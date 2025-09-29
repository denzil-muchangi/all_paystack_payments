import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:all_paystack_payments/all_paystack_payments_method_channel.dart';
import 'package:all_paystack_payments/all_paystack_payments.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAllPaystackPayments platform =
      MethodChannelAllPaystackPayments();
  const MethodChannel channel = MethodChannel('all_paystack_payments');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'initialize':
              return {'status': 'success'};
            case 'initializePayment':
              return {
                'reference': 'test_ref_123',
                'status': 'success',
                'amount': 1000,
                'currency': 'NGN',
                'payment_method': 'card',
              };
            case 'verifyPayment':
              return {
                'reference': methodCall.arguments['reference'],
                'status': 'success',
                'amount': 1000,
                'currency': 'NGN',
                'payment_method': 'card',
              };
            case 'getPaymentStatus':
              return {
                'reference': methodCall.arguments['reference'],
                'status': 'pending',
                'amount': 1000,
                'currency': 'NGN',
                'payment_method': 'card',
              };
            case 'cancelPayment':
              return true;
            case 'getPlatformVersion':
              return '42';
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('MethodChannelAllPaystackPayments', () {
    test('initialize calls platform correctly', () async {
      await platform.initialize('test_key');
      // Test passes if no exception is thrown
    });

    test('initializePayment calls platform and returns response', () async {
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

      final response = await platform.initializePayment(request);

      expect(response.reference, 'test_ref_123');
      expect(response.status, PaymentStatus.success);
      expect(response.amount, 1000);
      expect(response.currency, Currency.ngn);
      expect(response.paymentMethod, PaymentMethod.card);
    });

    test('verifyPayment calls platform and returns response', () async {
      final response = await platform.verifyPayment('test_ref');

      expect(response.reference, 'test_ref');
      expect(response.status, PaymentStatus.success);
    });

    test('getPaymentStatus calls platform and returns response', () async {
      final response = await platform.getPaymentStatus('test_ref');

      expect(response.reference, 'test_ref');
      expect(response.status, PaymentStatus.pending);
    });

    test('cancelPayment calls platform and returns result', () async {
      final result = await platform.cancelPayment('test_ref');

      expect(result, true);
    });

    test('getPlatformVersion calls platform and returns version', () async {
      final version = await platform.getPlatformVersion();

      expect(version, '42');
    });
  });

  group('Error Handling', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'initialize':
                throw PlatformException(
                  code: 'INIT_ERROR',
                  message: 'Init failed',
                );
              case 'initializePayment':
                return {'status': 'failed', 'message': 'Payment failed'};
              case 'verifyPayment':
                throw PlatformException(
                  code: 'VERIFY_ERROR',
                  message: 'Verify failed',
                );
              case 'getPaymentStatus':
                return null; // Null response
              case 'cancelPayment':
                throw PlatformException(
                  code: 'CANCEL_ERROR',
                  message: 'Cancel failed',
                );
              default:
                return '42';
            }
          });
    });

    test('initialize throws PaystackError on platform exception', () async {
      expect(
        () => platform.initialize('test_key'),
        throwsA(isA<PaystackError>()),
      );
    });

    test('initializePayment throws PaystackError on failed response', () async {
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

      expect(
        () => platform.initializePayment(request),
        throwsA(isA<PaystackError>()),
      );
    });

    test('verifyPayment throws PaystackError on platform exception', () async {
      expect(
        () => platform.verifyPayment('test_ref'),
        throwsA(isA<PaystackError>()),
      );
    });

    test('getPaymentStatus throws PaystackError on null response', () async {
      expect(
        () => platform.getPaymentStatus('test_ref'),
        throwsA(isA<PaystackError>()),
      );
    });

    test('cancelPayment throws PaystackError on platform exception', () async {
      expect(
        () => platform.cancelPayment('test_ref'),
        throwsA(isA<PaystackError>()),
      );
    });
  });
}
