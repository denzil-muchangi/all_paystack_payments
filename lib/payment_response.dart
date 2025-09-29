import 'enums.dart';

/// Response from a payment operation.
///
/// This class encapsulates the result of any payment-related operation, including
/// payment initiation, verification, and status checks. It provides a unified interface
/// for handling payment responses across all payment methods.
///
/// ## Properties
/// - [reference]: Unique transaction reference
/// - [status]: Current payment status ([PaymentStatus])
/// - [amount]: Transaction amount in kobo (smallest currency unit)
/// - [currency]: Transaction currency
/// - [paymentMethod]: Payment method used
/// - [gatewayResponse]: Human-readable response message from Paystack
/// - [rawResponse]: Complete raw response data from Paystack API
/// - [createdAt]: Timestamp when the transaction was created
///
/// ## Example
/// ```dart
/// final response = await AllPaystackPayments.initializeCardPayment(...);
///
/// if (response.isSuccessful) {
///   print('Payment successful: ${response.reference}');
///   print('Amount: ₦${response.amount / 100}');
/// } else {
///   print('Payment failed: ${response.gatewayResponse}');
/// }
/// ```
class PaymentResponse {
  /// Unique transaction reference
  final String reference;

  /// Payment status
  final PaymentStatus status;

  /// Transaction amount in kobo (smallest currency unit)
  final int amount;

  /// Currency used for the transaction
  final Currency currency;

  /// Payment method used
  final PaymentMethod paymentMethod;

  /// Gateway response message
  final String? gatewayResponse;

  /// Raw response data from Paystack API
  final Map<String, dynamic>? rawResponse;

  /// Timestamp of the transaction
  final DateTime? createdAt;

  PaymentResponse({
    required this.reference,
    required this.status,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.gatewayResponse,
    this.rawResponse,
    this.createdAt,
  });

  /// Factory method to create response from API data.
  ///
  /// Creates a [PaymentResponse] instance from raw Paystack API response data.
  /// This method handles parsing and type conversion of API response fields.
  ///
  /// ## Parameters
  /// - [response]: Raw response map from Paystack API
  ///
  /// ## Returns
  /// A new [PaymentResponse] instance with parsed data.
  factory PaymentResponse.fromApiResponse(Map<String, dynamic> response) {
    return PaymentResponse(
      reference: response['reference'] as String? ?? '',
      status: _parseStatus(response['status'] as String?),
      amount: response['amount'] as int? ?? 0,
      currency: _parseCurrency(response['currency'] as String?),
      paymentMethod: _parsePaymentMethod(response['payment_method'] as String?),
      gatewayResponse: response['gateway_response'] as String?,
      rawResponse: response,
      createdAt: response['created_at'] != null
          ? DateTime.parse(response['created_at'] as String)
          : null,
    );
  }

  static PaymentStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      case 'cancelled':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }

  static Currency _parseCurrency(String? currency) {
    switch (currency?.toUpperCase()) {
      case 'USD':
        return Currency.usd;
      case 'GHS':
        return Currency.ghs;
      case 'ZAR':
        return Currency.zar;
      case 'KES':
        return Currency.kes;
      default:
        return Currency.ngn;
    }
  }

  static PaymentMethod _parsePaymentMethod(String? method) {
    switch (method?.toLowerCase()) {
      case 'bank_transfer':
        return PaymentMethod.bankTransfer;
      case 'mobile_money':
        return PaymentMethod.mobileMoney;
      default:
        return PaymentMethod.card;
    }
  }

  /// Check if payment was successful.
  ///
  /// Returns `true` if the payment status is [PaymentStatus.success].
  bool get isSuccessful => status == PaymentStatus.success;

  /// Check if payment is pending.
  ///
  /// Returns `true` if the payment status is [PaymentStatus.pending].
  /// Pending payments may still complete or fail.
  bool get isPending => status == PaymentStatus.pending;

  /// Check if payment failed.
  ///
  /// Returns `true` if the payment status is [PaymentStatus.failed].
  bool get isFailed => status == PaymentStatus.failed;

  @override
  String toString() {
    return 'PaymentResponse(reference: $reference, status: $status, amount: $amount, currency: $currency, paymentMethod: $paymentMethod)';
  }
}
