import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';

import 'package:all_paystack_payments/all_paystack_payments.dart';
import 'package:all_paystack_payments/validation_utils.dart';

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
  bool _isInitializing = false;
  bool _isProcessingPayment = false;
  String _statusMessage = 'Not Initialized';
  final String _paystackPublicKey =
      'pk_test_YOUR_PUBLIC_KEY'; // Replace with your actual public key

  @override
  void initState() {
    super.initState();
    _initializePaystack();
  }

  Future<void> _initializePaystack() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
      _statusMessage = 'Initializing Paystack...';
    });

    try {
      await AllPaystackPayments.initialize(_paystackPublicKey);
      setState(() {
        _isInitialized = true;
        _statusMessage = 'Ready to accept payments';
      });
      _showSnackBar(context, 'Paystack initialized successfully');
    } on PaystackError catch (e) {
      setState(() {
        _statusMessage = 'Initialization failed: ${e.message}';
      });
      _showSnackBar(
        context,
        'Initialization failed: ${e.message}',
        isError: true,
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Unexpected error: ${e.toString()}';
      });
      _showSnackBar(context, 'Unexpected initialization error', isError: true);
    } finally {
      setState(() {
        _isInitializing = false;
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
                  if (!ValidationUtils.isValidCardNumber(value!))
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
                      validator: (value) {
                        if (value?.isEmpty ?? true)
                          return AppLocalizations.of(context)!.required;
                        if (!ValidationUtils.isValidExpiryDate(
                          value!,
                          expiryYearController.text,
                        ))
                          return 'Invalid expiry date';
                        return null;
                      },
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
                      validator: (value) {
                        if (value?.isEmpty ?? true)
                          return AppLocalizations.of(context)!.required;
                        if (!ValidationUtils.isValidExpiryDate(
                          expiryMonthController.text,
                          value!,
                        ))
                          return 'Invalid expiry date';
                        return null;
                      },
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
                validator: (value) {
                  if (value?.isEmpty ?? true)
                    return AppLocalizations.of(context)!.required;
                  if (!ValidationUtils.isValidCvv(value!))
                    return 'Invalid CVV (3-4 digits)';
                  return null;
                },
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
    if (_isProcessingPayment) return;

    setState(() => _isProcessingPayment = true);

    try {
      _showSnackBar(context, 'Processing card payment...');

      final metadata = {
        'payment_type': 'card',
        'timestamp': DateTime.now().toIso8601String(),
        'card_last_four': cardNumber.substring(cardNumber.length - 4),
      };

      final response = await AllPaystackPayments.initializeCardPayment(
        amount: amount,
        email: email,
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvv: cvv,
        cardHolderName: cardHolderName,
        reference: 'card_${DateTime.now().millisecondsSinceEpoch}',
        metadata: metadata,
      );

      if (!mounted) return;

      if (response.isSuccessful) {
        _showSnackBar(
          context,
          'Payment successful! Reference: ${response.reference}',
        );
        // In production, you would navigate to success screen
        // or update order status
      } else {
        _showSnackBar(
          context,
          'Payment failed: ${response.gatewayResponse ?? 'Unknown error'}',
          isError: true,
        );
      }
    } on PaystackError catch (e) {
      if (!mounted) return;
      log('Paystack card payment error: ${e.message}', error: e);

      String userMessage;
      switch (e.code) {
        case 'insufficient_funds':
          userMessage = 'Insufficient funds on card';
          break;
        case 'card_declined':
          userMessage = 'Card was declined. Please try a different card.';
          break;
        case 'invalid_card':
          userMessage = 'Invalid card details. Please check and try again.';
          break;
        case 'expired_card':
          userMessage = 'Card has expired. Please use a valid card.';
          break;
        default:
          userMessage = e.message;
      }

      _showSnackBar(context, userMessage, isError: true);
    } on ArgumentError catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        'Invalid card details: ${e.message}',
        isError: true,
      );
    } on TimeoutException catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        'Payment timed out. Please try again.',
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      log('Unexpected card payment error: $e');
      _showSnackBar(
        context,
        'An unexpected error occurred. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
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
    if (_isProcessingPayment) return;

    setState(() => _isProcessingPayment = true);

    try {
      _showSnackBar(context, 'Initiating bank transfer...');

      final response = await AllPaystackPayments.initializeBankTransfer(
        amount: amount,
        email: email,
        currency: currency,
        reference: 'bank_transfer_${DateTime.now().millisecondsSinceEpoch}',
        metadata: {
          'payment_type': 'bank_transfer',
          'initiated_at': DateTime.now().toIso8601String(),
        },
      );

      if (!mounted) return;

      if (response.isSuccessful) {
        _showSnackBar(context, 'Bank transfer initiated successfully!');
        // Show bank details dialog
        _showBankTransferDetails(response);
      } else {
        _showSnackBar(
          context,
          'Bank transfer failed: ${response.gatewayResponse ?? 'Unknown error'}',
          isError: true,
        );
      }
    } on PaystackError catch (e) {
      if (!mounted) return;
      log('Bank transfer error: ${e.message}', error: e);
      _showSnackBar(
        context,
        'Bank transfer failed: ${e.message}',
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      log('Unexpected bank transfer error: $e');
      _showSnackBar(
        context,
        'An unexpected error occurred. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  void _showBankTransferDetails(PaymentResponse response) {
    final rawData = response.rawResponse;
    String bankName = 'Unknown Bank';
    String accountNumber = 'Unknown';
    String accountName = 'Unknown';

    if (rawData != null && rawData['data'] != null) {
      final data = rawData['data'];
      bankName = data['bank_name'] ?? bankName;
      accountNumber = data['account_number'] ?? accountNumber;
      accountName = data['account_name'] ?? accountName;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bank Transfer Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bank: $bankName'),
              SizedBox(height: 8),
              Text('Account Name: $accountName'),
              SizedBox(height: 8),
              Text('Account Number: $accountNumber'),
              SizedBox(height: 8),
              Text('Amount: ₦${(response.amount / 100).toStringAsFixed(2)}'),
              SizedBox(height: 8),
              Text('Reference: ${response.reference}'),
              SizedBox(height: 16),
              Text(
                'Please transfer the exact amount to the account above within 30 minutes. The payment will be verified automatically.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally navigate to verification screen
                _showVerificationDialog(response.reference);
              },
              child: Text('Verify Payment'),
            ),
          ],
        );
      },
    );
  }

  void _showVerificationDialog(String reference) {
    final referenceController = TextEditingController(text: reference);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verify Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter the payment reference to verify:'),
              SizedBox(height: 16),
              TextField(
                controller: referenceController,
                decoration: InputDecoration(
                  labelText: 'Reference',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processVerifyPayment(reference: referenceController.text);
              },
              child: Text('Verify'),
            ),
          ],
        );
      },
    );
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
    if (_isProcessingPayment) return;

    setState(() => _isProcessingPayment = true);

    try {
      _showSnackBar(context, 'Processing mobile money payment...');

      // Validate phone number format for provider
      if (phoneNumber.startsWith('+254') &&
          provider != MobileMoneyProvider.mpesa) {
        throw ArgumentError(
          'Only M-Pesa is supported for Kenyan numbers (+254)',
        );
      }

      final response = await AllPaystackPayments.initializeMobileMoney(
        amount: amount,
        email: email,
        provider: provider,
        phoneNumber: phoneNumber,
        currency: currency,
        reference: 'mobile_money_${DateTime.now().millisecondsSinceEpoch}',
        metadata: {
          'payment_type': 'mobile_money',
          'provider': provider.name,
          'phone_last_four': phoneNumber.substring(phoneNumber.length - 4),
        },
      );

      if (!mounted) return;

      if (response.isSuccessful) {
        _showSnackBar(
          context,
          'Mobile money payment initiated! Check your phone for the prompt.',
        );
        // Show instructions for mobile money payment
        _showMobileMoneyInstructions(provider);
      } else {
        _showSnackBar(
          context,
          'Mobile money payment failed: ${response.gatewayResponse ?? 'Unknown error'}',
          isError: true,
        );
      }
    } on PaystackError catch (e) {
      if (!mounted) return;
      log('Mobile money error: ${e.message}', error: e);

      String userMessage;
      switch (e.code) {
        case 'insufficient_balance':
          userMessage = 'Insufficient mobile money balance';
          break;
        case 'invalid_phone':
          userMessage = 'Invalid phone number for this provider';
          break;
        case 'unsupported_network':
          userMessage = 'Mobile network not supported for this provider';
          break;
        default:
          userMessage = e.message;
      }

      _showSnackBar(context, userMessage, isError: true);
    } on ArgumentError catch (e) {
      if (!mounted) return;
      _showSnackBar(context, e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      log('Unexpected mobile money error: $e');
      _showSnackBar(
        context,
        'An unexpected error occurred. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  void _showMobileMoneyInstructions(MobileMoneyProvider provider) {
    String instructions = '';

    switch (provider) {
      case MobileMoneyProvider.mpesa:
        instructions =
            '1. Check your phone for the M-Pesa prompt\n2. Enter your M-Pesa PIN\n3. Confirm the payment\n4. Payment will be verified automatically';
        break;
      case MobileMoneyProvider.airtel:
        instructions =
            '1. Check your phone for the Airtel Money prompt\n2. Enter your Airtel Money PIN\n3. Confirm the payment\n4. Payment will be verified automatically';
        break;
      case MobileMoneyProvider.vodafone:
        instructions =
            '1. Check your phone for the Vodafone Cash prompt\n2. Enter your Vodafone Cash PIN\n3. Confirm the payment\n4. Payment will be verified automatically';
        break;
      case MobileMoneyProvider.tigo:
        instructions =
            '1. Check your phone for the Tigo Cash prompt\n2. Enter your Tigo Cash PIN\n3. Confirm the payment\n4. Payment will be verified automatically';
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${provider.name.toUpperCase()} Payment Instructions'),
          content: Text(instructions),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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
    try {
      _showSnackBar(context, 'Getting payment status...');
      final response = await AllPaystackPayments.getPaymentStatus(reference);
      if (!mounted) return;

      String statusMessage;
      String currencySymbol = '₦'; // Default to Naira

      switch (response.currency) {
        case Currency.usd:
          currencySymbol = '\$';
          break;
        case Currency.ghs:
          currencySymbol = '₵';
          break;
        case Currency.zar:
          currencySymbol = 'R';
          break;
        case Currency.kes:
          currencySymbol = 'KSh';
          break;
        default:
          currencySymbol = '₦';
      }

      switch (response.status) {
        case PaymentStatus.success:
          statusMessage = 'Payment completed successfully';
          break;
        case PaymentStatus.failed:
          statusMessage = 'Payment failed';
          break;
        case PaymentStatus.pending:
          statusMessage = 'Payment is still pending';
          break;
        case PaymentStatus.cancelled:
          statusMessage = 'Payment was cancelled';
          break;
      }

      _showSnackBar(
        context,
        'Status: $statusMessage (Amount: $currencySymbol${(response.amount / 100).toStringAsFixed(2)})',
      );
    } on PaystackError catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        'Failed to get status: ${e.message}',
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        context,
        'Unexpected error: ${e.toString()}',
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
                onPressed: (_isInitialized && !_isProcessingPayment)
                    ? _handleCardPayment
                    : null,
                child: _isProcessingPayment
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)?.payWithCard ??
                            'Pay with Card',
                      ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_isInitialized && !_isProcessingPayment)
                    ? _handleBankTransfer
                    : null,
                child: _isProcessingPayment
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)?.payWithBankTransfer ??
                            'Pay with Bank Transfer',
                      ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_isInitialized && !_isProcessingPayment)
                    ? _handleMobileMoney
                    : null,
                child: _isProcessingPayment
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
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
              const SizedBox(height: 32),
              Text(
                'Payment Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized ? _handleGetPaymentStatus : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text(
                  AppLocalizations.of(context)?.getPaymentStatus ??
                      'Get Payment Status',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized ? _handleVerifyPayment : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(
                  AppLocalizations.of(context)?.verifyPayment ??
                      'Verify Payment',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
