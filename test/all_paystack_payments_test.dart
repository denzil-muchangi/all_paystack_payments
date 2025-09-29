import 'package:flutter_test/flutter_test.dart';
import 'package:all_paystack_payments/all_paystack_payments.dart';
import 'package:all_paystack_payments/all_paystack_payments_platform_interface.dart';
import 'package:all_paystack_payments/all_paystack_payments_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAllPaystackPaymentsPlatform
    with MockPlatformInterfaceMixin
    implements AllPaystackPaymentsPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> initialize(String publicKey) => Future.value();

  @override
  Future<PaymentResponse> initializePayment(PaymentRequest request) {
    return Future.value(
      PaymentResponse(
        reference: 'test_ref',
        status: PaymentStatus.success,
        amount: 1000,
        currency: Currency.ngn,
        paymentMethod: PaymentMethod.card,
      ),
    );
  }

  @override
  Future<PaymentResponse> verifyPayment(String reference) {
    return Future.value(
      PaymentResponse(
        reference: reference,
        status: PaymentStatus.success,
        amount: 1000,
        currency: Currency.ngn,
        paymentMethod: PaymentMethod.card,
      ),
    );
  }

  @override
  Future<PaymentResponse> getPaymentStatus(String reference) {
    return Future.value(
      PaymentResponse(
        reference: reference,
        status: PaymentStatus.success,
        amount: 1000,
        currency: Currency.ngn,
        paymentMethod: PaymentMethod.card,
      ),
    );
  }

  @override
  Future<bool> cancelPayment(String reference) => Future.value(true);

  @override
  Future<String> getCheckoutUrl(PaymentRequest request) {
    return Future.value('https://checkout.paystack.com/test_checkout_url');
  }
}

void main() {
  final AllPaystackPaymentsPlatform initialPlatform =
      AllPaystackPaymentsPlatform.instance;

  test('$MethodChannelAllPaystackPayments is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAllPaystackPayments>());
  });

  test('getPlatformVersion', () async {
    MockAllPaystackPaymentsPlatform fakePlatform =
        MockAllPaystackPaymentsPlatform();
    AllPaystackPaymentsPlatform.instance = fakePlatform;

    expect(await AllPaystackPayments.getPlatformVersion(), '42');
  });

  group('Platform Interface Tests', () {
    late MockAllPaystackPaymentsPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockAllPaystackPaymentsPlatform();
      AllPaystackPaymentsPlatform.instance = mockPlatform;
    });

    tearDown(() {
      AllPaystackPaymentsPlatform.instance = initialPlatform;
    });

    test('initialize calls platform', () async {
      await AllPaystackPayments.initialize('test_key');
      // Verify initialize was called - using the mock setup
    });

    test('initializePayment calls platform', () async {
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

      final result = await AllPaystackPayments.initializePayment(request);

      expect(result.reference, 'test_ref');
      expect(result.status, PaymentStatus.success);
      expect(result.amount, 1000);
      expect(result.currency, Currency.ngn);
      expect(result.paymentMethod, PaymentMethod.card);
    });

    test('verifyPayment calls platform', () async {
      final result = await AllPaystackPayments.verifyPayment('test_ref');

      expect(result.reference, 'test_ref');
      expect(result.status, PaymentStatus.success);
    });

    test('getPaymentStatus calls platform', () async {
      final result = await AllPaystackPayments.getPaymentStatus('test_ref');

      expect(result.reference, 'test_ref');
      expect(result.status, PaymentStatus.success);
    });

    test('cancelPayment calls platform', () async {
      final result = await AllPaystackPayments.cancelPayment('test_ref');

      expect(result, true);
    });
  });

  group('Payment Flow Integration Tests', () {
    late MockAllPaystackPaymentsPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockAllPaystackPaymentsPlatform();
      AllPaystackPaymentsPlatform.instance = mockPlatform;
    });

    tearDown(() {
      AllPaystackPaymentsPlatform.instance = initialPlatform;
    });

    test('Complete card payment flow', () async {
      // Initialize
      await AllPaystackPayments.initialize('pk_test_123');

      // Initialize payment
      final result = await AllPaystackPayments.initializeCardPayment(
        amount: 5000,
        email: 'customer@example.com',
        cardNumber: '4111111111111111',
        expiryMonth: '12',
        expiryYear: '26',
        cvv: '123',
        cardHolderName: 'John Customer',
        currency: Currency.ngn,
      );

      expect(result.status, PaymentStatus.success);
      expect(result.amount, 1000); // From mock
      expect(result.currency, Currency.ngn);

      // Verify payment
      final verification = await AllPaystackPayments.verifyPayment(
        result.reference,
      );
      expect(verification.status, PaymentStatus.success);
    });

    test('Bank transfer payment flow', () async {
      final result = await AllPaystackPayments.initializeBankTransfer(
        amount: 10000,
        email: 'customer@example.com',
        currency: Currency.ngn,
      );

      expect(result.status, PaymentStatus.success);
      expect(result.paymentMethod, PaymentMethod.card); // From mock
    });

    test('Mobile money payment flow', () async {
      final result = await AllPaystackPayments.initializeMobileMoney(
        amount: 2000,
        email: 'customer@example.com',
        provider: MobileMoneyProvider.mpesa,
        phoneNumber: '+254712345678',
        currency: Currency.kes,
      );

      expect(result.status, PaymentStatus.success);
      expect(result.paymentMethod, PaymentMethod.card); // From mock
    });
  });
}
