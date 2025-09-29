// Re-export enums and classes for convenience
export 'enums.dart';
export 'paystack_error.dart';
export 'payment_request.dart';
export 'payment_response.dart';
export 'card_payment_request.dart';
export 'bank_transfer_request.dart';
export 'mobile_money_request.dart';

import 'all_paystack_payments_platform_interface.dart';
import 'card_payment_request.dart';
import 'bank_transfer_request.dart';
import 'mobile_money_request.dart';
import 'payment_request.dart';
import 'payment_response.dart';
import 'enums.dart';

/// Main class for Paystack payments integration
class AllPaystackPayments {
  /// Initialize the Paystack SDK with your public key
  static Future<void> initialize(String publicKey) {
    return AllPaystackPaymentsPlatform.instance.initialize(publicKey);
  }

  /// Initialize a card payment
  static Future<PaymentResponse> initializeCardPayment({
    required int amount,
    required String email,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardHolderName,
    String? reference,
    String? pin,
    Map<String, dynamic>? metadata,
    String? callbackUrl,
    Currency currency =
        Currency.ngn, // Make currency configurable, default to NGN
  }) {
    final request = CardPaymentRequest(
      amount: amount,
      currency: currency,
      email: email,
      reference: reference,
      cardNumber: cardNumber,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      cvv: cvv,
      cardHolderName: cardHolderName,
      pin: pin,
      metadata: metadata,
      callbackUrl: callbackUrl,
    );
    return AllPaystackPaymentsPlatform.instance.initializePayment(request);
  }

  /// Initialize a bank transfer payment
  static Future<PaymentResponse> initializeBankTransfer({
    required int amount,
    required String email,
    String? reference,
    Map<String, dynamic>? metadata,
    String? callbackUrl,
    Currency currency =
        Currency.ngn, // Make currency configurable, default to NGN
  }) {
    final request = BankTransferRequest(
      amount: amount,
      currency: currency,
      email: email,
      reference: reference,
      metadata: metadata,
      callbackUrl: callbackUrl,
    );
    return AllPaystackPaymentsPlatform.instance.initializePayment(request);
  }

  /// Initialize a mobile money payment
  static Future<PaymentResponse> initializeMobileMoney({
    required int amount,
    required String email,
    required MobileMoneyProvider provider,
    required String phoneNumber,
    String? reference,
    Map<String, dynamic>? metadata,
    String? callbackUrl,
    Currency currency =
        Currency.ngn, // Make currency configurable, default to NGN
  }) {
    final request = MobileMoneyRequest(
      amount: amount,
      currency: currency,
      email: email,
      reference: reference,
      provider: provider,
      phoneNumber: phoneNumber,
      metadata: metadata,
      callbackUrl: callbackUrl,
    );
    return AllPaystackPaymentsPlatform.instance.initializePayment(request);
  }

  /// Initialize payment with a custom request object
  static Future<PaymentResponse> initializePayment(PaymentRequest request) {
    return AllPaystackPaymentsPlatform.instance.initializePayment(request);
  }

  /// Verify a payment transaction
  static Future<PaymentResponse> verifyPayment(String reference) {
    return AllPaystackPaymentsPlatform.instance.verifyPayment(reference);
  }

  /// Get payment status
  static Future<PaymentResponse> getPaymentStatus(String reference) {
    return AllPaystackPaymentsPlatform.instance.getPaymentStatus(reference);
  }

  /// Cancel a payment transaction
  static Future<bool> cancelPayment(String reference) {
    return AllPaystackPaymentsPlatform.instance.cancelPayment(reference);
  }

  /// For backward compatibility.
  static Future<String?> getPlatformVersion() async {
    return AllPaystackPaymentsPlatform.instance.getPlatformVersion();
  }
}
