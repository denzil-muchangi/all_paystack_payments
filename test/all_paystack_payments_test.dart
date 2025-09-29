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
}
