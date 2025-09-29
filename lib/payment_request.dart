import 'enums.dart';
import 'validation_utils.dart';

/// Base class for all payment requests.
///
/// This abstract class provides the foundation for all payment request types.
/// It handles common validation, sanitization, and JSON serialization for payment data.
///
/// ## Subclasses
/// - [CardPaymentRequest] - For debit/credit card payments
/// - [BankTransferRequest] - For bank transfer payments
/// - [MobileMoneyRequest] - For mobile money payments
///
/// ## Properties
/// - [amount]: Transaction amount in kobo (smallest currency unit)
/// - [currency]: Transaction currency
/// - [email]: Customer's email (automatically sanitized)
/// - [reference]: Optional transaction reference
/// - [paymentMethod]: Type of payment method
/// - [metadata]: Optional custom metadata
/// - [callbackUrl]: Optional callback URL for web payments
///
/// ## Example
/// ```dart
/// // Create a custom payment request
/// class CustomPaymentRequest extends PaymentRequest {
///   CustomPaymentRequest({
///     required super.amount,
///     required super.currency,
///     required super.email,
///     required super.paymentMethod,
///   });
///
///   @override
///   Map<String, dynamic> getSpecificJson() => {};
/// }
/// ```
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
    required String email,
    this.reference,
    required this.paymentMethod,
    this.metadata,
    this.callbackUrl,
  }) : email = ValidationUtils.sanitizeString(email);

  /// Convert request to JSON for API call.
  ///
  /// Serializes the payment request into a JSON format suitable for Paystack API calls.
  /// This includes common fields and payment-method-specific data from subclasses.
  ///
  /// ## Returns
  /// A JSON map containing all payment request data.
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

  /// Method to be implemented by subclasses for payment-method-specific data.
  ///
  /// Each payment method subclass must implement this method to provide
  /// additional JSON fields specific to that payment type.
  ///
  /// ## Returns
  /// A JSON map with payment-method-specific data.
  Map<String, dynamic> getSpecificJson();

  /// Validate the request data.
  ///
  /// Performs comprehensive validation on the payment request including:
  /// - Amount validation (positive, within currency limits)
  /// - Email format validation
  /// - Reference format validation (if provided)
  /// - Callback URL validation (if provided)
  ///
  /// ## Throws
  /// - [ArgumentError] if any validation fails
  void validate() {
    // Validate amount
    if (!ValidationUtils.isValidAmount(amount, currency)) {
      throw ArgumentError(
        'Amount must be greater than 0 and not exceed the maximum limit for ${currency.name.toUpperCase()}',
      );
    }

    // Validate email
    if (email.isEmpty) {
      throw ArgumentError('Email address is required');
    }
    if (!ValidationUtils.isValidEmail(email)) {
      throw ArgumentError('Invalid email address format');
    }

    // Validate reference if provided
    if (reference != null && reference!.isEmpty) {
      throw ArgumentError('Reference cannot be empty if provided');
    }

    // Validate callback URL if provided
    if (callbackUrl != null && callbackUrl!.isNotEmpty) {
      try {
        Uri.parse(callbackUrl!);
      } catch (e) {
        throw ArgumentError('Invalid callback URL format');
      }
    }
  }
}
