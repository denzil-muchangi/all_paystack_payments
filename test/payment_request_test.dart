import 'package:flutter_test/flutter_test.dart';
import 'package:all_paystack_payments/all_paystack_payments.dart';

void main() {
  group('PaymentRequest', () {
    group('Base PaymentRequest Validation', () {
      test('should validate valid request', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        );

        expect(() => request.validate(), returnsNormally);
      });

      test('should throw on invalid amount', () {
        final request = CardPaymentRequest(
          amount: 0,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should throw on empty email', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: '',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should throw on invalid email', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'invalid-email',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should throw on empty reference', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          reference: '',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should throw on invalid callback URL', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          callbackUrl: 'http://[::1', // Invalid IPv6
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should accept valid callback URL', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          callbackUrl: 'https://example.com/callback',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        );

        expect(() => request.validate(), returnsNormally);
      });
    });

    group('CardPaymentRequest', () {
      test('should create valid card payment request', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        );

        expect(request.cardNumber, '4111111111111111');
        expect(request.expiryMonth, '12');
        expect(request.expiryYear, '25');
        expect(request.cvv, '123');
        expect(request.cardHolderName, 'John Doe');
        expect(request.pin, null);
      });

      test('should sanitize card fields', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: ' 4111 1111 1111 1111 ',
          expiryMonth: ' 12 ',
          expiryYear: ' 25 ',
          cvv: ' 123 ',
          cardHolderName: ' John Doe ',
        );

        expect(request.cardNumber, '4111111111111111');
        expect(request.expiryMonth, '12');
        expect(request.expiryYear, '25');
        expect(request.cvv, '123');
        expect(request.cardHolderName, 'John Doe');
      });

      test('should generate correct JSON', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
          pin: '1234',
        );

        final json = request.toJson();
        expect(json['card'], {
          'number': '4111111111111111',
          'expiry_month': '12',
          'expiry_year': '25',
          'cvv': '123',
          'holder_name': 'John Doe',
          'pin': '1234',
        });
      });

      test('should validate valid card request', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        );

        expect(() => request.validate(), returnsNormally);
      });

      test('should throw on empty card number', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: '',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should throw on invalid card number', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: '4111111111111112', // Invalid Luhn
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should throw on invalid expiry date', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '13',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should throw on expired card', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '01',
          expiryYear: '20',
          cvv: '123',
          cardHolderName: 'John Doe',
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should throw on invalid CVV', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '12',
          cardHolderName: 'John Doe',
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should throw on empty card holder name', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: '',
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should throw on short card holder name', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'A',
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should throw on invalid PIN', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
          pin: '123',
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should accept valid PIN', () {
        final request = CardPaymentRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
          pin: '1234',
        );

        expect(() => request.validate(), returnsNormally);
      });
    });

    group('BankTransferRequest', () {
      test('should create valid bank transfer request', () {
        final request = BankTransferRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
        );

        expect(request.accountNumber, null);
        expect(request.bankCode, null);
        expect(request.bankName, null);
        expect(request.transferType, BankTransferType.account);
      });

      test('should sanitize bank fields', () {
        final request = BankTransferRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          accountNumber: ' 1234567890 ',
          bankCode: ' 001 ',
          bankName: ' Test Bank ',
        );

        expect(request.accountNumber, '1234567890');
        expect(request.bankCode, '001');
        expect(request.bankName, 'Test Bank');
      });

      test('should generate correct JSON', () {
        final request = BankTransferRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          accountNumber: '1234567890',
          bankCode: '001',
          bankName: 'Test Bank',
          transferType: BankTransferType.otp,
        );

        final json = request.toJson();
        expect(json['bank_transfer'], {
          'account_number': '1234567890',
          'bank_code': '001',
          'bank_name': 'Test Bank',
          'transfer_type': 'otp',
        });
      });

      test('should validate valid bank transfer request', () {
        final request = BankTransferRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
        );

        expect(() => request.validate(), returnsNormally);
      });

      test('should throw on invalid account number', () {
        final request = BankTransferRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          accountNumber: '123456789', // Too short
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should throw on invalid bank code', () {
        final request = BankTransferRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          bankCode: '12', // Too short
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should throw on empty bank name', () {
        final request = BankTransferRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          bankName: '',
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should accept valid account details', () {
        final request = BankTransferRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          accountNumber: '1234567890',
          bankCode: '001',
          bankName: 'Test Bank',
        );

        expect(() => request.validate(), returnsNormally);
      });
    });

    group('MobileMoneyRequest', () {
      test('should create valid mobile money request', () {
        final request = MobileMoneyRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          provider: MobileMoneyProvider.mpesa,
          phoneNumber: '+254712345678',
        );

        expect(request.provider, MobileMoneyProvider.mpesa);
        expect(request.phoneNumber, '+254712345678');
      });

      test('should sanitize phone number', () {
        final request = MobileMoneyRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          provider: MobileMoneyProvider.mpesa,
          phoneNumber: ' +254712345678 ',
        );

        expect(request.phoneNumber, '+254712345678');
      });

      test('should generate correct JSON', () {
        final request = MobileMoneyRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          provider: MobileMoneyProvider.mpesa,
          phoneNumber: '+254712345678',
        );

        final json = request.toJson();
        expect(json['mobile_money'], {
          'provider': 'mpesa',
          'phone_number': '+254712345678',
        });
      });

      test('should validate valid mobile money request', () {
        final request = MobileMoneyRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          provider: MobileMoneyProvider.mpesa,
          phoneNumber: '+254712345678',
        );

        expect(() => request.validate(), returnsNormally);
      });

      test('should throw on empty phone number', () {
        final request = MobileMoneyRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          provider: MobileMoneyProvider.mpesa,
          phoneNumber: '',
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should throw on invalid phone number', () {
        final request = MobileMoneyRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          provider: MobileMoneyProvider.mpesa,
          phoneNumber: '0712345678', // Missing +
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should throw on invalid M-Pesa number', () {
        final request = MobileMoneyRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          provider: MobileMoneyProvider.mpesa,
          phoneNumber: '+1234567890', // Not Kenyan
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should accept valid M-Pesa number', () {
        final request = MobileMoneyRequest(
          amount: 1000,
          currency: Currency.ngn,
          email: 'test@example.com',
          provider: MobileMoneyProvider.mpesa,
          phoneNumber: '+254712345678',
        );

        expect(() => request.validate(), returnsNormally);
      });

      test('should throw on invalid Airtel number', () {
        final request = MobileMoneyRequest(
          amount: 1000,
          currency: Currency.ghs,
          email: 'test@example.com',
          provider: MobileMoneyProvider.airtel,
          phoneNumber: '+1234567890', // Not Ghanaian
        );

        expect(() => request.validate(), throwsArgumentError);
      });

      test('should accept valid Airtel number', () {
        final request = MobileMoneyRequest(
          amount: 1000,
          currency: Currency.ghs,
          email: 'test@example.com',
          provider: MobileMoneyProvider.airtel,
          phoneNumber: '+233501234567',
        );

        expect(() => request.validate(), returnsNormally);
      });
    });
  });
}
