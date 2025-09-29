import 'package:flutter_test/flutter_test.dart';
import 'package:all_paystack_payments/all_paystack_payments.dart';
import 'package:all_paystack_payments/validation_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Tests', () {
    test('CardPaymentRequest validation performance', () {
      final stopwatch = Stopwatch()..start();

      // Create and validate 1000 requests
      for (int i = 0; i < 1000; i++) {
        final request = CardPaymentRequest(
          amount: 1000 + i,
          currency: Currency.ngn,
          email: 'test$i@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe $i',
        );
        request.validate();
      }

      stopwatch.stop();
      final timePerValidation = stopwatch.elapsedMicroseconds / 1000;

      print(
        'CardPaymentRequest validation: ${timePerValidation.toStringAsFixed(2)} µs per validation',
      );
      expect(
        timePerValidation,
        lessThan(1000),
      ); // Should be less than 1ms per validation
    });

    test('MobileMoneyRequest validation performance', () {
      final stopwatch = Stopwatch()..start();

      // Create and validate 1000 requests
      for (int i = 0; i < 1000; i++) {
        final request = MobileMoneyRequest(
          amount: 1000 + i,
          currency: Currency.ngn,
          email: 'test$i@example.com',
          provider: MobileMoneyProvider.airtel,
          phoneNumber: '+254712345678',
        );
        request.validate();
      }

      stopwatch.stop();
      final timePerValidation = stopwatch.elapsedMicroseconds / 1000;

      print(
        'MobileMoneyRequest validation: ${timePerValidation.toStringAsFixed(2)} µs per validation',
      );
      expect(
        timePerValidation,
        lessThan(1000),
      ); // Should be less than 1ms per validation
    });

    test('BankTransferRequest validation performance', () {
      final stopwatch = Stopwatch()..start();

      // Create and validate 1000 requests
      for (int i = 0; i < 1000; i++) {
        final request = BankTransferRequest(
          amount: 1000 + i,
          currency: Currency.ngn,
          email: 'test$i@example.com',
        );
        request.validate();
      }

      stopwatch.stop();
      final timePerValidation = stopwatch.elapsedMicroseconds / 1000;

      print(
        'BankTransferRequest validation: ${timePerValidation.toStringAsFixed(2)} µs per validation',
      );
      expect(
        timePerValidation,
        lessThan(500),
      ); // Should be less than 0.5ms per validation
    });

    test('PaymentResponse creation performance', () {
      final stopwatch = Stopwatch()..start();

      // Create 1000 responses
      for (int i = 0; i < 1000; i++) {
        PaymentResponse(
          reference: 'ref_$i',
          status: PaymentStatus.success,
          amount: 1000 + i,
          currency: Currency.ngn,
          paymentMethod: PaymentMethod.card,
        );
      }

      stopwatch.stop();
      final timePerCreation = stopwatch.elapsedMicroseconds / 1000;

      print(
        'PaymentResponse creation: ${timePerCreation.toStringAsFixed(2)} µs per creation',
      );
      expect(timePerCreation, lessThan(100)); // Should be very fast
    });

    test('JSON serialization performance', () {
      final request = CardPaymentRequest(
        amount: 1000,
        currency: Currency.ngn,
        email: 'test@example.com',
        cardNumber: '4111111111111111',
        expiryMonth: '12',
        expiryYear: '25',
        cvv: '123',
        cardHolderName: 'John Doe',
        metadata: {
          'key': 'value',
          'number': 123,
          'list': [1, 2, 3],
        },
      );

      final stopwatch = Stopwatch()..start();

      // Serialize 1000 times
      for (int i = 0; i < 1000; i++) {
        request.toJson();
      }

      stopwatch.stop();
      final timePerCycle = stopwatch.elapsedMicroseconds / 1000;

      print(
        'JSON serialization cycle: ${timePerCycle.toStringAsFixed(2)} µs per cycle',
      );
      expect(timePerCycle, lessThan(2000)); // Should be reasonable
    });

    test('ValidationUtils performance', () {
      final testEmails = [
        'test@example.com',
        'user.name+tag@domain.co.uk',
        'test123@test-domain.com',
        'invalid-email',
        'test@',
        '@example.com',
      ];

      final testCards = [
        '4111111111111111',
        '5555555555554444',
        '378282246310005',
        '4111111111111112', // Invalid
        'abcd111111111111', // Invalid
      ];

      final stopwatch = Stopwatch()..start();

      // Test email validation
      for (int i = 0; i < 1000; i++) {
        for (final email in testEmails) {
          ValidationUtils.isValidEmail(email);
        }
      }

      // Test card validation
      for (int i = 0; i < 1000; i++) {
        for (final card in testCards) {
          ValidationUtils.isValidCardNumber(card);
        }
      }

      stopwatch.stop();
      final totalTime = stopwatch.elapsedMilliseconds;
      final operations = (testEmails.length + testCards.length) * 1000;
      final timePerOperation = totalTime * 1000 / operations; // microseconds

      print(
        'ValidationUtils: ${timePerOperation.toStringAsFixed(2)} µs per operation',
      );
      expect(timePerOperation, lessThan(50)); // Should be very fast
    });

    test('Memory efficiency - large metadata handling', () {
      final largeMetadata = {
        'large_data': List.generate(1000, (i) => 'item_$i'),
        'nested': {
          'deeply': {
            'nested': {
              'data': List.generate(100, (i) => {'key': 'value_$i'}),
            },
          },
        },
      };

      final stopwatch = Stopwatch()..start();

      // Create 100 requests with large metadata
      for (int i = 0; i < 100; i++) {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
          metadata: largeMetadata,
        );
        request.validate();
        request.toJson();
      }

      stopwatch.stop();
      final timePerOperation = stopwatch.elapsedMicroseconds / 100;

      print(
        'Large metadata handling: ${timePerOperation.toStringAsFixed(2)} µs per operation',
      );
      expect(
        timePerOperation,
        lessThan(5000),
      ); // Should handle large data reasonably
    });
  });
}
