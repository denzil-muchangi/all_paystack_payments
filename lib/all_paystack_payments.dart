// Re-export enums and classes for convenience
export 'enums.dart';
export 'paystack_error.dart';
export 'payment_request.dart';
export 'payment_response.dart';
export 'card_payment_request.dart';
export 'bank_transfer_request.dart';
export 'mobile_money_request.dart';
export 'webview_payment_handler.dart';

import 'all_paystack_payments_platform_interface.dart';
import 'card_payment_request.dart';
import 'bank_transfer_request.dart';
import 'mobile_money_request.dart';
import 'payment_request.dart';
import 'payment_response.dart';
import 'enums.dart';
import 'webview_payment_handler.dart';

/// Main class for Paystack payments integration.
///
/// This class provides a comprehensive Flutter plugin for integrating Paystack payment services,
/// supporting card payments, bank transfers, and mobile money transactions across multiple platforms.
///
/// ## Features
/// - Secure card tokenization with PCI DSS compliance
/// - Bank transfer payment processing
/// - Mobile money payments (M-Pesa, Airtel, Vodafone, Tigo)
/// - Multi-currency support (NGN, USD, GHS, ZAR, KES)
/// - Cross-platform support (Android, iOS, Web, Windows, Linux, macOS)
/// - Real-time payment verification and status checking
/// - Payment cancellation capabilities
///
/// ## Example
/// ```dart
/// import 'package:all_paystack_payments/all_paystack_payments.dart';
///
/// // Initialize the plugin
/// await AllPaystackPayments.initialize('pk_test_your_key');
///
/// // Process a card payment
/// final response = await AllPaystackPayments.initializeCardPayment(
///   amount: 50000, // ₦500.00 in kobo
///   email: 'customer@example.com',
///   cardNumber: '4084084084084081',
///   expiryMonth: '12',
///   expiryYear: '25',
///   cvv: '408',
///   cardHolderName: 'John Doe',
/// );
/// ```
class AllPaystackPayments {
  /// Initialize the Paystack SDK with your public key.
  ///
  /// This method must be called before using any other payment methods.
  /// The public key is used to authenticate requests to Paystack's API.
  ///
  /// ## Parameters
  /// - [publicKey]: Your Paystack public key (starts with 'pk_test_' for test mode or 'pk_live_' for live mode)
  ///
  /// ## Example
  /// ```dart
  /// await AllPaystackPayments.initialize('pk_test_your_public_key_here');
  /// ```
  ///
  /// ## Throws
  /// - [PaystackError] if initialization fails
  static Future<void> initialize(String publicKey) {
    return AllPaystackPaymentsPlatform.instance.initialize(publicKey);
  }

