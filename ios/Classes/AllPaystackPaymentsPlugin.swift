import Flutter
import UIKit
import PaystackCore
import PaystackUI

public class AllPaystackPaymentsPlugin: NSObject, FlutterPlugin {
  private var registrar: FlutterPluginRegistrar?
  private var currentTransaction: PSTCKPaymentTransaction?

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
    case "verifyPayment":
      handleVerifyPayment(call, result: result)
    case "getPaymentStatus":
      handleGetPaymentStatus(call, result: result)
    case "cancelPayment":
      handleCancelPayment(call, result: result)
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

    Paystack.setDefaultPublicKey(publicKey)
    result(nil)
  }

  private func handleInitializePayment(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let paymentMethod = args["payment_method"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Payment method is required", details: nil))
      return
    }

    guard let viewController = getRootViewController() else {
      result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Unable to get root view controller", details: nil))
      return
    }

    switch paymentMethod {
    case "card":
      handleCardPayment(args: args, viewController: viewController, result: result)
    case "bank_transfer":
      handleBankTransferPayment(args: args, viewController: viewController, result: result)
    case "mobile_money":
      handleMobileMoneyPayment(args: args, viewController: viewController, result: result)
    default:
      result(FlutterError(code: "UNSUPPORTED_METHOD", message: "Payment method not supported", details: nil))
    }
  }

  private func handleCardPayment(args: [String: Any], viewController: UIViewController, result: @escaping FlutterResult) {
    guard let cardData = args["card"] as? [String: Any],
          let number = cardData["number"] as? String,
          let expiryMonth = cardData["expiry_month"] as? String,
          let expiryYear = cardData["expiry_year"] as? String,
          let cvv = cardData["cvv"] as? String,
          let amount = args["amount"] as? Int,
          let email = args["email"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Card details and payment info required", details: nil))
      return
    }

    let reference = args["reference"] as? String ?? UUID().uuidString

    do {
      let transactionParams = PSTCKTransactionParams()
      transactionParams.amount = UInt(amount)
      transactionParams.email = email
      transactionParams.reference = reference

      let cardParams = PSTCKCardParams()
      cardParams.number = number
      cardParams.expiryMonth = UInt(expiryMonth) ?? 0
      cardParams.expiryYear = UInt(expiryYear) ?? 0
      cardParams.cvc = cvv

      if let pin = cardData["pin"] as? String {
        cardParams.pin = pin
      }

      let transaction = PSTCKPaymentTransaction(params: transactionParams, cardParams: cardParams)

      currentTransaction = transaction

      transaction.chargeCard(on: viewController) { [weak self] (reference, error) in
        guard let self = self else { return }

        if let error = error {
          result(FlutterError(code: "PAYMENT_FAILED", message: error.localizedDescription, details: nil))
          return
        }

        if let reference = reference {
          let response: [String: Any] = [
            "reference": reference,
            "status": "success",
            "amount": amount,
            "currency": args["currency"] as? String ?? "NGN",
            "payment_method": "card",
            "gateway_response": "Payment successful"
          ]
          result(response)
        } else {
          result(FlutterError(code: "PAYMENT_FAILED", message: "Payment failed with unknown error", details: nil))
        }
      } catch {
        result(FlutterError(code: "PAYMENT_FAILED", message: error.localizedDescription, details: nil))
      }
    } catch {
      result(FlutterError(code: "PAYMENT_FAILED", message: "Failed to create payment transaction: \(error.localizedDescription)", details: nil))
    }
  }

  private func handleBankTransferPayment(args: [String: Any], viewController: UIViewController, result: @escaping FlutterResult) {
    guard let amount = args["amount"] as? Int,
          let email = args["email"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Amount and email required", details: nil))
      return
    }

    let reference = args["reference"] as? String ?? UUID().uuidString

    let transactionParams = PSTCKTransactionParams()
    transactionParams.amount = UInt(amount)
    transactionParams.email = email
    transactionParams.reference = reference

    // For bank transfers, we initialize the transaction and return the transfer details
    Paystack.shared.charge(with: transactionParams) { [weak self] (transaction, error) in
      guard let self = self else { return }

      if let error = error {
        result(FlutterError(code: "PAYMENT_FAILED", message: error.localizedDescription, details: nil))
        return
      }

      if let transaction = transaction {
        // For bank transfers, we need to get the transfer details
        // This is a simplified implementation - in practice, you'd need to handle the transfer flow
        let response: [String: Any] = [
          "reference": reference,
          "status": "pending",
          "amount": amount,
          "currency": args["currency"] as? String ?? "NGN",
          "payment_method": "bank_transfer",
          "gateway_response": "Bank transfer initiated"
        ]
        result(response)
      } else {
        result(FlutterError(code: "PAYMENT_FAILED", message: "Failed to initialize bank transfer", details: nil))
      }
    }
  }

  private func handleMobileMoneyPayment(args: [String: Any], viewController: UIViewController, result: @escaping FlutterResult) {
    guard let mobileMoneyData = args["mobile_money"] as? [String: Any],
          let provider = mobileMoneyData["provider"] as? String,
          let phoneNumber = mobileMoneyData["phone_number"] as? String,
          let amount = args["amount"] as? Int,
          let email = args["email"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Mobile money details and payment info required", details: nil))
      return
    }

    let reference = args["reference"] as? String ?? UUID().uuidString

    let transactionParams = PSTCKTransactionParams()
    transactionParams.amount = UInt(amount)
    transactionParams.email = email
    transactionParams.reference = reference

    // Set mobile money provider
    switch provider.lowercased() {
    case "mpesa":
      transactionParams.paymentMethod = .mpesa
    case "airtel":
      transactionParams.paymentMethod = .airtel
    case "vodafone":
      transactionParams.paymentMethod = .vodafone
    case "tigo":
      transactionParams.paymentMethod = .tigo
    default:
      result(FlutterError(code: "UNSUPPORTED_PROVIDER", message: "Mobile money provider not supported", details: nil))
      return
    }

    // For mobile money, we initialize the transaction
    Paystack.shared.charge(with: transactionParams) { [weak self] (transaction, error) in
      guard let self = self else { return }

      if let error = error {
        result(FlutterError(code: "PAYMENT_FAILED", message: error.localizedDescription, details: nil))
        return
      }

      if let transaction = transaction {
        let response: [String: Any] = [
          "reference": reference,
          "status": "pending",
          "amount": amount,
          "currency": args["currency"] as? String ?? "NGN",
          "payment_method": "mobile_money",
          "gateway_response": "Mobile money payment initiated"
        ]
        result(response)
      } else {
        result(FlutterError(code: "PAYMENT_FAILED", message: "Failed to initialize mobile money payment", details: nil))
      }
    }
  }

  private func handleVerifyPayment(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let reference = args["reference"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Reference is required", details: nil))
      return
    }

    // Verify payment using Paystack API
    Paystack.shared.verifyTransaction(reference) { (transaction, error) in
      if let error = error {
        result(FlutterError(code: "VERIFICATION_FAILED", message: error.localizedDescription, details: nil))
        return
      }

      if let transaction = transaction {
        let status = transaction.status == .success ? "success" : "failed"
        let response: [String: Any] = [
          "reference": reference,
          "status": status,
          "amount": transaction.amount,
          "currency": "NGN", // Default, should be configurable
          "payment_method": "card", // Default, should be determined from transaction
          "gateway_response": transaction.message ?? "Verification completed"
        ]
        result(response)
      } else {
        result(FlutterError(code: "VERIFICATION_FAILED", message: "Transaction not found", details: nil))
      }
    }
  }

  private func handleGetPaymentStatus(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let reference = args["reference"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Reference is required", details: nil))
      return
    }

    // Get payment status - similar to verification
    Paystack.shared.verifyTransaction(reference) { (transaction, error) in
      if let error = error {
        result(FlutterError(code: "STATUS_CHECK_FAILED", message: error.localizedDescription, details: nil))
        return
      }

      if let transaction = transaction {
        let status = transaction.status == .success ? "success" : transaction.status == .failed ? "failed" : "pending"
        let response: [String: Any] = [
          "reference": reference,
          "status": status,
          "amount": transaction.amount,
          "currency": "NGN",
          "payment_method": "card",
          "gateway_response": transaction.message ?? "Status check completed"
        ]
        result(response)
      } else {
        result(FlutterError(code: "STATUS_CHECK_FAILED", message: "Transaction not found", details: nil))
      }
    }
  }

  private func handleCancelPayment(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let reference = args["reference"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Reference is required", details: nil))
      return
    }

    // Paystack doesn't support canceling transactions once initiated
    // Return false to indicate cancellation is not possible
    result(false)
  }

  private func getRootViewController() -> UIViewController? {
    guard let registrar = registrar else { return nil }

    if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
      var viewController = window.rootViewController
      while let presentedViewController = viewController?.presentedViewController {
        viewController = presentedViewController
      }
      return viewController
    }

    return registrar.viewController
  }
}
