import 'enums.dart';

/// Response from a payment operation
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

  /// Factory method to create response from API data
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

  /// Check if payment was successful
  bool get isSuccessful => status == PaymentStatus.success;

  /// Check if payment is pending
  bool get isPending => status == PaymentStatus.pending;

  /// Check if payment failed
  bool get isFailed => status == PaymentStatus.failed;

  @override
  String toString() {
    return 'PaymentResponse(reference: $reference, status: $status, amount: $amount, currency: $currency, paymentMethod: $paymentMethod)';
  }
}