  /// Initialize a card payment with secure tokenization.
  ///
  /// This method processes debit/credit card payments using Paystack's secure tokenization system.
  /// Card details are immediately tokenized and never stored locally, ensuring PCI DSS compliance.
  ///
  /// ## Parameters
  /// - [amount]: Payment amount in kobo (smallest currency unit). E.g., ₦500.00 = 50000
  /// - [email]: Customer's email address
  /// - [cardNumber]: Card number (13-19 digits, no spaces or hyphens)
  /// - [expiryMonth]: Card expiry month (MM format, e.g., '12')
  /// - [expiryYear]: Card expiry year (YY format, e.g., '25')
  /// - [cvv]: Card verification value (3-4 digits)
  /// - [cardHolderName]: Name on the card
  /// - [reference]: Optional custom transaction reference (auto-generated if not provided)
  /// - [pin]: Optional debit card PIN (required for some cards)
  /// - [metadata]: Optional custom metadata for the transaction
  /// - [callbackUrl]: Optional callback URL for web redirects
  /// - [currency]: Transaction currency (defaults to NGN)
  ///
  /// ## Returns
  /// A [PaymentResponse] containing the payment result and status.
  ///
  /// ## Example
  /// ```dart
  /// final response = await AllPaystackPayments.initializeCardPayment(
  ///   amount: 50000, // ₦500.00
  ///   email: 'customer@example.com',
  ///   cardNumber: '4084084084084081',
  ///   expiryMonth: '12',
  ///   expiryYear: '25',
  ///   cvv: '408',
  ///   cardHolderName: 'John Doe',
  ///   reference: 'custom_ref_123',
  ///   metadata: {'order_id': '12345'},
  /// );
  ///
  /// if (response.isSuccessful) {
  ///   print('Payment successful: ${response.reference}');
  /// } else {
  ///   print('Payment failed: ${response.gatewayResponse}');
  /// }
  /// ```
  ///
  /// ## Throws
  /// - [PaystackError] for API errors (insufficient funds, card declined, etc.)
  /// - [ArgumentError] for invalid parameters
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
    Currency currency = Currency.ngn,
  }) async {
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

    // Get checkout URL from platform
    final checkoutUrl = await AllPaystackPaymentsPlatform.instance
        .getCheckoutUrl(request);

    // Process payment through webview
    final handler = WebViewPaymentHandlerFactory.create();
    return handler.processPayment(checkoutUrl);
  }

  /// Initialize a bank transfer payment.
  ///
  /// This method generates account details for customers to transfer money directly from their bank accounts.
  /// Paystack provides temporary account details that customers can use for the transfer.
  ///
  /// ## Parameters
  /// - [amount]: Payment amount in kobo (smallest currency unit)
  /// - [email]: Customer's email address
  /// - [reference]: Optional custom transaction reference (auto-generated if not provided)
  /// - [metadata]: Optional custom metadata for the transaction
  /// - [callbackUrl]: Optional callback URL for web redirects
  /// - [currency]: Transaction currency (defaults to NGN)
  ///
  /// ## Returns
  /// A [PaymentResponse] containing the payment result. The response's [rawResponse] will contain
  /// bank account details (account number, bank name, account name) that should be displayed to the customer.
  ///
  /// ## Example
  /// ```dart
  /// final response = await AllPaystackPayments.initializeBankTransfer(
  ///   amount: 100000, // ₦1,000.00
  ///   email: 'customer@example.com',
  ///   reference: 'bank_transfer_123',
  ///   metadata: {'invoice_id': 'INV-001'},
  /// );
  ///
  /// if (response.isSuccessful) {
  ///   // Display bank details to customer
  ///   final data = response.rawResponse['data'];
  ///   print('Bank: ${data['bank_name']}');
  ///   print('Account: ${data['account_number']}');
  ///   print('Name: ${data['account_name']}');
  /// }
  /// ```
  ///
  /// ## Throws
  /// - [PaystackError] for API errors
  static Future<PaymentResponse> initializeBankTransfer({
    required int amount,
    required String email,
    String? reference,
    Map<String, dynamic>? metadata,
    String? callbackUrl,
    Currency currency = Currency.ngn,
  }) async {
    final request = BankTransferRequest(
      amount: amount,
      currency: currency,
      email: email,
      reference: reference,
      metadata: metadata,
      callbackUrl: callbackUrl,
    );

    // Get checkout URL from platform
    final checkoutUrl = await AllPaystackPaymentsPlatform.instance
        .getCheckoutUrl(request);

    // Process payment through webview
    final handler = WebViewPaymentHandlerFactory.create();
    return handler.processPayment(checkoutUrl);
  }

  /// Initialize a mobile money payment.
  ///
  /// This method processes payments from mobile money wallets including M-Pesa, Airtel Money,
  /// Vodafone Cash, and Tigo Cash. The customer will receive a prompt on their mobile device.
  ///
  /// ## Parameters
  /// - [amount]: Payment amount in kobo (smallest currency unit)
  /// - [email]: Customer's email address
  /// - [provider]: Mobile money provider ([MobileMoneyProvider.mpesa], [MobileMoneyProvider.airtel], etc.)
  /// - [phoneNumber]: Customer's phone number with country code (e.g., '+254712345678')
  /// - [reference]: Optional custom transaction reference (auto-generated if not provided)
  /// - [metadata]: Optional custom metadata for the transaction
  /// - [callbackUrl]: Optional callback URL for web redirects
  /// - [currency]: Transaction currency (defaults to NGN)
  ///
  /// ## Supported Providers
  /// - [MobileMoneyProvider.mpesa]: M-Pesa (Kenya) - requires KES currency
  /// - [MobileMoneyProvider.airtel]: Airtel Money (Kenya, Tanzania, Uganda)
  /// - [MobileMoneyProvider.vodafone]: Vodafone Cash (Ghana)
  /// - [MobileMoneyProvider.tigo]: Tigo Cash (Ghana)
  ///
  /// ## Returns
  /// A [PaymentResponse] containing the payment result and status.
  ///
  /// ## Example
  /// ```dart
  /// final response = await AllPaystackPayments.initializeMobileMoney(
  ///   amount: 25000, // ₦250.00
  ///   email: 'customer@example.com',
  ///   provider: MobileMoneyProvider.mpesa,
  ///   phoneNumber: '+254712345678',
  ///   currency: Currency.kes, // Required for M-Pesa
  /// );
  ///
  /// if (response.isSuccessful) {
  ///   print('Mobile money payment initiated');
  ///   // Customer will receive a prompt on their phone
  /// }
  /// ```
  ///
  /// ## Throws
  /// - [PaystackError] for API errors (insufficient balance, invalid phone, etc.)
  /// - [ArgumentError] for invalid phone number format or unsupported provider/country combinations
  static Future<PaymentResponse> initializeMobileMoney({
    required int amount,
    required String email,
    required MobileMoneyProvider provider,
    required String phoneNumber,
    String? reference,
    Map<String, dynamic>? metadata,
    String? callbackUrl,
    Currency currency = Currency.ngn,
  }) async {
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

    // Get checkout URL from platform
    final checkoutUrl = await AllPaystackPaymentsPlatform.instance
        .getCheckoutUrl(request);

    // Process payment through webview
    final handler = WebViewPaymentHandlerFactory.create();
    return handler.processPayment(checkoutUrl);
  }

  /// Initialize payment with a custom request object.
  ///
  /// This method allows for advanced payment processing using custom [PaymentRequest] objects.
  /// Useful for implementing custom payment flows or when you need more control over request parameters.
  ///
  /// ## Parameters
  /// - [request]: A custom [PaymentRequest] object containing all payment details
  ///
  /// ## Returns
  /// A [PaymentResponse] containing the payment result and status.
  ///
  /// ## Example
  /// ```dart
  /// final customRequest = CardPaymentRequest(
  ///   amount: 50000,
  ///   currency: Currency.ngn,
  ///   email: 'customer@example.com',
  ///   cardNumber: '4084084084084081',
  ///   expiryMonth: '12',
  ///   expiryYear: '25',
  ///   cvv: '408',
  ///   cardHolderName: 'John Doe',
  /// );
  ///
  /// final response = await AllPaystackPayments.initializePayment(customRequest);
  /// ```
  static Future<PaymentResponse> initializePayment(
    PaymentRequest request,
  ) async {
    // Get checkout URL from platform
    final checkoutUrl = await AllPaystackPaymentsPlatform.instance
        .getCheckoutUrl(request);

    // Process payment through webview
    final handler = WebViewPaymentHandlerFactory.create();
    return handler.processPayment(checkoutUrl);
  }

  /// Verify a payment transaction.
  ///
  /// This method checks the final status of a payment transaction with Paystack's servers.
  /// Should be called after payment initiation to confirm completion, especially for asynchronous payments.
  ///
  /// ## Parameters
  /// - [reference]: The transaction reference to verify
  ///
  /// ## Returns
  /// A [PaymentResponse] with the verified payment status and details.
  ///
  /// ## Example
  /// ```dart
  /// final response = await AllPaystackPayments.verifyPayment('txn_ref_123');
  ///
  /// switch (response.status) {
  ///   case PaymentStatus.success:
  ///     // Payment completed successfully
  ///     break;
  ///   case PaymentStatus.failed:
  ///     // Payment failed
  ///     break;
  ///   case PaymentStatus.pending:
  ///     // Payment still processing
  ///     break;
  /// }
  /// ```
  ///
  /// ## Throws
  /// - [PaystackError] if verification fails
  static Future<PaymentResponse> verifyPayment(String reference) {
    return AllPaystackPaymentsPlatform.instance.verifyPayment(reference);
  }

  /// Get the current status of a payment transaction.
  ///
  /// This method retrieves the current status of any payment without performing full verification.
  /// Useful for checking status during polling or when you need quick status updates.
  ///
  /// ## Parameters
  /// - [reference]: The transaction reference to check
  ///
  /// ## Returns
  /// A [PaymentResponse] with the current payment status and details.
  ///
  /// ## Example
  /// ```dart
  /// final response = await AllPaystackPayments.getPaymentStatus('txn_ref_123');
  ///
  /// if (response.isPending) {
  ///   print('Payment is still processing...');
  /// } else if (response.isSuccessful) {
  ///   print('Payment completed!');
  /// }
  /// ```
  ///
  /// ## Throws
  /// - [PaystackError] if status check fails
  static Future<PaymentResponse> getPaymentStatus(String reference) {
    return AllPaystackPaymentsPlatform.instance.getPaymentStatus(reference);
  }

  /// Cancel a pending payment transaction.
  ///
  /// This method attempts to cancel a payment that is still in pending status.
  /// Note that only pending payments can be cancelled; completed payments cannot be cancelled.
  ///
  /// ## Parameters
  /// - [reference]: The transaction reference to cancel
  ///
  /// ## Returns
  /// `true` if the payment was successfully cancelled, `false` otherwise.
  ///
  /// ## Example
  /// ```dart
  /// final success = await AllPaystackPayments.cancelPayment('txn_ref_123');
  ///
  /// if (success) {
  ///   print('Payment cancelled successfully');
  /// } else {
  ///   print('Could not cancel payment - may already be processed');
  /// }
  /// ```
  ///
  /// ## Throws
  /// - [PaystackError] if cancellation fails
  static Future<bool> cancelPayment(String reference) {
    return AllPaystackPaymentsPlatform.instance.cancelPayment(reference);
  }

  /// For backward compatibility.
  static Future<String?> getPlatformVersion() async {
    return AllPaystackPaymentsPlatform.instance.getPlatformVersion();
  }
}
