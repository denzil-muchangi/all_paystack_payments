import 'package:flutter_test/flutter_test.dart';
import 'package:all_paystack_payments/all_paystack_payments.dart';
import 'package:all_paystack_payments/webview_payment_handler.dart';

// Mock the webview payment handler factory to avoid web dependencies in tests
class MockWebViewPaymentHandler implements WebViewPaymentHandler {
  @override
  Future<PaymentResponse> processPayment(String checkoutUrl) async {
    return PaymentResponse(
      reference: 'mock_ref_123',
      status: PaymentStatus.success,
      amount: 1000,
      currency: Currency.ngn,
      paymentMethod: PaymentMethod.card,
    );
  }
}

class MockWebViewPaymentHandlerFactory {
  static WebViewPaymentHandler create() => MockWebViewPaymentHandler();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AllPaystackPayments API', () {
    test('initializeCardPayment creates valid request', () {
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

      expect(request.amount, 1000);
      expect(request.currency, Currency.ngn);
      expect(request.email, 'test@example.com');
      expect(request.cardNumber, '4111111111111111');
      expect(request.expiryMonth, '12');
      expect(request.expiryYear, '25');
      expect(request.cvv, '123');
      expect(request.cardHolderName, 'John Doe');
    });

    test('initializeBankTransfer creates valid request', () {
      final request = BankTransferRequest(
        amount: 1000,
        currency: Currency.ngn,
        email: 'test@example.com',
      );

      expect(request.amount, 1000);
      expect(request.currency, Currency.ngn);
      expect(request.email, 'test@example.com');
      expect(request.transferType, BankTransferType.account);
    });

    test('initializeMobileMoney creates valid request', () {
      final request = MobileMoneyRequest(
        amount: 1000,
        currency: Currency.ngn,
        email: 'test@example.com',
        provider: MobileMoneyProvider.mpesa,
        phoneNumber: '+254712345678',
      );

      expect(request.amount, 1000);
      expect(request.currency, Currency.ngn);
      expect(request.email, 'test@example.com');
      expect(request.provider, MobileMoneyProvider.mpesa);
      expect(request.phoneNumber, '+254712345678');
    });

    test('initializeCardPayment with all parameters', () {
      final result = AllPaystackPayments.initializeCardPayment(
        amount: 1000,
        email: 'test@example.com',
        cardNumber: '4111111111111111',
        expiryMonth: '12',
        expiryYear: '25',
        cvv: '123',
        cardHolderName: 'John Doe',
        reference: 'custom_ref',
        pin: '1234',
        metadata: {'key': 'value'},
        callbackUrl: 'https://example.com/callback',
        currency: Currency.usd,
      );

      expect(result, isA<Future<PaymentResponse>>());
    });

    test('initializeBankTransfer with all parameters', () {
      final result = AllPaystackPayments.initializeBankTransfer(
        amount: 1000,
        email: 'test@example.com',
        reference: 'custom_ref',
        metadata: {'key': 'value'},
        callbackUrl: 'https://example.com/callback',
        currency: Currency.ghs,
      );

      expect(result, isA<Future<PaymentResponse>>());
    });

    test('initializeMobileMoney with all parameters', () {
      final result = AllPaystackPayments.initializeMobileMoney(
        amount: 1000,
        email: 'test@example.com',
        provider: MobileMoneyProvider.airtel,
        phoneNumber: '+233501234567',
        reference: 'custom_ref',
        metadata: {'key': 'value'},
        callbackUrl: 'https://example.com/callback',
        currency: Currency.zar,
      );

      expect(result, isA<Future<PaymentResponse>>());
    });

    test('verifyPayment returns Future<PaymentResponse>', () {
      final result = AllPaystackPayments.verifyPayment('ref123');
      expect(result, isA<Future<PaymentResponse>>());
    });

    test('getPaymentStatus returns Future<PaymentResponse>', () {
      final result = AllPaystackPayments.getPaymentStatus('ref123');
      expect(result, isA<Future<PaymentResponse>>());
    });

    test('cancelPayment returns Future<bool>', () {
      final result = AllPaystackPayments.cancelPayment('ref123');
      expect(result, isA<Future<bool>>());
    });

    test('getPlatformVersion returns Future<String?>', () {
      final result = AllPaystackPayments.getPlatformVersion();
      expect(result, isA<Future<String?>>());
    });

