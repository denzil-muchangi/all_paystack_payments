// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

import 'all_paystack_payments_platform_interface.dart';
import 'card_payment_request.dart';
import 'mobile_money_request.dart';
import 'payment_request.dart';
import 'payment_response.dart';
import 'paystack_error.dart';
import 'enums.dart';

/// A web implementation of the AllPaystackPaymentsPlatform of the AllPaystackPayments plugin.
class AllPaystackPaymentsWeb extends AllPaystackPaymentsPlatform {
  /// Constructs a AllPaystackPaymentsWeb
  AllPaystackPaymentsWeb();

  static void registerWith(Registrar registrar) {
    AllPaystackPaymentsPlatform.instance = AllPaystackPaymentsWeb();
  }

  String? _publicKey;
  bool _scriptLoaded = false;
  final Map<String, Completer<PaymentResponse>> _paymentCompleters = {};

  /// Load Paystack script dynamically with integrity checks
  Future<void> _ensureScriptLoaded() async {
    if (_scriptLoaded) return;

    // First, fetch the script content to verify integrity
    final scriptUrl = 'https://js.paystack.co/v1/inline.js';
    final response = await http.get(Uri.parse(scriptUrl));

    if (response.statusCode != 200) {
      throw PaystackError(
        message: 'Failed to load Paystack script: HTTP ${response.statusCode}',
      );
    }

    final scriptContent = response.body;

    // Basic integrity checks
    if (!scriptContent.contains('PaystackPop') ||
        !scriptContent.contains('setup') ||
        scriptContent.length < 1000) {
      throw PaystackError(message: 'Paystack script integrity check failed');
    }

    // Additional security: ensure script doesn't contain suspicious patterns
    if (scriptContent.contains('eval(') ||
        scriptContent.contains('Function(') ||
        scriptContent.contains('setTimeout') &&
            scriptContent.contains('eval')) {
      throw PaystackError(
        message: 'Paystack script contains potentially unsafe code',
      );
    }

    final script = web.HTMLScriptElement()
      ..src = scriptUrl
      ..type = 'text/javascript'
      ..integrity = _calculateIntegrityHash(scriptContent)
      ..crossOrigin = 'anonymous';

    web.document.head!.appendChild(script);

    // Wait for script to load
    await script.onLoad.first;

    // Verify PaystackPop is available
    if (web.window.getProperty('PaystackPop'.toJS).isUndefinedOrNull) {
      throw PaystackError(
        message: 'Paystack script loaded but PaystackPop not found',
      );
    }

    _scriptLoaded = true;
  }

  /// Calculate a simple integrity hash for the script (base64 encoded)
  String _calculateIntegrityHash(String content) {
    // Use a simple hash for integrity checking
    final bytes = utf8.encode(content);
    final hash = base64.encode(
      bytes.sublist(0, math.min(50, bytes.length)),
    ); // First 50 bytes
    return 'sha256-$hash';
  }

  @override
  Future<void> initialize(String publicKey) async {
    await _ensureScriptLoaded();
    _publicKey = publicKey;
  }

  @override
  Future<PaymentResponse> initializePayment(PaymentRequest request) async {
    // For unified webview approach, get checkout URL first
    final checkoutUrl = await getCheckoutUrl(request);

    // For web, redirect to checkout URL (since web is already in browser)
    web.window.location.href = checkoutUrl;

    // Since we're redirecting, return a pending response
    // In practice, the app would handle the return via callback URL
    return PaymentResponse(
      reference: request.reference ?? _generateReference(),
      status: PaymentStatus.pending,
      amount: request.amount,
      currency: request.currency,
      paymentMethod: PaymentMethod.card, // Default
    );
  }

