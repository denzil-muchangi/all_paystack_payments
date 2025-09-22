import 'enums.dart';

/// Base class for all payment requests
abstract class PaymentRequest {
  /// Amount to be charged in kobo (smallest currency unit)
  final int amount;

  /// Currency for the transaction
  final Currency currency;

  /// Email address of the customer
  final String email;

  /// Unique reference for the transaction (optional, will be generated if not provided)
  final String? reference;

  /// Payment method type
  final PaymentMethod paymentMethod;

  /// Additional metadata for the transaction
  final Map<String, dynamic>? metadata;

  /// Callback URL for web payments
  final String? callbackUrl;

  PaymentRequest({
    required this.amount,
    required this.currency,
    required this.email,
    this.reference,
    required this.paymentMethod,
    this.metadata,
    this.callbackUrl,
  });

  /// Convert request to JSON for API call
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency.name.toUpperCase(),
      'email': email,
      'reference': reference,
      'payment_method': paymentMethod.name,
      'metadata': metadata,
      'callback_url': callbackUrl,
      ...getSpecificJson(),
    };
  }

  /// Method to be implemented by subclasses for payment-method-specific data
  Map<String, dynamic> getSpecificJson();

  /// Validate the request data
  void validate() {
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than 0');
    }
    if (email.isEmpty || !email.contains('@')) {
      throw ArgumentError('Valid email is required');
    }
  }
}