    group('Validation and Error Handling', () {
      test('initializeCardPayment throws ArgumentError for invalid amount', () {
        expect(
          () => AllPaystackPayments.initializeCardPayment(
            amount: 0,
            email: 'test@example.com',
            cardNumber: '4111111111111111',
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName: 'John Doe',
          ),
          throwsArgumentError,
        );
      });

      test('initializeCardPayment throws ArgumentError for invalid email', () {
        expect(
          () => AllPaystackPayments.initializeCardPayment(
            amount: 1000,
            email: 'invalid-email',
            cardNumber: '4111111111111111',
            expiryMonth: '12',
            expiryYear: '25',
            cvv: '123',
            cardHolderName: 'John Doe',
          ),
          throwsArgumentError,
        );
      });

      test(
        'initializeCardPayment throws ArgumentError for invalid card number',
        () {
          expect(
            () => AllPaystackPayments.initializeCardPayment(
              amount: 1000,
              email: 'test@example.com',
              cardNumber: '4111111111111112', // Invalid Luhn
              expiryMonth: '12',
              expiryYear: '25',
              cvv: '123',
              cardHolderName: 'John Doe',
            ),
            throwsArgumentError,
          );
        },
      );

      test('initializeCardPayment throws ArgumentError for expired card', () {
        expect(
          () => AllPaystackPayments.initializeCardPayment(
            amount: 1000,
            email: 'test@example.com',
            cardNumber: '4111111111111111',
            expiryMonth: '01',
            expiryYear: '20',
            cvv: '123',
            cardHolderName: 'John Doe',
          ),
          throwsArgumentError,
        );
      });

      test(
        'initializeMobileMoney throws ArgumentError for invalid phone number',
        () {
          expect(
            () => AllPaystackPayments.initializeMobileMoney(
              amount: 1000,
              email: 'test@example.com',
              provider: MobileMoneyProvider.mpesa,
              phoneNumber: '+1234567890', // Not Kenyan
              currency: Currency.kes,
            ),
            throwsArgumentError,
          );
        },
      );

      test(
        'initializeMobileMoney accepts valid phone numbers for different providers',
        () {
          // M-Pesa (Kenya)
          expect(
            () => AllPaystackPayments.initializeMobileMoney(
              amount: 1000,
              email: 'test@example.com',
              provider: MobileMoneyProvider.mpesa,
              phoneNumber: '+254712345678',
              currency: Currency.kes,
            ),
            returnsNormally,
          );

          // Airtel (Ghana)
          expect(
            () => AllPaystackPayments.initializeMobileMoney(
              amount: 1000,
              email: 'test@example.com',
              provider: MobileMoneyProvider.airtel,
              phoneNumber: '+233501234567',
              currency: Currency.ghs,
            ),
            returnsNormally,
          );
        },
      );
    });

    group('Currency Support', () {
      test('supports all currency enums', () {
        final currencies = Currency.values;
        expect(currencies, contains(Currency.ngn));
        expect(currencies, contains(Currency.usd));
        expect(currencies, contains(Currency.ghs));
        expect(currencies, contains(Currency.zar));
        expect(currencies, contains(Currency.kes));
      });

      test('initializeCardPayment accepts different currencies', () {
        for (final currency in Currency.values) {
          expect(
            () => AllPaystackPayments.initializeCardPayment(
              amount: 1000,
              email: 'test@example.com',
              cardNumber: '4111111111111111',
              expiryMonth: '12',
              expiryYear: '25',
              cvv: '123',
              cardHolderName: 'John Doe',
              currency: currency,
            ),
            returnsNormally,
          );
        }
      });
    });

    group('Mobile Money Providers', () {
      test('supports all mobile money providers', () {
        final providers = MobileMoneyProvider.values;
        expect(providers, contains(MobileMoneyProvider.mpesa));
        expect(providers, contains(MobileMoneyProvider.airtel));
        expect(providers, contains(MobileMoneyProvider.vodafone));
        expect(providers, contains(MobileMoneyProvider.tigo));
      });

      test(
        'initializeMobileMoney accepts all providers with valid phone numbers',
        () {
          const testCases = [
            (MobileMoneyProvider.mpesa, '+254712345678', Currency.kes),
            (MobileMoneyProvider.airtel, '+233501234567', Currency.ghs),
            (MobileMoneyProvider.vodafone, '+233501234567', Currency.ghs),
            (MobileMoneyProvider.tigo, '+233501234567', Currency.ghs),
          ];

          for (final (provider, phone, currency) in testCases) {
            expect(
              () => AllPaystackPayments.initializeMobileMoney(
                amount: 1000,
                email: 'test@example.com',
                provider: provider,
                phoneNumber: phone,
                currency: currency,
              ),
              returnsNormally,
            );
          }
        },
      );
    });

    group('Payment Methods', () {
      test('supports all payment method types', () {
        final methods = PaymentMethod.values;
        expect(methods, contains(PaymentMethod.card));
        expect(methods, contains(PaymentMethod.bankTransfer));
        expect(methods, contains(PaymentMethod.mobileMoney));
      });
    });

    group('Payment Statuses', () {
      test('supports all payment status types', () {
        final statuses = PaymentStatus.values;
        expect(statuses, contains(PaymentStatus.pending));
        expect(statuses, contains(PaymentStatus.success));
        expect(statuses, contains(PaymentStatus.failed));
        expect(statuses, contains(PaymentStatus.cancelled));
      });
    });
  });
}
