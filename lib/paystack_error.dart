/// Custom exception class for Paystack payment errors
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

  /// Factory method to create error from API response
  factory PaystackError.fromApiResponse(Map<String, dynamic> response) {
    return PaystackError(
      message: response['message'] as String? ?? 'Unknown error',
      code: response['code'] as String?,
      details: response,
    );
  }
}
