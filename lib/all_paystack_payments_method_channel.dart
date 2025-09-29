import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'all_paystack_payments_platform_interface.dart';
import 'payment_request.dart';
import 'payment_response.dart';
import 'paystack_error.dart';

/// An implementation of [AllPaystackPaymentsPlatform] that uses method channels.
class MethodChannelAllPaystackPayments extends AllPaystackPaymentsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('all_paystack_payments');

  @override
  Future<void> initialize(String publicKey) async {
    try {
      await methodChannel.invokeMethod('initialize', {'publicKey': publicKey});
    } on PlatformException catch (e) {
      throw PaystackError(
        message: e.message ?? 'Failed to initialize Paystack',
        code: e.code,
      );
    }
  }

  @override
  Future<PaymentResponse> initializePayment(PaymentRequest request) async {
    try {
      request.validate();
      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'initializePayment',
        request.toJson(),
      );
      if (result == null) {
        throw PaystackError(message: 'No response from payment initialization');
      }
      final castedResult = result.cast<String, dynamic>();
      if (castedResult['status'] != 'success') {
        throw PaystackError.fromApiResponse(castedResult);
      }
      return PaymentResponse.fromApiResponse(castedResult);
    } on PlatformException catch (e) {
      throw PaystackError(
        message: e.message ?? 'Failed to initialize payment',
        code: e.code,
      );
    }
  }

  @override
  Future<PaymentResponse> verifyPayment(String reference) async {
    try {
      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'verifyPayment',
        {'reference': reference},
      );
      if (result == null) {
        throw PaystackError(message: 'No response from payment verification');
      }
      final castedResult = result.cast<String, dynamic>();
      if (castedResult['status'] != 'success') {
        throw PaystackError.fromApiResponse(castedResult);
      }
      return PaymentResponse.fromApiResponse(castedResult);
    } on PlatformException catch (e) {
      throw PaystackError(
        message: e.message ?? 'Failed to verify payment',
        code: e.code,
      );
    }
  }

  @override
  Future<PaymentResponse> getPaymentStatus(String reference) async {
    try {
      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getPaymentStatus',
        {'reference': reference},
      );
      if (result == null) {
        throw PaystackError(message: 'No response from payment status check');
      }
      final castedResult = result.cast<String, dynamic>();
      if (castedResult['status'] != 'success') {
        throw PaystackError.fromApiResponse(castedResult);
      }
      return PaymentResponse.fromApiResponse(castedResult);
    } on PlatformException catch (e) {
      throw PaystackError(
        message: e.message ?? 'Failed to get payment status',
        code: e.code,
      );
    }
  }

  @override
  Future<bool> cancelPayment(String reference) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('cancelPayment', {
        'reference': reference,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw PaystackError(
        message: e.message ?? 'Failed to cancel payment',
        code: e.code,
      );
    }
  }

  @override
  Future<String> getCheckoutUrl(PaymentRequest request) async {
    try {
      request.validate();
      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getCheckoutUrl',
        request.toJson(),
      );
      if (result == null) {
        throw PaystackError(message: 'No response from checkout URL request');
      }
      final castedResult = result.cast<String, dynamic>();
      if (castedResult['status'] != 'success') {
        throw PaystackError.fromApiResponse(castedResult);
      }
      final data = castedResult['data'] as Map<String, dynamic>;
      final checkoutUrl = data['authorization_url'] as String?;
      if (checkoutUrl == null) {
        throw PaystackError(message: 'No checkout URL in response');
      }
      return checkoutUrl;
    } on PlatformException catch (e) {
      throw PaystackError(
        message: e.message ?? 'Failed to get checkout URL',
        code: e.code,
      );
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
