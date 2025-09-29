import 'package:flutter_test/flutter_test.dart';
import 'package:all_paystack_payments/all_paystack_payments.dart';

void main() {
  group('PaystackError', () {
    test('should create error with message', () {
      final error = PaystackError(message: 'Test error');

      expect(error.message, 'Test error');
      expect(error.code, null);
      expect(error.details, null);
    });

    test('should create error with all fields', () {
      final details = <String, dynamic>{'field': 'value'};
      final error = PaystackError(
        message: 'Test error',
        code: 'ERROR_CODE',
        details: details,
      );

      expect(error.message, 'Test error');
      expect(error.code, 'ERROR_CODE');
      expect(error.details, details);
    });

    test('should create from API response', () {
      final apiResponse = <String, dynamic>{
        'message': 'API error message',
        'code': 'API_ERROR',
        'extra_field': 'extra_value',
      };

      final error = PaystackError.fromApiResponse(apiResponse);

      expect(error.message, 'API error message');
      expect(error.code, 'API_ERROR');
      expect(error.details, apiResponse);
    });

    test('should handle missing fields in API response', () {
      final apiResponse = <String, dynamic>{};

      final error = PaystackError.fromApiResponse(apiResponse);

      expect(error.message, 'Unknown error');
      expect(error.code, null);
      expect(error.details, apiResponse);
    });

    test('should handle null values in API response', () {
      final apiResponse = <String, dynamic>{'message': null, 'code': null};

      final error = PaystackError.fromApiResponse(apiResponse);

      expect(error.message, 'Unknown error');
      expect(error.code, null);
      expect(error.details, apiResponse);
    });

    test('toString should include message and code', () {
      final error = PaystackError(message: 'Test error', code: 'ERROR_CODE');

      expect(error.toString(), 'PaystackError: Test error (Code: ERROR_CODE)');
    });

    test('toString should handle missing code', () {
      final error = PaystackError(message: 'Test error');

      expect(error.toString(), 'PaystackError: Test error');
    });
  });
}
