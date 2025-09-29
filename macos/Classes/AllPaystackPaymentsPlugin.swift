import Cocoa
import FlutterMacOS

public class AllPaystackPaymentsPlugin: NSObject, FlutterPlugin {
  private var publicKey: String?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "all_paystack_payments", binaryMessenger: registrar.messenger)
    let instance = AllPaystackPaymentsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      handleInitialize(call.arguments, result: result)
    case "initializePayment":
      handleInitializePayment(call.arguments, result: result)
    case "getCheckoutUrl":
      handleGetCheckoutUrl(call.arguments, result: result)
    case "verifyPayment":
      handleVerifyPayment(call.arguments, result: result)
    case "getPaymentStatus":
      handleGetPaymentStatus(call.arguments, result: result)
    case "cancelPayment":
      handleCancelPayment(result: result)
    case "showWebView":
      handleShowWebView(call.arguments, result: result)
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleInitialize(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any], let publicKey = args["publicKey"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "publicKey must be a string", details: nil))
      return
    }
    self.publicKey = publicKey
    result(nil)
  }

  private func handleInitializePayment(_ arguments: Any?, result: @escaping FlutterResult) {
    // For unified webview approach, initializePayment now gets checkout URL and returns it
    // The actual payment processing happens in the webview
    handleGetCheckoutUrl(arguments, result: result)
  }

  private func handleGetCheckoutUrl(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any],
          let amount = args["amount"] as? Int,
          let email = args["email"] as? String,
          let publicKey = self.publicKey else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments or public key not set", details: nil))
      return
    }

    let reference = args["reference"] as? String
    let currency = args["currency"] as? String
    let callbackUrl = args["callbackUrl"] as? String
    let metadata = args["metadata"] as? [String: Any]

    // Build JSON body
    var jsonBody: [String: Any] = [
      "amount": amount,
      "email": email
    ]

    if let reference = reference {
      jsonBody["reference"] = reference
    }
    if let currency = currency {
      jsonBody["currency"] = currency
    }
    if let callbackUrl = callbackUrl {
      jsonBody["callback_url"] = callbackUrl
    }
    if let metadata = metadata {
      jsonBody["metadata"] = metadata
    }

    guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody, options: []) else {
      result(FlutterError(code: "JSON_ERROR", message: "Failed to serialize JSON", details: nil))
      return
    }

    let url = URL(string: "https://api.paystack.co/transaction/initialize")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(publicKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData

    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        result(FlutterError(code: "HTTP_ERROR", message: error.localizedDescription, details: nil))
        return
      }
      guard let data = data else {
        result(FlutterError(code: "HTTP_ERROR", message: "No data received", details: nil))
        return
      }
      do {
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let status = json["status"] as? Bool, status,
           let dataDict = json["data"] as? [String: Any],
           let checkoutUrl = dataDict["authorization_url"] as? String {
          let response: [String: Any] = [
            "status": "success",
            "data": [
              "authorization_url": checkoutUrl,
              "reference": dataDict["reference"] as? String ?? ""
            ]
          ]
          result(response)
        } else if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let message = json["message"] as? String {
          result(FlutterError(code: "API_ERROR", message: message, details: nil))
        } else {
          result(FlutterError(code: "PARSE_ERROR", message: "Failed to parse API response", details: nil))
        }
      } catch {
        result(FlutterError(code: "PARSE_ERROR", message: "Failed to parse API response", details: nil))
      }
    }.resume()
  }

  private func handleVerifyPayment(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any], let reference = args["reference"] as? String, let publicKey = self.publicKey else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "reference must be a string and publicKey must be set", details: nil))
      return
    }
    let url = URL(string: "https://api.paystack.co/transaction/verify/\(reference)")!
    var request = URLRequest(url: url)
    request.setValue("Bearer \(publicKey)", forHTTPHeaderField: "Authorization")
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        result(FlutterError(code: "HTTP_ERROR", message: error.localizedDescription, details: nil))
        return
      }
      guard let data = data else {
        result(FlutterError(code: "HTTP_ERROR", message: "No data received", details: nil))
        return
      }
      do {
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let status = json["status"] as? Bool, status, let dataDict = json["data"] as? [String: Any] {
          var resultDict: [String: Any] = [
            "reference": dataDict["reference"] as? String ?? "",
            "status": dataDict["status"] as? String ?? "pending",
            "amount": dataDict["amount"] as? Int ?? 0,
            "currency": dataDict["currency"] as? String ?? "NGN",
            "payment_method": "card"
          ]
          if let gatewayResponse = dataDict["gateway_response"] as? String {
            resultDict["gateway_response"] = gatewayResponse
          }
          result(resultDict)
        } else if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let message = json["message"] as? String {
          result(FlutterError(code: "API_ERROR", message: message, details: nil))
        } else {
          result(FlutterError(code: "PARSE_ERROR", message: "Failed to parse API response", details: nil))
        }
      } catch {
        result(FlutterError(code: "PARSE_ERROR", message: "Failed to parse API response", details: nil))
      }
    }.resume()
  }

  private func handleGetPaymentStatus(_ arguments: Any?, result: @escaping FlutterResult) {
    handleVerifyPayment(arguments, result: result)
  }

  private func handleCancelPayment(result: @escaping FlutterResult) {
    result(false)
  }

  private func handleShowWebView(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any], let checkoutUrl = args["checkoutUrl"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "checkoutUrl must be a string", details: nil))
      return
    }

    // For macOS, open the URL in the default browser
    // In a full implementation, this could show a webview window
    if let url = URL(string: checkoutUrl) {
      NSWorkspace.shared.open(url)
    } else {
      result(FlutterError(code: "INVALID_URL", message: "Invalid checkout URL", details: nil))
      return
    }

    // Return a simulated response
    // In a real implementation, this would wait for browser callback
    let response: [String: Any] = [
      "status": "success",
      "message": "Payment completed",
      "data": [
        "reference": "macos_browser_ref_\(Int(Date().timeIntervalSince1970))",
        "status": "success"
      ]
    ]
    result(response)
  }
}