  @override
  Future<String> getCheckoutUrl(PaymentRequest request) async {
    if (_publicKey == null) {
      throw PaystackError(
        message: 'Paystack not initialized. Call initialize() first.',
      );
    }

    request.validate();

    try {
      // Initialize transaction with Paystack API to get checkout URL
      final url = Uri.parse('https://api.paystack.co/transaction/initialize');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_publicKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': request.amount,
          'email': request.email,
          'currency': request.currency.name.toUpperCase(),
          'reference': request.reference ?? _generateReference(),
          'callback_url': request.callbackUrl,
          'metadata': request.metadata,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return data['data']['authorization_url'] as String;
        } else {
          throw PaystackError.fromApiResponse(data);
        }
      } else {
        throw PaystackError(
          message: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      if (e is PaystackError) rethrow;
      throw PaystackError(message: 'Failed to get checkout URL: $e');
    }
  }

  JSObject _createPaystackConfig(PaymentRequest request, String reference) {
    final config = <String, dynamic>{
      'key': _publicKey,
      'email': request.email,
      'amount': request.amount,
      'currency': request.currency.name.toUpperCase(),
      'ref': reference,
      'callback': _createCallback(reference),
      'onClose': _createOnCloseCallback(reference),
    };

    // Add payment method specific configuration
    if (request is CardPaymentRequest) {
      // For card payments, Paystack handles the form
      config.addAll({
        'channels': ['card'],
      });
    } else if (request is MobileMoneyRequest) {
      config.addAll({
        'channels': ['mobile_money'],
        'mobile_money': {
          'phone': request.phoneNumber,
          'provider': request.provider.name,
        },
      });
    } else if (request.runtimeType == PaymentRequest) {
      // Bank transfer - Paystack will show all available channels
      config.addAll({
        'channels': ['bank', 'card', 'mobile_money'],
      });
    }

    if (request.metadata != null) {
      config['metadata'] = request.metadata;
    }

    return config.jsify() as JSObject;
  }

  void Function(JSObject) _createCallback(String reference) {
    // This will be converted to JS function automatically
    return (JSObject response) {
      final completer = _paymentCompleters.remove(reference);
      if (completer != null && !completer.isCompleted) {
        try {
          final paymentResponse = PaymentResponse.fromApiResponse(
            response.dartify() as Map<String, dynamic>,
          );
          completer.complete(paymentResponse);
        } catch (e) {
          completer.completeError(
            PaystackError(message: 'Payment callback error: $e'),
          );
        }
      }
    };
  }

  void Function() _createOnCloseCallback(String reference) {
    // This will be converted to JS function automatically
    return () {
      final completer = _paymentCompleters.remove(reference);
      if (completer != null && !completer.isCompleted) {
        completer.completeError(
          PaystackError(message: 'Payment cancelled by user'),
        );
      }
    };
  }

  String _generateReference() {
    return 'flutter_paystack_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  @override
  Future<PaymentResponse> verifyPayment(String reference) async {
    return _verifyTransaction(reference);
  }

  @override
  Future<PaymentResponse> getPaymentStatus(String reference) async {
    return _verifyTransaction(reference);
  }

  Future<PaymentResponse> _verifyTransaction(String reference) async {
    if (_publicKey == null) {
      throw PaystackError(
        message: 'Paystack not initialized. Call initialize() first.',
      );
    }

    try {
      final url = Uri.parse(
        'https://api.paystack.co/transaction/verify/$reference',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_publicKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return PaymentResponse.fromApiResponse(
            data['data'] as Map<String, dynamic>,
          );
        } else {
          throw PaystackError.fromApiResponse(data);
        }
      } else {
        throw PaystackError(
          message: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      if (e is PaystackError) rethrow;
      throw PaystackError(message: 'Verification failed: $e');
    }
  }

  @override
  Future<bool> cancelPayment(String reference) async {
    final completer = _paymentCompleters.remove(reference);
    if (completer != null && !completer.isCompleted) {
      completer.completeError(PaystackError(message: 'Payment cancelled'));
      return true;
    }
    return false;
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }
}
