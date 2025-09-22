import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'all_paystack_payments_method_channel.dart';
import 'payment_request.dart';
import 'payment_response.dart';

abstract class AllPaystackPaymentsPlatform extends PlatformInterface {
  /// Constructs a AllPaystackPaymentsPlatform.
  AllPaystackPaymentsPlatform() : super(token: _token);

  static final Object _token = Object();

  static AllPaystackPaymentsPlatform _instance =
      MethodChannelAllPaystackPayments();

  /// The default instance of [AllPaystackPaymentsPlatform] to use.
  ///
  /// Defaults to [MethodChannelAllPaystackPayments].
  static AllPaystackPaymentsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AllPaystackPaymentsPlatform] when
  /// they register themselves.
  static set instance(AllPaystackPaymentsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initialize the Paystack SDK with public key
  Future<void> initialize(String publicKey) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Initialize a payment transaction
  Future<PaymentResponse> initializePayment(PaymentRequest request) {
    throw UnimplementedError('initializePayment() has not been implemented.');
  }

  /// Verify a payment transaction
  Future<PaymentResponse> verifyPayment(String reference) {
    throw UnimplementedError('verifyPayment() has not been implemented.');
  }

  /// Get payment status
  Future<PaymentResponse> getPaymentStatus(String reference) {
    throw UnimplementedError('getPaymentStatus() has not been implemented.');
  }

  /// Cancel a payment transaction
  Future<bool> cancelPayment(String reference) {
    throw UnimplementedError('cancelPayment() has not been implemented.');
  }

  /// Get platform version (legacy method for backward compatibility)
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
