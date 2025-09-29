import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';

import 'package:all_paystack_payments/all_paystack_payments.dart';

import 'l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _currentLocale = const Locale('en');
  bool _isInitialized = false;
  String _statusMessage = 'Not Initialized';
  final String _paystackPublicKey =
      'pk_test_YOUR_PUBLIC_KEY'; // Replace with your actual public key

  @override
  void initState() {
    super.initState();
    _initializePaystack();
  }

  Future<void> _initializePaystack() async {
    try {
      await AllPaystackPayments.initialize(_paystackPublicKey);
      _showSnackBar(
        context,
        AppLocalizations.of(context)!.initializationSuccess,
      );
    } on PaystackError catch (e) {
      _showSnackBar(
        context,
        AppLocalizations.of(context)!.initializationFailed(e.message),
        isError: true,
      );
    } catch (e) {
      setState(() {
        _statusMessage = AppLocalizations.of(
          context,
        )!.unexpectedError(e.toString());
      });
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showPaymentDialog(String title, Widget content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: content,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleCardPayment() async {
    final formKey = GlobalKey<FormState>();
    final cardNumberController = TextEditingController();
    final expiryMonthController = TextEditingController();
    final expiryYearController = TextEditingController();
    final cvvController = TextEditingController();
    final cardHolderController = TextEditingController();
    final emailController = TextEditingController();
    final amountController = TextEditingController();

    _showPaymentDialog(
      AppLocalizations.of(context)!.cardPayment,
      Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                ),
                validator: (value) => value?.isEmpty ?? true
                    ? AppLocalizations.of(context)!.required
                    : null,
              ),
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.amountKobo,
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true
                    ? AppLocalizations.of(context)!.required
                    : null,
              ),
              TextFormField(
                controller: cardNumberController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.cardNumber,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true)
                    return AppLocalizations.of(context)!.required;
                  final regex = RegExp(r'^\d{13,19}$');
                  if (!regex.hasMatch(value!))
                    return AppLocalizations.of(context)!.invalidCardNumber;
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: expiryMonthController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.expiryMonth,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true
                          ? AppLocalizations.of(context)!.required
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: expiryYearController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.expiryYear,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true
                          ? AppLocalizations.of(context)!.required
                          : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: cvvController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.cvv,
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true
                    ? AppLocalizations.of(context)!.required
                    : null,
              ),
              TextFormField(
                controller: cardHolderController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.cardHolderName,
                ),
                validator: (value) => value?.isEmpty ?? true
                    ? AppLocalizations.of(context)!.required
                    : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.of(context).pop();
                    await _processCardPayment(
                      email: emailController.text,
                      amount: int.parse(amountController.text),
                      cardNumber: cardNumberController.text,
                      expiryMonth: expiryMonthController.text,
                      expiryYear: expiryYearController.text,
                      cvv: cvvController.text,
                      cardHolderName: cardHolderController.text,
                    );
                  }
                },
                child: Text(AppLocalizations.of(context)!.pay),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processCardPayment({
    required String email,
    required int amount,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardHolderName,
  }) async {
    final currentContext = context;
    try {
      _showSnackBar(
        currentContext,
        AppLocalizations.of(currentContext)!.processingCardPayment,
      );
      final metadata = {
        'payment_type': 'card',
        'timestamp': DateTime.now().toIso8601String(),
      };
      final response = await AllPaystackPayments.initializeCardPayment(
        amount: amount,
        email: email,
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvv: cvv,
        cardHolderName: cardHolderName,
        metadata: metadata,
      );
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(
          context,
        )!.paymentStatus(response.status.name, response.gatewayResponse ?? ''),
      );
    } on PaystackError catch (e) {
      if (!mounted) return;
      log('Card payment error: $e');
      _showSnackBar(
        context,
        AppLocalizations.of(context)!.paymentFailed(e.message),
        isError: true,
      );
    } on ArgumentError catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(currentContext)!.invalidCardDetails(e.message),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      log('Card payment error: $e');
      _showSnackBar(
        context,
        AppLocalizations.of(context)!.unexpectedError(e.toString()),
        isError: true,
      );
    }
  }

  Future<void> _handleBankTransfer() async {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final amountController = TextEditingController();
    Currency selectedCurrency = Currency.ngn;

    _showPaymentDialog(
      AppLocalizations.of(context)!.bankTransfer,
      Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.email ?? 'Email',
              ),
              validator: (value) => value?.isEmpty ?? true
                  ? AppLocalizations.of(context)?.required ?? 'Required'
                  : null,
            ),
            TextFormField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.amountKobo,
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true
                  ? AppLocalizations.of(context)!.required
                  : null,
            ),
            DropdownButtonFormField<Currency>(
              initialValue: selectedCurrency,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.currency,
              ),
              items: Currency.values.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => selectedCurrency = value!,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop();
                  await _processBankTransfer(
                    email: emailController.text,
                    amount: int.parse(amountController.text),
                    currency: selectedCurrency,
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.initiateTransfer),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processBankTransfer({
    required String email,
    required int amount,
    required Currency currency,
  }) async {
    final currentContext = context;
    try {
      _showSnackBar(
        currentContext,
        AppLocalizations.of(currentContext)!.initiatingBankTransfer,
      );
      final response = await AllPaystackPayments.initializeBankTransfer(
        amount: amount,
        email: email,
        currency: currency,
      );
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(
          context,
        )!.transferStatus(response.status.name, response.gatewayResponse ?? ''),
      );
    } on PaystackError catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(context)!.transferFailed(e.message),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(context)!.unexpectedError(e.toString()),
        isError: true,
      );
    }
  }

  Future<void> _handleMobileMoney() async {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final amountController = TextEditingController();
    final phoneController = TextEditingController();
    MobileMoneyProvider selectedProvider = MobileMoneyProvider.mpesa;
    Currency selectedCurrency = Currency.ngn;

    _showPaymentDialog(
      AppLocalizations.of(context)?.mobileMoney ?? 'Mobile Money',
      Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.email,
              ),
              validator: (value) => value?.isEmpty ?? true
                  ? AppLocalizations.of(context)!.required
                  : null,
            ),
            TextFormField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.amountKobo,
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true
                  ? AppLocalizations.of(context)!.required
                  : null,
            ),
            DropdownButtonFormField<Currency>(
              initialValue: selectedCurrency,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.currency,
              ),
              items: Currency.values.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => selectedCurrency = value!,
            ),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.phoneNumber,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true)
                  return AppLocalizations.of(context)!.required;
                final regex = RegExp(r'^\+\d{10,15}$');
                if (!regex.hasMatch(value!)) {
                  return AppLocalizations.of(context)!.invalidPhoneNumber;
                }
                return null;
              },
            ),
            DropdownButtonFormField<MobileMoneyProvider>(
              initialValue: selectedProvider,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.provider,
              ),
              items: MobileMoneyProvider.values.map((provider) {
                return DropdownMenuItem(
                  value: provider,
                  child: Text(provider.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => selectedProvider = value!,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop();
                  await _processMobileMoney(
                    email: emailController.text,
                    amount: int.parse(amountController.text),
                    provider: selectedProvider,
                    phoneNumber: phoneController.text,
                    currency: selectedCurrency,
                    localizations: AppLocalizations.of(context)!,
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.pay),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processMobileMoney({
    required String email,
    required int amount,
    required MobileMoneyProvider provider,
    required String phoneNumber,
    required Currency currency,
    required AppLocalizations localizations,
  }) async {
    final currentContext = context;
    try {
      _showSnackBar(
        currentContext,
        AppLocalizations.of(currentContext)!.processingMobileMoney,
      );
      if (phoneNumber.startsWith('+254') &&
          provider != MobileMoneyProvider.mpesa) {
        throw ArgumentError(localizations.onlyMpesaSupported);
      }
      final response = await AllPaystackPayments.initializeMobileMoney(
        amount: amount,
        email: email,
        provider: provider,
        phoneNumber: phoneNumber,
        currency: currency,
      );
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(
          context,
        )!.paymentStatus(response.status.name, response.gatewayResponse ?? ''),
      );
    } on PaystackError catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(context)!.paymentFailed(e.message),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(context)!.unexpectedError(e.toString()),
        isError: true,
      );
    }
  }

  Future<void> _handleVerifyPayment() async {
    final formKey = GlobalKey<FormState>();
    final referenceController = TextEditingController();

    _showPaymentDialog(
      AppLocalizations.of(context)!.verifyPayment,
      Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: referenceController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.reference,
              ),
              validator: (value) => value?.isEmpty ?? true
                  ? AppLocalizations.of(context)!.required
                  : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop();
                  await _processVerifyPayment(
                    reference: referenceController.text,
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.verify),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processVerifyPayment({required String reference}) async {
    final currentContext = context;
    try {
      _showSnackBar(
        currentContext,
        AppLocalizations.of(currentContext)!.verifyingPayment,
      );
      final response = await AllPaystackPayments.verifyPayment(reference);
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(
          context,
        )!.paymentStatus(response.status.name, response.gatewayResponse ?? ''),
      );
    } on PaystackError catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(context)!.verificationFailed(e.message),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(context)!.unexpectedError(e.toString()),
        isError: true,
      );
    }
  }

  Future<void> _handleGetPaymentStatus() async {
    final formKey = GlobalKey<FormState>();
    final referenceController = TextEditingController();

    _showPaymentDialog(
      AppLocalizations.of(context)!.getPaymentStatus,
      Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: referenceController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.reference,
              ),
              validator: (value) => value?.isEmpty ?? true
                  ? AppLocalizations.of(context)!.required
                  : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop();
                  await _processGetPaymentStatus(
                    reference: referenceController.text,
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.getStatus),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processGetPaymentStatus({required String reference}) async {
    final currentContext = context;
    try {
      _showSnackBar(
        currentContext,
        AppLocalizations.of(currentContext)!.gettingPaymentStatus,
      );
      final response = await AllPaystackPayments.getPaymentStatus(reference);
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(
          context,
        )!.paymentStatus(response.status.name, response.gatewayResponse ?? ''),
      );
    } on PaystackError catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(context)!.getStatusFailed(e.message),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(context)!.unexpectedError(e.toString()),
        isError: true,
      );
    }
  }

  Future<void> _handleCancelPayment() async {
    final formKey = GlobalKey<FormState>();
    final referenceController = TextEditingController();

    _showPaymentDialog(
      AppLocalizations.of(context)!.cancelPayment,
      Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: referenceController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.reference,
              ),
              validator: (value) => value?.isEmpty ?? true
                  ? AppLocalizations.of(context)!.required
                  : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop();
                  await _processCancelPayment(
                    reference: referenceController.text,
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processCancelPayment({required String reference}) async {
    final currentContext = context;
    try {
      _showSnackBar(
        currentContext,
        AppLocalizations.of(currentContext)!.cancellingPayment,
      );
      final success = await AllPaystackPayments.cancelPayment(reference);
      if (!mounted) return;
      _showSnackBar(
        context,
        success
            ? AppLocalizations.of(context)!.paymentCancelledSuccessfully
            : AppLocalizations.of(context)!.paymentCancellationFailed,
      );
    } on PaystackError catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(context)!.cancellationFailed(e.message),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        AppLocalizations.of(context)!.unexpectedError(e.toString()),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _currentLocale,
      home: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.appTitle),
          actions: [
            DropdownButton<Locale>(
              value: _currentLocale,
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  setState(() {
                    _currentLocale = newLocale;
                  });
                }
              },
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('fr'), child: Text('Français')),
              ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isInitialized
                    ? AppLocalizations.of(context)?.readyToAcceptPayments ??
                          'Ready to accept payments'
                    : AppLocalizations.of(context)?.initializing ??
                          'Initializing...',
                style: TextStyle(
                  color: _isInitialized ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(_statusMessage, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isInitialized ? _handleCardPayment : null,
                child: Text(
                  AppLocalizations.of(context)?.payWithCard ?? 'Pay with Card',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized ? _handleBankTransfer : null,
                child: Text(
                  AppLocalizations.of(context)?.payWithBankTransfer ??
                      'Pay with Bank Transfer',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized ? _handleMobileMoney : null,
                child: Text(
                  AppLocalizations.of(context)?.payWithMobileMoney ??
                      'Pay with Mobile Money',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized ? _handleVerifyPayment : null,
                child: Text(
                  AppLocalizations.of(context)?.verifyPayment ??
                      'Verify Payment',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized ? _handleGetPaymentStatus : null,
                child: Text(
                  AppLocalizations.of(context)?.getPaymentStatus ??
                      'Get Payment Status',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized ? _handleCancelPayment : null,
                child: Text(
                  AppLocalizations.of(context)?.cancelPayment ??
                      'Cancel Payment',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
