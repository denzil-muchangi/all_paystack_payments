/// Custom exception class for Paystack payment errors.
///
/// This class represents errors that occur during Paystack API interactions.
/// It provides structured error information including error codes and additional details.
///
/// ## Properties
/// - [message]: Human-readable error description
/// - [code]: Optional error code from Paystack API
/// - [details]: Optional additional error details from the API response
///
/// ## Example
/// ```dart
/// try {
///   final response = await AllPaystackPayments.initializeCardPayment(...);
/// } on PaystackError catch (e) {
///   print('Paystack Error: ${e.message}');
///   if (e.code != null) {
///     print('Error Code: ${e.code}');
///   }
///   // Handle specific error types
/// }
/// ```
class PaystackError implements Exception {
  /// Error message
  final String message;

  /// Error code from Paystack API
  final String? code;

  /// Additional error details
  final Map<String, dynamic>? details;

  PaystackError({required this.message, this.code, this.details});

  @override
  String toString() {
    return 'PaystackError: $message${code != null ? ' (Code: $code)' : ''}';
  }

  /// Factory method to create error from API response.
  ///
  /// Creates a [PaystackError] instance from raw Paystack API error response data.
  /// This method extracts error message, code, and details from the API response.
  ///
  /// ## Parameters
  /// - [response]: Raw error response map from Paystack API
  ///
  /// ## Returns
  /// A new [PaystackError] instance with parsed error data.
  factory PaystackError.fromApiResponse(Map<String, dynamic> response) {
    return PaystackError(
      message: response['message'] as String? ?? 'Unknown error',
      code: response['code'] as String?,
      details: response,
    );
  }
}
