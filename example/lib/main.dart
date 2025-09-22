import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:all_paystack_payments/all_paystack_payments.dart';

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

  @override
  void initState() {
    super.initState();
    _initializePaystack();
  }

  Future<void> _initializePaystack() async {
    try {
      // Initialize with test public key - replace with your actual test key
      await AllPaystackPayments.initialize('pk_test_your_test_public_key_here');
      setState(() {
        _isInitialized = true;
        _statusMessage = 'Paystack initialized successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to initialize Paystack: $e';
      });
    }
  }

  void _showPaymentDialog(String title, Widget content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
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
      'Card Payment',
      Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount (kobo)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: cardNumberController,
                decoration: const InputDecoration(labelText: 'Card Number'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: expiryMonthController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Month (MM)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: expiryYearController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Year (YY)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: cvvController,
                decoration: const InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: cardHolderController,
                decoration: const InputDecoration(
                  labelText: 'Card Holder Name',
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
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
                child: const Text('Pay'),
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
    try {
      _showSnackBar('Processing card payment...');
      final response = await AllPaystackPayments.initializeCardPayment(
        amount: amount,
        email: email,
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvv: cvv,
        cardHolderName: cardHolderName,
      );
      _showSnackBar(
        'Payment ${response.status.name}: ${response.gatewayResponse ?? ''}',
      );
    } on PaystackError catch (e) {
      _showSnackBar('Payment failed: ${e.message}', isError: true);
    } catch (e) {
      _showSnackBar('Unexpected error: $e', isError: true);
    }
  }

  Future<void> _handleBankTransfer() async {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final amountController = TextEditingController();

    _showPaymentDialog(
      'Bank Transfer',
      Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount (kobo)'),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
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
              child: const Text('Initiate Transfer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processBankTransfer({
    required String email,
    required int amount,
  }) async {
    try {
      _showSnackBar('Initiating bank transfer...');
      final response = await AllPaystackPayments.initializeBankTransfer(
        amount: amount,
        email: email,
      );
      _showSnackBar(
        'Transfer ${response.status.name}: ${response.gatewayResponse ?? ''}',
      );
    } on PaystackError catch (e) {
      _showSnackBar('Transfer failed: ${e.message}', isError: true);
    } catch (e) {
      _showSnackBar('Unexpected error: $e', isError: true);
    }
  }

  Future<void> _handleMobileMoney() async {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final amountController = TextEditingController();
    final phoneController = TextEditingController();
    MobileMoneyProvider selectedProvider = MobileMoneyProvider.mpesa;

    _showPaymentDialog(
      'Mobile Money',
      Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount (kobo)'),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            DropdownButtonFormField<MobileMoneyProvider>(
              value: selectedProvider,
              decoration: const InputDecoration(labelText: 'Provider'),
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
              child: const Text('Pay'),
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
    try {
      _showSnackBar('Processing mobile money payment...');
      final response = await AllPaystackPayments.initializeMobileMoney(
        amount: amount,
        email: email,
        provider: provider,
        phoneNumber: phoneNumber,
      );
      _showSnackBar(
        'Payment ${response.status.name}: ${response.gatewayResponse ?? ''}',
      );
    } on PaystackError catch (e) {
      _showSnackBar('Payment failed: ${e.message}', isError: true);
    } catch (e) {
      _showSnackBar('Unexpected error: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Paystack Payment Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isInitialized ? 'Ready to accept payments' : 'Initializing...',
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
                child: const Text('Pay with Card'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized ? _handleBankTransfer : null,
                child: const Text('Pay with Bank Transfer'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized ? _handleMobileMoney : null,
                child: const Text('Pay with Mobile Money'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
