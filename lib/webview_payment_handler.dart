import 'package:flutter/foundation.dart';
import 'payment_response.dart';
import 'webview/android_webview_payment_handler.dart';
import 'webview/ios_webview_payment_handler.dart';
import 'webview/web_webview_payment_handler.dart';
import 'webview/macos_webview_payment_handler.dart';
import 'webview/windows_webview_payment_handler.dart';
import 'webview/linux_webview_payment_handler.dart';

/// Unified interface for handling Paystack payments through webviews across all platforms.
///
/// This interface provides a consistent API for opening Paystack checkout URLs in webviews
/// and handling payment completion callbacks across different platforms.
abstract class WebViewPaymentHandler {
  /// Processes a payment by opening the provided checkout URL in a webview.
  ///
  /// The implementation should:
  /// - Open the checkout URL in a platform-appropriate webview
  /// - Handle Paystack's callback mechanisms (redirects, postMessage, etc.)
  /// - Return a [PaymentResponse] based on the payment outcome
  ///
  /// [checkoutUrl] The Paystack checkout URL to load in the webview
  ///
  /// Returns a [PaymentResponse] containing the payment result
  Future<PaymentResponse> processPayment(String checkoutUrl);
}

/// Factory for creating platform-specific WebViewPaymentHandler instances
class WebViewPaymentHandlerFactory {
  static WebViewPaymentHandler create() {
    if (kIsWeb) {
      return WebWebViewPaymentHandler();
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidWebViewPaymentHandler();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return IOSWebViewPaymentHandler();
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return MacOSWebViewPaymentHandler();
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      return WindowsWebViewPaymentHandler();
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      return LinuxWebViewPaymentHandler();
    } else {
      // Fallback for unknown platforms
      throw UnimplementedError('Platform not supported');
    }
  }
}
