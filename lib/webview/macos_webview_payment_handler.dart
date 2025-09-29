import 'dart:async';
import 'package:flutter/services.dart';
import '../webview_payment_handler.dart';
import '../payment_response.dart';
import '../enums.dart';
import '../paystack_error.dart';

/// macOS implementation of WebViewPaymentHandler using platform channels
class MacOSWebViewPaymentHandler implements WebViewPaymentHandler {
  static const MethodChannel _channel = MethodChannel('all_paystack_payments');

  @override
  Future<PaymentResponse> processPayment(String checkoutUrl) async {
    // Extract reference from checkout URL
    final uri = Uri.parse(checkoutUrl);
    final reference =
        uri.queryParameters['reference'] ??
        uri.queryParameters['trxref'] ??
        'macos_webview_${DateTime.now().millisecondsSinceEpoch}';

    try {
      // Call platform method to show webview (opens in browser) with timeout
      final result = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('showWebView', {
            'checkoutUrl': checkoutUrl,
          })
          .timeout(
            const Duration(minutes: 10),
            onTimeout: () {
              throw PaystackError(
                message:
                    'Payment timeout - user took too long to complete payment',
                code: 'PAYMENT_TIMEOUT',
              );
            },
          );

      if (result == null) {
        throw PaystackError(message: 'No response from webview');
      }

      final castedResult = result.cast<String, dynamic>();
      if (castedResult['status'] != 'success') {
        throw PaystackError.fromApiResponse(castedResult);
      }

      // Parse the payment result
      final data = castedResult['data'] as Map<String, dynamic>;
      final paymentReference = data['reference'] as String? ?? reference;
      final status = data['status'] as String? ?? 'success';

      return PaymentResponse(
        reference: paymentReference,
        status: _parsePaymentStatus(status),
        amount: 0, // Would be determined from verification
        currency: Currency.ngn, // Would be determined from verification
        paymentMethod: PaymentMethod.card, // Would be determined from payment
        gatewayResponse: data['message'] as String? ?? 'Payment completed',
      );
    } on PlatformException catch (e) {
      throw PaystackError(
        message: e.message ?? 'Webview payment failed',
        code: e.code,
      );
    } on TimeoutException {
      throw PaystackError(
        message: 'Payment timeout - user took too long to complete payment',
        code: 'PAYMENT_TIMEOUT',
      );
    } catch (_) {
      throw PaystackError(
        message: 'Unexpected error during payment',
        code: 'WEBVIEW_ERROR',
      );
    }
  }

  PaymentStatus _parsePaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      case 'cancelled':
        return PaymentStatus.cancelled;
      case 'pending':
        return PaymentStatus.pending;
      default:
        return PaymentStatus.pending;
    }
  }
}
