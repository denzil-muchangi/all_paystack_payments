// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

import 'all_paystack_payments_platform_interface.dart';
import 'card_payment_request.dart';
import 'mobile_money_request.dart';
import 'payment_request.dart';
import 'payment_response.dart';
import 'paystack_error.dart';

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

  /// Load Paystack script dynamically
  Future<void> _ensureScriptLoaded() async {
    if (_scriptLoaded) return;

    final script = web.HTMLScriptElement()
      ..src = 'https://js.paystack.co/v1/inline.js'
      ..type = 'text/javascript';

    web.document.head!.appendChild(script);

    // Wait for script to load
    await script.onLoad.first;
    _scriptLoaded = true;
  }

  @override
  Future<void> initialize(String publicKey) async {
    await _ensureScriptLoaded();
    _publicKey = publicKey;
  }

  @override
  Future<PaymentResponse> initializePayment(PaymentRequest request) async {
    if (_publicKey == null) {
      throw PaystackError(
        message: 'Paystack not initialized. Call initialize() first.',
      );
    }

    request.validate();

    final completer = Completer<PaymentResponse>();
    final reference = request.reference ?? _generateReference();

    _paymentCompleters[reference] = completer;

    try {
      // Prepare Paystack configuration
      final config = _createPaystackConfig(request, reference);

      // Call PaystackPop.setup()
      final paystackPop = web.window.getProperty('PaystackPop'.toJS);
      if (paystackPop.isUndefinedOrNull) {
        throw PaystackError(message: 'Paystack script not loaded properly');
      }

      (paystackPop as JSObject).callMethod(
        'setup'.toJS,
        config.jsify() as JSObject,
      );

      // Return the completer future - it will be completed by callbacks
      return completer.future;
    } catch (e) {
      _paymentCompleters.remove(reference);
      throw PaystackError(message: 'Failed to initialize payment: $e');
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
