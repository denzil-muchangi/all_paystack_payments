import 'package:flutter_test/flutter_test.dart';
import 'package:all_paystack_payments/all_paystack_payments.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Edge Cases and Boundary Testing', () {
    group('Amount Boundary Testing', () {
      test('accepts minimum valid amount (1 kobo)', () {
        expect(
          () => CardPaymentRequest(
            amount: 1,
            currency: Currency.ngn,
            email: 'test@example.com',
            cardNumber: '4111111111111111',
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName: 'John Doe',
          ).validate(),
          returnsNormally,
        );
      });

      test('accepts maximum valid amount for NGN (100M kobo)', () {
        expect(
          () => CardPaymentRequest(
            amount: 10000000000, // 100M NGN in kobo
            currency: Currency.ngn,
            email: 'test@example.com',
            cardNumber: '4111111111111111',
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName: 'John Doe',
          ).validate(),
          returnsNormally,
        );
      });

      test('rejects amount over maximum for NGN', () {
        expect(
          () => CardPaymentRequest(
            amount: 10000000001, // Over 100M NGN
            currency: Currency.ngn,
            email: 'test@example.com',
            cardNumber: '4111111111111111',
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName: 'John Doe',
          ).validate(),
          throwsArgumentError,
        );
      });
    });

    group('Card Number Edge Cases', () {
      test('accepts minimum valid card number length (13 digits)', () {
        expect(
          () => CardPaymentRequest(
            amount: 1000,
            currency: Currency.ngn,
            email: 'test@example.com',
            cardNumber: '4111111111111', // 13 digits
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName: 'John Doe',
          ).validate(),
          returnsNormally,
        );
      });

      test('accepts maximum valid card number length (19 digits)', () {
        expect(
          () => CardPaymentRequest(
            amount: 1000,
            currency: Currency.ngn,
            email: 'test@example.com',
            cardNumber: '4111111111111111111', // 19 digits
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName: 'John Doe',
          ).validate(),
          returnsNormally,
        );
      });

      test('rejects card number too short (12 digits)', () {
        expect(
          () => CardPaymentRequest(
            amount: 1000,
            currency: Currency.ngn,
            email: 'test@example.com',
            cardNumber: '411111111111', // 12 digits
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName: 'John Doe',
          ).validate(),
          throwsArgumentError,
        );
      });
    });

    group('Card Holder Name Edge Cases', () {
      test('accepts minimum valid name length (2 characters)', () {
        expect(
          () => CardPaymentRequest(
            amount: 1000,
            currency: Currency.ngn,
            email: 'test@example.com',
            cardNumber: '4111111111111111',
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName: 'Jo', // 2 characters
          ).validate(),
          returnsNormally,
        );
      });

      test('accepts name with special characters', () {
        expect(
          () => CardPaymentRequest(
            amount: 1000,
            currency: Currency.ngn,
            email: 'test@example.com',
            cardNumber: '4111111111111111',
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName:
                'José María O\'Connor-Smith', // Accents, apostrophe, hyphen
          ).validate(),
          returnsNormally,
        );
      });

      test('rejects name too short (1 character)', () {
        expect(
          () => CardPaymentRequest(
            amount: 1000,
            currency: Currency.ngn,
            email: 'test@example.com',
            cardNumber: '4111111111111111',
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName: 'J', // 1 character
          ).validate(),
          throwsArgumentError,
        );
      });
    });

    group('Email Edge Cases', () {
      test('accepts email with subdomain', () {
        expect(
          () => CardPaymentRequest(
            amount: 1000,
            currency: Currency.ngn,
            email: 'test@sub.domain.com',
            cardNumber: '4111111111111111',
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName: 'John Doe',
          ).validate(),
          returnsNormally,
        );
      });

      test('accepts email with plus addressing', () {
        expect(
          () => CardPaymentRequest(
            amount: 1000,
            currency: Currency.ngn,
            email: 'test+tag@example.com',
            cardNumber: '4111111111111111',
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName: 'John Doe',
          ).validate(),
          returnsNormally,
        );
      });

      test('rejects email without @ symbol', () {
        expect(
          () => CardPaymentRequest(
            amount: 1000,
            currency: Currency.ngn,
            email: 'invalid-email',
            cardNumber: '4111111111111111',
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName: 'John Doe',
          ).validate(),
          throwsArgumentError,
        );
      });
    });

    group('Phone Number Edge Cases', () {
      test('accepts phone number with minimum length', () {
        expect(
          () => MobileMoneyRequest(
            amount: 1000,
            currency: Currency.ngn,
            email: 'test@example.com',
            provider: MobileMoneyProvider.airtel,
            phoneNumber: '+1234567890', // 10 digits after +
          ).validate(),
          returnsNormally,
        );
      });

      test('rejects phone number without + prefix', () {
        expect(
          () => MobileMoneyRequest(
            amount: 1000,
            currency: Currency.ngn,
            email: 'test@example.com',
            provider: MobileMoneyProvider.airtel,
            phoneNumber: '1234567890', // Missing +
          ).validate(),
          throwsArgumentError,
        );
      });
    });

    group('Reference Edge Cases', () {
      test('accepts reference with special characters', () {
        expect(
          () => CardPaymentRequest(
            amount: 1000,
            currency: Currency.ngn,
            email: 'test@example.com',
            reference: 'ref_123-456.789',
            cardNumber: '4111111111111111',
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName: 'John Doe',
          ).validate(),
          returnsNormally,
        );
      });

      test('rejects empty reference', () {
        expect(
          () => CardPaymentRequest(
            amount: 1000,
            currency: Currency.ngn,
            email: 'test@example.com',
            reference: '', // Empty
            cardNumber: '4111111111111111',
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName: 'John Doe',
          ).validate(),
          throwsArgumentError,
        );
      });
    });
  });
}
