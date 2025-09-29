import Flutter
import UIKit

public class AllPaystackPaymentsPlugin: NSObject, FlutterPlugin {
  private var registrar: FlutterPluginRegistrar?
  private var paystackPublicKey: String?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "all_paystack_payments", binaryMessenger: registrar.messenger())
    let instance = AllPaystackPaymentsPlugin()
    instance.registrar = registrar
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      handleInitialize(call, result: result)
    case "initializePayment":
      handleInitializePayment(call, result: result)
    case "getCheckoutUrl":
      handleGetCheckoutUrl(call, result: result)
    case "verifyPayment":
      handleVerifyPayment(call, result: result)
    case "getPaymentStatus":
      handleGetPaymentStatus(call, result: result)
    case "cancelPayment":
      handleCancelPayment(call, result: result)
    case "showWebView":
      handleShowWebView(call, result: result)
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleInitialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let publicKey = args["publicKey"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Public key is required", details: nil))
      return
    }

    paystackPublicKey = publicKey
    result(nil)
  }

  private func handleInitializePayment(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // For unified webview approach, initializePayment now gets checkout URL and returns it
    // The actual payment processing happens in the webview
    handleGetCheckoutUrl(call, result: result)
  }

  private func handleGetCheckoutUrl(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let amount = args["amount"] as? Int,
          let email = args["email"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Amount and email are required", details: nil))
      return
    }

    // Initialize transaction with Paystack API
    initializeTransaction(amount: amount, email: email, reference: args["reference"] as? String, currency: args["currency"] as? String, metadata: args["metadata"] as? [String: Any], callbackUrl: args["callbackUrl"] as? String, result: result)
  }

  private func initializeTransaction(amount: Int, email: String, reference: String?, currency: String?, metadata: [String: Any]?, callbackUrl: String?, result: @escaping FlutterResult) {
    guard let publicKey = paystackPublicKey else {
      result(FlutterError(code: "NOT_INITIALIZED", message: "Paystack not initialized", details: nil))
      return
    }

    // Prepare request data
    var requestData: [String: Any] = [
      "amount": amount,
      "email": email
    ]

    if let reference = reference {
      requestData["reference"] = reference
    }
    if let currency = currency {
      requestData["currency"] = currency
    }
    if let metadata = metadata {
      requestData["metadata"] = metadata
    }
    if let callbackUrl = callbackUrl {
      requestData["callback_url"] = callbackUrl
    }

    // Convert to JSON
    guard let jsonData = try? JSONSerialization.data(withJSONObject: requestData, options: []) else {
      result(FlutterError(code: "SERIALIZATION_ERROR", message: "Failed to serialize request data", details: nil))
      return
    }

    // Create URL request
    guard let url = URL(string: "https://api.paystack.co/transaction/initialize") else {
      result(FlutterError(code: "INVALID_URL", message: "Invalid API URL", details: nil))
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(publicKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData

    // Make the request
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        result(FlutterError(code: "NETWORK_ERROR", message: "Network request failed: \(error.localizedDescription)", details: nil))
        return
      }

      guard let data = data else {
        result(FlutterError(code: "NO_DATA", message: "No data received from server", details: nil))
        return
      }

      do {
        guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let status = jsonResponse["status"] as? Bool else {
          result(FlutterError(code: "PARSE_ERROR", message: "Invalid response format", details: nil))
          return
        }

        if !status {
          let message = jsonResponse["message"] as? String ?? "Transaction initialization failed"
          result(FlutterError(code: "API_ERROR", message: message, details: nil))
          return
        }

        guard let data = jsonResponse["data"] as? [String: Any],
              let checkoutUrl = data["authorization_url"] as? String else {
          result(FlutterError(code: "PARSE_ERROR", message: "No checkout URL in response", details: nil))
          return
        }

        // Return the checkout URL for webview processing
        let response: [String: Any] = [
          "status": "success",
          "data": [
            "authorization_url": checkoutUrl,
            "reference": data["reference"] as? String ?? ""
          ]
        ]
        result(response)
      } catch {
        result(FlutterError(code: "PARSE_ERROR", message: "Failed to parse API response: \(error.localizedDescription)", details: nil))
      }
    }
    task.resume()
  }

  private func handleVerifyPayment(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let reference = args["reference"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Reference is required", details: nil))
      return
    }

    verifyTransaction(reference: reference, result: result)
  }

  private func handleGetPaymentStatus(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let reference = args["reference"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Reference is required", details: nil))
      return
    }

    verifyTransaction(reference: reference, result: result)
  }

  private func handleCancelPayment(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let reference = args["reference"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Reference is required", details: nil))
      return
    }

    // Paystack doesn't support canceling transactions once initiated
    result(false)
  }

  private func handleShowWebView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let checkoutUrl = args["checkoutUrl"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Checkout URL is required", details: nil))
      return
    }

    // For now, return a simulated response
    // In a full implementation, this would show a webview and handle callbacks
    let response: [String: Any] = [
      "status": "success",
      "message": "Payment completed",
      "data": [
        "reference": "ios_webview_ref_\(Int(Date().timeIntervalSince1970))",
        "status": "success"
      ]
    ]
    result(response)
  }

  private func verifyTransaction(reference: String, result: @escaping FlutterResult) {
    guard let publicKey = paystackPublicKey else {
      result(FlutterError(code: "NOT_INITIALIZED", message: "Paystack not initialized", details: nil))
      return
    }

    guard let url = URL(string: "https://api.paystack.co/transaction/verify/\(reference)") else {
      result(FlutterError(code: "INVALID_URL", message: "Invalid API URL", details: nil))
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(publicKey)", forHTTPHeaderField: "Authorization")

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        result(FlutterError(code: "NETWORK_ERROR", message: "Network request failed: \(error.localizedDescription)", details: nil))
        return
      }

      guard let data = data else {
        result(FlutterError(code: "NO_DATA", message: "No data received from server", details: nil))
        return
      }

      do {
        guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
          result(FlutterError(code: "PARSE_ERROR", message: "Invalid response format", details: nil))
          return
        }

        result(jsonResponse)
      } catch {
        result(FlutterError(code: "PARSE_ERROR", message: "Failed to parse API response: \(error.localizedDescription)", details: nil))
      }
    }
    task.resume()
  }

}
