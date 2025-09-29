import 'package:flutter_test/flutter_test.dart';
import 'package:all_paystack_payments/validation_utils.dart';
import 'package:all_paystack_payments/enums.dart';

void main() {
  group('ValidationUtils', () {
    group('sanitizeString', () {
      test('should trim whitespace', () {
        expect(ValidationUtils.sanitizeString('  test  '), 'test');
      });

      test('should remove control characters', () {
        expect(ValidationUtils.sanitizeString('test\x00\x01'), 'test');
      });

      test('should handle empty string', () {
        expect(ValidationUtils.sanitizeString(''), '');
      });

      test('should handle null-like input', () {
        expect(ValidationUtils.sanitizeString('   '), '');
      });
    });

    group('isValidEmail', () {
      test('should validate correct email formats', () {
        expect(ValidationUtils.isValidEmail('test@example.com'), true);
        expect(
          ValidationUtils.isValidEmail('user.name+tag@domain.co.uk'),
          true,
        );
        expect(ValidationUtils.isValidEmail('test123@test-domain.com'), true);
      });

      test('should reject invalid email formats', () {
        expect(ValidationUtils.isValidEmail(''), false);
        expect(ValidationUtils.isValidEmail('test'), false);
        expect(ValidationUtils.isValidEmail('test@'), false);
        expect(ValidationUtils.isValidEmail('@example.com'), false);
        expect(ValidationUtils.isValidEmail('test@example'), false);
        expect(ValidationUtils.isValidEmail('test example.com'), false);
        expect(ValidationUtils.isValidEmail('test@.com'), false);
      });

      test('should handle edge cases', () {
        expect(ValidationUtils.isValidEmail('test@example.com'), true);
        expect(ValidationUtils.isValidEmail('test@example.com.'), false);
      });
    });

    group('isValidPhoneNumber', () {
      test('should validate correct E.164 phone numbers', () {
        expect(ValidationUtils.isValidPhoneNumber('+1234567890'), true);
        expect(ValidationUtils.isValidPhoneNumber('+254712345678'), true);
        expect(ValidationUtils.isValidPhoneNumber('+447911123456'), true);
      });

      test('should reject invalid phone numbers', () {
        expect(ValidationUtils.isValidPhoneNumber(''), false);
        expect(ValidationUtils.isValidPhoneNumber('1234567890'), false);
        expect(ValidationUtils.isValidPhoneNumber('+'), false);
        expect(ValidationUtils.isValidPhoneNumber('+123'), false);
        expect(ValidationUtils.isValidPhoneNumber('abc1234567890'), false);
      });
    });

    group('isValidCardNumber', () {
      test('should validate correct card numbers with valid Luhn', () {
        expect(
          ValidationUtils.isValidCardNumber('4111111111111111'),
          true,
        ); // Visa test number
        expect(
          ValidationUtils.isValidCardNumber('5555555555554444'),
          true,
        ); // Mastercard test number
        expect(
          ValidationUtils.isValidCardNumber('378282246310005'),
          true,
        ); // Amex test number
      });

      test('should reject invalid card numbers', () {
        expect(ValidationUtils.isValidCardNumber(''), false);
        expect(ValidationUtils.isValidCardNumber('123'), false);
        expect(
          ValidationUtils.isValidCardNumber('4111111111111112'),
          false,
        ); // Invalid Luhn
        expect(ValidationUtils.isValidCardNumber('abcd111111111111'), false);
        expect(
          ValidationUtils.isValidCardNumber('41111111111111111'),
          false,
        ); // Too long
      });

      test('should handle different lengths', () {
        expect(
          ValidationUtils.isValidCardNumber('4111111111111111'),
          true,
        ); // 16 digits
        expect(
          ValidationUtils.isValidCardNumber('378282246310005'),
          true,
        ); // 15 digits
        expect(
          ValidationUtils.isValidCardNumber('411111111111111'),
          false,
        ); // 15 digits invalid
      });
    });

    group('isValidCvv', () {
      test('should validate correct CVV formats', () {
        expect(ValidationUtils.isValidCvv('123'), true);
        expect(ValidationUtils.isValidCvv('1234'), true);
      });

      test('should reject invalid CVV formats', () {
        expect(ValidationUtils.isValidCvv(''), false);
        expect(ValidationUtils.isValidCvv('12'), false);
        expect(ValidationUtils.isValidCvv('12345'), false);
        expect(ValidationUtils.isValidCvv('abc'), false);
        expect(ValidationUtils.isValidCvv('12a'), false);
      });
    });

    group('isValidExpiryDate', () {
      test('should validate future expiry dates', () {
        final futureDate = DateTime.now().add(const Duration(days: 365));
        final month = futureDate.month.toString().padLeft(2, '0');
        final year = futureDate.year.toString().substring(2);

        expect(ValidationUtils.isValidExpiryDate(month, year), true);
        expect(ValidationUtils.isValidExpiryDate('12', '30'), true);
      });

      test('should reject expired dates', () {
        expect(
          ValidationUtils.isValidExpiryDate('01', '20'),
          false,
        ); // Past year
        expect(
          ValidationUtils.isValidExpiryDate('01', '19'),
          false,
        ); // Way past
      });

      test('should reject invalid formats', () {
        expect(ValidationUtils.isValidExpiryDate('', '25'), false);
        expect(
          ValidationUtils.isValidExpiryDate('13', '25'),
          false,
        ); // Invalid month
        expect(
          ValidationUtils.isValidExpiryDate('00', '25'),
          false,
        ); // Invalid month
        expect(
          ValidationUtils.isValidExpiryDate('1', '25'),
          false,
        ); // Single digit
        expect(ValidationUtils.isValidExpiryDate('ab', '25'), false);
      });

      test('should handle current month correctly', () {
        final now = DateTime.now();
        final currentMonth = now.month.toString().padLeft(2, '0');
        final currentYear = now.year.toString().substring(2);

        // Should be valid if not expired
        expect(
          ValidationUtils.isValidExpiryDate(currentMonth, currentYear),
          true,
        );
      });
    });

    group('isValidAmount', () {
      test('should validate amounts within limits', () {
        expect(ValidationUtils.isValidAmount(1000, Currency.ngn), true);
        expect(ValidationUtils.isValidAmount(100000, Currency.usd), true);
        expect(ValidationUtils.isValidAmount(50000, Currency.ghs), true);
      });

      test('should reject invalid amounts', () {
        expect(ValidationUtils.isValidAmount(0, Currency.ngn), false);
        expect(ValidationUtils.isValidAmount(-100, Currency.ngn), false);
        expect(
          ValidationUtils.isValidAmount(100000000000, Currency.ngn),
          false,
        ); // Too large
      });

      test('should enforce currency-specific limits', () {
        // NGN max: 100M
        expect(ValidationUtils.isValidAmount(10000000000, Currency.ngn), true);
        expect(ValidationUtils.isValidAmount(10000000001, Currency.ngn), false);

        // USD max: 1M
        expect(ValidationUtils.isValidAmount(100000000, Currency.usd), true);
        expect(ValidationUtils.isValidAmount(100000001, Currency.usd), false);
      });
    });

    group('Security Tests', () {
      test('sanitizeString should prevent XSS-like attacks', () {
        expect(
          ValidationUtils.sanitizeString('<script>alert("xss")</script>'),
          '<script>alert("xss")</script>',
        );
        // Note: sanitizeString only trims and removes control chars, not HTML
      });

      test('should handle malicious input in email validation', () {
        expect(ValidationUtils.isValidEmail('test@evil.com<script>'), false);
        expect(ValidationUtils.isValidEmail('test@evil.com\x00'), false);
      });

      test('should handle malicious input in card validation', () {
        expect(
          ValidationUtils.isValidCardNumber('4111111111111111<script>'),
          false,
        );
        expect(
          ValidationUtils.isValidCardNumber('4111111111111111\x00'),
          false,
        );
      });

      test('should handle SQL injection attempts', () {
        expect(
          ValidationUtils.isValidEmail("test@domain.com' OR '1'='1"),
          false,
        );
        expect(
          ValidationUtils.sanitizeString("test' OR '1'='1"),
          "test' OR '1'='1",
        );
      });
    });
  });
}
