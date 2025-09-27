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
  bool _isInitialized = false;
  String _statusMessage = '';
  Locale _currentLocale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _initializePaystack();
  }

  Future<void> _initializePaystack() async {
    try {
      const key = 'pk_test_1234567890abcdef'; // Test key for simulation
      // Initialize with test public key
      await AllPaystackPayments.initialize(key);
      setState(() {
        _isInitialized = true;
        _statusMessage =
            AppLocalizations.of(context)?.paystackInitialized ??
            'Paystack initialized successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage =
            AppLocalizations.of(context)?.paystackInitFailed(e.toString()) ??
            'Failed to initialize Paystack: ${e.toString()}';
      });
    }
  }

  void _showPaymentDialog(
    String title,
    Widget content, {
    AppLocalizations? localizations,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations?.cancel ?? 'Cancel'),
          ),
        ],
      ),
    );
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
      AppLocalizations.of(context)?.cardPayment ?? 'Card Payment',
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
                  if (value?.isEmpty ?? true) return 'Required';
                  final regex = RegExp(r'^\d{13,19}$');
                  if (!regex.hasMatch(value!)) return 'Invalid card number';
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
        'Invalid card details: ${e.message}',
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop();
                  await _processBankTransfer(
                    email: emailController.text,
                    amount: int.parse(amountController.text),
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.initiateTransfer),
            ),
          ],
        ),
      ),
      localizations: AppLocalizations.of(context),
    );
  }

  Future<void> _processBankTransfer({
    required String email,
    required int amount,
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

    _showPaymentDialog(
      AppLocalizations.of(context)!.mobileMoney,
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
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.phoneNumber,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                final regex = RegExp(r'^\+\d{10,15}$');
                if (!regex.hasMatch(value!)) {
                  return 'Invalid phone number (include country code)';
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
  }) async {
    final currentContext = context;
    try {
      _showSnackBar(
        currentContext,
        AppLocalizations.of(currentContext)!.processingMobileMoney,
      );
      if (phoneNumber.startsWith('+254') &&
          provider != MobileMoneyProvider.mpesa) {
        throw ArgumentError('Only M-Pesa supported for Kenya');
      }
      final response = await AllPaystackPayments.initializeMobileMoney(
        amount: amount,
        email: email,
        provider: provider,
        phoneNumber: phoneNumber,
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _currentLocale,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)?.appTitle ??
                'Paystack Payments Example',
          ),
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
            ],
          ),
        ),
      ),
    );
  }
}
