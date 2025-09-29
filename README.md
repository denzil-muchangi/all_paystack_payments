# All Paystack Payments

[![pub package](https://img.shields.io/pub/v/all_paystack_payments.svg)](https://pub.dev/packages/all_paystack_payments)
[![Test Coverage](https://img.shields.io/badge/coverage-80%2B%25-brightgreen.svg)](https://github.com/xeplas/all_paystack_payments)
[![CI/CD](https://img.shields.io/github/actions/workflow/status/xeplas/all_paystack_payments/ci.yml?branch=main)](https://github.com/xeplas/all_paystack_payments/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.3+-02569B.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2.svg)](https://dart.dev)

A comprehensive Flutter plugin for integrating Paystack payment services, supporting card payments, bank transfers, and mobile money transactions across multiple platforms including Android, iOS, Web, Windows, Linux, and macOS.

## Screenshots

### Payment Method Selection
![Payment Method Selection](screenshots/screenshot_1.png)
*Example app showing available payment methods*

### Card Payment Form
![Card Payment Form](screenshots/screenshot_2.png)
*Secure card payment form with validation*

### Bank Transfer Details
![Bank Transfer Details](screenshots/screenshot_3.png)
*Bank account details for transfer payments*

## Table of Contents

- [Quick Start](#quick-start)
- [Features](#features)
- [Supported Platforms](#supported-platforms)
- [Installation & Setup](#installation--setup)
- [Payment Methods](#payment-methods)
  - [Card Payments](#card-payments)
  - [Bank Transfer Payments](#bank-transfer-payments)
  - [Mobile Money Payments](#mobile-money-payments)
- [Payment Management](#payment-management)
- [Error Handling](#error-handling)
- [Testing & Quality Assurance](#testing--quality-assurance)
- [Best Practices & Security](#best-practices--security)
- [Troubleshooting](#troubleshooting)
- [Migration Guide](#migration-guide)
- [API Reference](#api-reference)
- [Example App](#example-app)
- [Contributing](#contributing)
- [Support](#support)

## Quick Start

> **New to Paystack?** Follow our [step-by-step setup guide](#installation--setup) with screenshots to get started in minutes.

```dart
import 'package:all_paystack_payments/all_paystack_payments.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with your Paystack public key
  await AllPaystackPayments.initialize('pk_test_your_public_key_here');

  runApp(MyApp());
}

// Process a payment
Future<void> processPayment() async {
  final response = await AllPaystackPayments.initializeCardPayment(
    amount: 50000, // ₦500.00 in kobo
    email: 'customer@example.com',
    cardNumber: '4084084084084081',
    expiryMonth: '12',
    expiryYear: '25',
    cvv: '408',
    cardHolderName: 'John Doe',
  );

  if (response.isSuccessful) {
    print('Payment successful: ${response.reference}');
  } else {
    print('Payment failed: ${response.gatewayResponse}');
  }
}
```

## Features

- **🔐 Secure Payment Processing**: PCI DSS compliant card tokenization and secure payment flows (see [SECURITY.md](SECURITY.md))
- **💳 Multiple Payment Methods**: Support for debit/credit cards, bank transfers, and mobile money
- **🌍 Multi-Currency Support**: NGN, USD, GHS, ZAR, KES
- **📱 Cross-Platform**: Works seamlessly on Android, iOS, Web, Windows, Linux, and macOS
- **🔍 Transaction Verification**: Built-in methods for real-time payment verification and status checking
- **⚡ Type-Safe APIs**: Strongly typed Dart APIs with comprehensive enums
- **🛡️ Error Handling**: Robust error handling with detailed error messages and custom exceptions
- **🎯 Easy Integration**: Simple, intuitive API design for quick implementation
- **🔄 Payment Management**: Cancel payments and check payment status programmatically
- **📊 Comprehensive Logging**: Debug mode support for troubleshooting
- **🧪 Enterprise-Grade Testing**: 80%+ test coverage with automated CI/CD, performance benchmarks, and comprehensive error scenario testing
- **🚀 Production Ready**: Extensive validation, security testing, and cross-platform compatibility verification

## Supported Platforms

| Platform | Minimum Version | Status | Setup Required |
|----------|-----------------|--------|----------------|
| Android | API 21 (Android 5.0) | ✅ Fully Supported | Internet permission |
| iOS | 11.0 | ✅ Fully Supported | App Transport Security |
| Web | Modern browsers | ✅ Fully Supported | None |
| Windows | Windows 10+ | ✅ Fully Supported | None |
| Linux | Ubuntu 18.04+ | ✅ Fully Supported | None |
| macOS | 10.14+ | ✅ Fully Supported | Network entitlements |

## Installation & Setup

### Step 1: Add the Dependency

Add `all_paystack_payments` to your `pubspec.yaml` file:

```yaml
dependencies:
  all_paystack_payments: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### Step 2: Get Your Paystack Keys

1. **Sign up/Login** to your [Paystack Dashboard](https://dashboard.paystack.com/)
2. **Navigate** to Settings → API Keys & Webhooks
3. **Copy** your public key:
   - **Test Mode**: `pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
   - **Live Mode**: `pk_live_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

> **⚠️ Security Note**: Never commit API keys to version control. Use environment variables or secure storage.

### Step 3: Initialize the Plugin

Initialize the plugin in your `main.dart` before using any payment methods:

```dart
import 'package:all_paystack_payments/all_paystack_payments.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with your Paystack public key
  await AllPaystackPayments.initialize('pk_test_your_public_key_here');

  runApp(MyApp());
}
```

### Step 4: Platform-Specific Setup

#### Android Setup

Add internet permission to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <!-- ... other permissions -->
</manifest>
```

**Screenshot: Android Manifest Setup**
```
📱 [Screenshot showing AndroidManifest.xml with internet permission added]
```

#### iOS Setup

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

**Screenshot: iOS Info.plist Setup**
```
📱 [Screenshot showing Info.plist with NSAppTransportSecurity configuration]
```

#### Web Setup

No additional setup required. The plugin automatically handles web integration using Paystack's secure inline.js library.

#### Windows/Linux/macOS Setup

No additional configuration needed. These platforms have built-in network access.

### Step 5: Test Your Setup

Run the example app to verify everything works:

```bash
cd example
flutter run
```

**Screenshot: Example App Running**
```
📱 [Screenshot of the example app showing payment options]
```

## Payment Methods

### Card Payments

Accept debit and credit card payments with secure tokenization.

#### Basic Implementation

```dart
Future<void> processCardPayment() async {
  try {
    final response = await AllPaystackPayments.initializeCardPayment(
      amount: 50000, // Amount in kobo (₦500.00)
      email: 'customer@example.com',
      cardNumber: '4084084084084081', // Test card
      expiryMonth: '12',
      expiryYear: '25',
      cvv: '408',
      cardHolderName: 'John Doe',
    );

    if (response.isSuccessful) {
      print('Payment successful: ${response.reference}');
      // Handle success - update UI, navigate to success screen
    } else {
      print('Payment failed: ${response.gatewayResponse}');
      // Handle failure - show error message
    }
  } catch (e) {
    print('Error: $e');
    // Handle error
  }
}
```

#### Advanced Implementation with Validation

```dart
class CardPaymentForm extends StatefulWidget {
  @override
  _CardPaymentFormState createState() => _CardPaymentFormState();
}

class _CardPaymentFormState extends State<CardPaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _amountController = TextEditingController();

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final response = await AllPaystackPayments.initializeCardPayment(
        amount: int.parse(_amountController.text),
        email: _emailController.text,
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        expiryMonth: _expiryMonthController.text,
        expiryYear: _expiryYearController.text,
        cvv: _cvvController.text,
        cardHolderName: _cardHolderController.text,
        reference: 'card_${DateTime.now().millisecondsSinceEpoch}',
        metadata: {
          'order_id': '12345',
          'customer_type': 'premium',
        },
      );

      if (response.isSuccessful) {
        _showSuccessDialog(response.reference!);
      } else {
        _showErrorDialog(response.gatewayResponse ?? 'Payment failed');
      }
    } on PaystackError catch (e) {
      _showErrorDialog(e.message);
    } catch (e) {
      _showErrorDialog('An unexpected error occurred');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  String? _validateCardNumber(String? value) {
    if (value?.isEmpty ?? true) return 'Card number is required';
    if (!ValidationUtils.isValidCardNumber(value!)) {
      return 'Invalid card number';
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    if (value?.isEmpty ?? true) return 'Required';
    if (!ValidationUtils.isValidExpiryDate(
      _expiryMonthController.text,
      _expiryYearController.text,
    )) {
      return 'Invalid expiry date';
    }
    return null;
  }

  String? _validateCvv(String? value) {
    if (value?.isEmpty ?? true) return 'CVV is required';
    if (!ValidationUtils.isValidCvv(value!)) {
      return 'Invalid CVV (3-4 digits)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Email is required' : null,
          ),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(labelText: 'Amount (kobo)'),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Amount is required' : null,
          ),
          TextFormField(
            controller: _cardNumberController,
            decoration: InputDecoration(labelText: 'Card Number'),
            keyboardType: TextInputType.number,
            validator: _validateCardNumber,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryMonthController,
                  decoration: InputDecoration(labelText: 'MM'),
                  validator: _validateExpiry,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _expiryYearController,
                  decoration: InputDecoration(labelText: 'YY'),
                  validator: _validateExpiry,
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _cvvController,
            decoration: InputDecoration(labelText: 'CVV'),
            validator: _validateCvv,
          ),
          TextFormField(
            controller: _cardHolderController,
            decoration: InputDecoration(labelText: 'Card Holder Name'),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Name is required' : null,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            child: _isProcessing
                ? CircularProgressIndicator()
                : Text('Pay Now'),
          ),
        ],
      ),
    );
  }
}
```

**Test Card Numbers:**
- Success: `4084084084084081`
- Declined: `4084084084084082`
- Insufficient Funds: `4084084084084083`

### Bank Transfer Payments

Generate account details for customers to transfer money directly from their bank accounts.

#### Basic Implementation

```dart
Future<void> processBankTransfer() async {
  try {
    final response = await AllPaystackPayments.initializeBankTransfer(
      amount: 100000, // ₦1,000.00 in kobo
      email: 'customer@example.com',
    );

    if (response.isSuccessful) {
      print('Transfer initiated: ${response.reference}');
      // Display bank account details to customer
      _showBankDetails(response);
    } else {
      print('Transfer failed: ${response.gatewayResponse}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

void _showBankDetails(PaymentResponse response) {
  final rawData = response.rawResponse;
  if (rawData != null && rawData['data'] != null) {
    final data = rawData['data'];
    final bankName = data['bank_name'];
    final accountNumber = data['account_number'];
    final accountName = data['account_name'];

    // Display these details to the user
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bank Transfer Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bank: $bankName'),
            Text('Account Name: $accountName'),
            Text('Account Number: $accountNumber'),
            Text('Amount: ₦${response.amount / 100}'),
            SizedBox(height: 16),
            Text('Please transfer the exact amount within 30 minutes.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

#### Advanced Implementation with Status Polling

```dart
class BankTransferPayment extends StatefulWidget {
  @override
  _BankTransferPaymentState createState() => _BankTransferPaymentState();
}

class _BankTransferPaymentState extends State<BankTransferPayment> {
  PaymentResponse? _paymentResponse;
  Timer? _statusTimer;

  Future<void> _initiateTransfer() async {
    final response = await AllPaystackPayments.initializeBankTransfer(
      amount: 50000,
      email: 'customer@example.com',
      reference: 'bank_transfer_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (response.isSuccessful) {
      setState(() => _paymentResponse = response);
      _startStatusPolling(response.reference!);
      _showBankDetailsDialog(response);
    }
  }

  void _startStatusPolling(String reference) {
    _statusTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      try {
        final statusResponse = await AllPaystackPayments.verifyPayment(reference);
        if (statusResponse.isSuccessful) {
          _statusTimer?.cancel();
          _showSuccessDialog();
        } else if (statusResponse.status == PaymentStatus.failed) {
          _statusTimer?.cancel();
          _showFailureDialog();
        }
      } catch (e) {
        print('Status check failed: $e');
      }
    });
  }

  void _showBankDetailsDialog(PaymentResponse response) {
    // Implementation as above
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _initiateTransfer,
          child: Text('Pay with Bank Transfer'),
        ),
        if (_paymentResponse != null)
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Transfer initiated. Please complete the transfer.'),
          ),
      ],
    );
  }
}
```

### Mobile Money Payments

Accept payments from mobile money wallets (M-Pesa, Airtel Money, etc.).

#### Basic Implementation

```dart
Future<void> processMobileMoneyPayment() async {
  try {
    final response = await AllPaystackPayments.initializeMobileMoney(
      amount: 25000, // ₦250.00 in kobo
      email: 'customer@example.com',
      provider: MobileMoneyProvider.mpesa,
      phoneNumber: '+254712345678',
    );

    if (response.isSuccessful) {
      print('Mobile money payment initiated: ${response.reference}');
      // Customer will receive a prompt on their mobile device
      _showMobileMoneyInstructions();
    } else {
      print('Mobile money payment failed: ${response.gatewayResponse}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

void _showMobileMoneyInstructions() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Mobile Money Payment'),
      content: Text(
        '1. Check your phone for the payment prompt\n'
        '2. Enter your mobile money PIN\n'
        '3. Confirm the payment\n'
        '4. Payment will be verified automatically'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

#### Supported Providers and Countries

| Provider | Countries | Currency | Phone Format | Notes |
|----------|-----------|----------|--------------|-------|
| M-Pesa | Kenya | KES | +254XXXXXXXXX | Most popular in Kenya |
| Airtel Money | Kenya, Tanzania, Uganda | KES, TZS, UGX | +254/+255/+256XXXXXXXXX | Regional coverage |
| Vodafone Cash | Ghana | GHS | +233XXXXXXXXX | Ghana only |
| Tigo Cash | Ghana | GHS | +233XXXXXXXXX | Ghana only |

## Payment Management

### Payment Verification

Always verify payment status after initiation to confirm completion:

```dart
Future<void> verifyPayment(String reference) async {
  try {
    final response = await AllPaystackPayments.verifyPayment(reference);

    switch (response.status) {
      case PaymentStatus.success:
        print('Payment verified successfully');
        // Update order status, deliver product, etc.
        await handleSuccessfulPayment(response);
        break;
      case PaymentStatus.failed:
        print('Payment verification failed');
        await handleFailedPayment(response);
        break;
      case PaymentStatus.pending:
        print('Payment is still pending');
        // Implement retry logic or polling
        await scheduleVerificationRetry(reference);
        break;
      case PaymentStatus.cancelled:
        print('Payment was cancelled');
        await handleCancelledPayment(response);
        break;
    }
  } catch (e) {
    print('Verification error: $e');
  }
}
```

### Payment Status Checking

Check the current status without full verification:

```dart
Future<void> checkPaymentStatus(String reference) async {
  try {
    final response = await AllPaystackPayments.getPaymentStatus(reference);

    print('Current status: ${response.status}');
    print('Amount: ${response.amount}');
    print('Currency: ${response.currency}');

    if (response.isPending) {
      // Payment is still processing
    } else if (response.isSuccessful) {
      // Payment completed
    }
  } catch (e) {
    print('Error checking status: $e');
  }
}
```

### Payment Cancellation

Cancel pending payments:

```dart
Future<void> cancelPendingPayment(String reference) async {
  try {
    final success = await AllPaystackPayments.cancelPayment(reference);
    if (success) {
      print('Payment cancelled successfully');
    } else {
      print('Failed to cancel payment');
    }
  } catch (e) {
    print('Error cancelling payment: $e');
  }
}
```

## Testing & Quality Assurance

This plugin includes a comprehensive testing suite to ensure reliability and developer confidence. All tests are automatically run in CI/CD pipelines.

### 🧪 Test Coverage

- **Unit Tests**: Core business logic, validation, and utilities
- **Integration Tests**: Platform channel communication and API interactions
- **Widget Tests**: UI components and user interaction flows
- **Performance Tests**: Load testing and performance benchmarks
- **Error Scenario Tests**: Comprehensive failure case coverage
- **Edge Case Tests**: Boundary values and special character handling

### 📊 Quality Metrics

| Metric | Value | Description |
|--------|-------|-------------|
| **Test Coverage** | 80%+ | Minimum coverage threshold enforced |
| **Platforms Tested** | 6 | Android, iOS, Web, Windows, Linux, macOS |
| **Test Categories** | 8 | Unit, Integration, Widget, Performance, Error, Edge, Security, E2E |
| **CI/CD Status** | ✅ | Automated testing on every commit |

### 🛠️ Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test groups
flutter test --tags integration    # Integration tests only
flutter test --exclude-tags slow   # Exclude slow tests

# Run example app tests
cd example && flutter test
```

### 🔍 Test Categories

#### Unit Tests
```dart
// Core validation testing
test('card number validation', () {
  expect(ValidationUtils.isValidCardNumber('4111111111111111'), true);
  expect(ValidationUtils.isValidCardNumber('invalid'), false);
});

// API method testing with mocks
test('card payment initialization', () async {
  when(mockPlatform.getCheckoutUrl(any)).thenAnswer((_) async => checkoutUrl);
  when(mockWebViewHandler.processPayment(any)).thenAnswer((_) async => mockResponse);

  final result = await AllPaystackPayments.initializeCardPayment(...);
  expect(result.isSuccessful, true);
});
```

#### Integration Tests
```dart
// Platform channel testing
test('method channel communication', () async {
  final platform = MethodChannelAllPaystackPayments();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    if (methodCall.method == 'initializePayment') {
      return {'status': 'success', 'reference': 'test_ref'};
    }
    return null;
  });

  final response = await platform.initializePayment(request);
  expect(response.status, PaymentStatus.success);
});
```

#### Widget Tests
```dart
// UI interaction testing
testWidgets('payment form validation', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: PaymentForm()));

  // Enter invalid data
  await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  // Verify error message appears
  expect(find.text('Please enter a valid email'), findsOneWidget);
});
```

#### Performance Tests
```dart
// Load testing
test('bulk validation performance', () {
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < 1000; i++) {
    ValidationUtils.isValidCardNumber('4111111111111111');
  }

  stopwatch.stop();
  final timePerValidation = stopwatch.elapsedMicroseconds / 1000;
  expect(timePerValidation, lessThan(1000)); // < 1ms per validation
});
```

#### Error Scenario Tests
```dart
// Comprehensive error handling
test('handles all payment failure scenarios', () async {
  // Test card declined
  when(mockWebViewHandler.processPayment(any))
      .thenThrow(PaystackError(message: 'Card declined', code: 'card_declined'));

  expect(
    () => AllPaystackPayments.initializeCardPayment(...),
    throwsA(isA<PaystackError>()),
  );

  // Test network timeout
  when(mockWebViewHandler.processPayment(any))
      .thenThrow(TimeoutException('Payment timed out'));

  expect(
    () => AllPaystackPayments.initializeCardPayment(...),
    throwsA(isA<TimeoutException>()),
  );
});
```

### 🔒 Security Testing

```dart
// Input sanitization testing
test('prevents XSS attacks', () {
  final maliciousInput = '<script>alert("xss")</script>';
  final sanitized = ValidationUtils.sanitizeString(maliciousInput);
  expect(sanitized, doesNotContain('<script>'));
});

// SQL injection prevention
test('handles malicious SQL input', () {
  final sqlInjection = "'; DROP TABLE users; --";
  final sanitized = ValidationUtils.sanitizeString(sqlInjection);
  expect(ValidationUtils.isValidEmail(sanitized), false);
});
```

### 🚀 CI/CD Integration

The plugin uses GitHub Actions for automated testing:

```yaml
# .github/workflows/ci.yml
jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: flutter test --coverage
      - run: dart tool/check_coverage.dart  # Custom coverage checker
```

### 📈 Coverage Reporting

Test coverage is automatically calculated and reported:

```bash
flutter test --coverage
# Generates coverage/lcov.info

# View HTML report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 🐛 Debugging Test Failures

Enable detailed logging for test debugging:

```dart
import 'dart:developer';

void main() {
  // Enable test logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    log('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Run your tests
  test('debug test', () async {
    log('Starting test...');
    // Test code here
  });
}
```

### 📚 Best Testing Practices

1. **Mock External Dependencies**: Always mock platform interfaces and network calls
2. **Test Edge Cases**: Include boundary values, null inputs, and special characters
3. **Performance Benchmarks**: Set performance expectations and monitor regressions
4. **Cross-Platform Testing**: Ensure tests run on all supported platforms
5. **Error Coverage**: Test all error paths and exception handling
6. **Security Testing**: Validate input sanitization and injection prevention

## Error Handling

The plugin provides comprehensive error handling through the `PaystackError` class:

```dart
Future<void> processPaymentWithErrorHandling() async {
  try {
    final response = await AllPaystackPayments.initializeCardPayment(
      amount: 50000,
      email: 'customer@example.com',
      cardNumber: '4084084084084081',
      expiryMonth: '12',
      expiryYear: '25',
      cvv: '408',
      cardHolderName: 'John Doe',
    );

    // Handle response
    await handlePaymentResponse(response);

  } on PaystackError catch (e) {
    // Paystack API errors
    await handlePaystackError(e);

  } on ArgumentError catch (e) {
    // Validation errors
    await handleValidationError(e);

  } catch (e) {
    // Network, timeout, or unexpected errors
    await handleGeneralError(e);
  }
}

Future<void> handlePaystackError(PaystackError e) async {
  String userMessage;

  switch (e.code) {
    case 'insufficient_funds':
      userMessage = 'Insufficient funds. Please check your account balance.';
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

  await showErrorDialog(userMessage);
}
```

## Best Practices & Security

### Security Best Practices

1. **Key Management**
   ```dart
   // Use environment variables
   const publicKey = String.fromEnvironment('PAYSTACK_PUBLIC_KEY');

   // Or secure storage
   final publicKey = await SecureStorage.getPaystackKey();
   ```

2. **Input Validation**
   ```dart
   // Always validate user input
   if (!ValidationUtils.isValidEmail(email)) {
     throw ArgumentError('Invalid email format');
   }
   ```

3. **Error Logging**
   ```dart
   // Log errors without sensitive data
   catch (e) {
     log('Payment error: ${e.toString()}');
     // Never log: card numbers, CVV, PIN, etc.
   }
   ```

### Performance Best Practices

1. **Async Handling**
   ```dart
   Future<void> processPayment() async {
     showLoadingSpinner();
     try {
       final response = await AllPaystackPayments.initializeCardPayment(...);
       hideLoadingSpinner();
       handleResponse(response);
     } catch (e) {
       hideLoadingSpinner();
       handleError(e);
     }
   }
   ```

2. **Timeout Handling**
   ```dart
   final response = await AllPaystackPayments.initializeCardPayment(...)
       .timeout(Duration(seconds: 30));
   ```

### User Experience Best Practices

1. **Loading States**
   ```dart
   setState(() => _isProcessing = true);
   try {
     final response = await processPayment();
   } finally {
     setState(() => _isProcessing = false);
   }
   ```

2. **Clear Messaging**
   ```dart
   if (response.isPending) {
     showMessage('Payment initiated. Please complete the transaction.');
   } else if (response.isSuccessful) {
     showMessage('Payment successful! Thank you.');
   }
   ```

## Troubleshooting

### Common Issues

**"Invalid public key" error**
- Ensure you're using a valid Paystack public key
- Check that the key matches your environment (test/live)
- Verify the key format (starts with `pk_test_` or `pk_live_`)

**Card payment fails with "Invalid card details"**
- Verify card number format and length
- Check expiry date format (MM/YY)
- Ensure CVV is 3-4 digits
- Test with Paystack test cards

**Mobile money payment not working**
- Verify phone number includes country code
- Check that the provider is supported in the customer's country
- Ensure customer has sufficient balance

**Bank transfer account not generated**
- Check your Paystack dashboard for account generation settings
- Ensure bank transfers are enabled for your account

**Verification returns pending status**
- Some payment methods take time to process
- Implement polling or webhooks for real-time updates
- Check Paystack dashboard for transaction status

### Debug Mode

Enable detailed logging for debugging:

```dart
import 'dart:developer';

Future<void> debugPaymentProcess() async {
  try {
    final response = await AllPaystackPayments.initializeCardPayment(...);

    log('Response: ${response.toString()}');
    log('Raw response: ${response.rawResponse}');

  } catch (e) {
    log('Error: $e');
  }
}
```

### Platform-Specific Issues

**Android**: Ensure internet permission in `AndroidManifest.xml`

**iOS**: Configure App Transport Security in `Info.plist`

**Web**: No additional setup required

**Desktop**: Ensure network access and proper TLS support

## Migration Guide

### Migrating from flutter_paystack

If you're migrating from the `flutter_paystack` plugin:

1. **Update Dependencies**
   ```yaml
   dependencies:
     # Remove this
     # flutter_paystack: ^1.0.0

     # Add this
     all_paystack_payments: ^1.0.0
   ```

2. **Update Imports**
   ```dart
   // Old
   import 'package:flutter_paystack/flutter_paystack.dart';

   // New
   import 'package:all_paystack_payments/all_paystack_payments.dart';
   ```

3. **Update Initialization**
   ```dart
   // Old
   PaystackPlugin.initialize(publicKey: 'pk_test_...');

   // New
   await AllPaystackPayments.initialize('pk_test_...');
   ```

4. **Update Card Payment**
   ```dart
   // Old
   Charge charge = Charge()
     ..amount = 50000
     ..email = 'customer@example.com'
     ..card = PaymentCard(
       number: '4084084084084081',
       cvc: '408',
       expiryMonth: 12,
       expiryYear: 25,
     );

   // New
   final response = await AllPaystackPayments.initializeCardPayment(
     amount: 50000,
     email: 'customer@example.com',
     cardNumber: '4084084084084081',
     expiryMonth: '12',
     expiryYear: '25',
     cvv: '408',
     cardHolderName: 'John Doe',
   );
   ```

5. **Update Response Handling**
   ```dart
   // Old
   if (charge.status == 'success') {
     // Handle success
   }

   // New
   if (response.isSuccessful) {
     // Handle success
   } else {
     // Handle failure
   }
   ```

### Migrating from paystack_manager

1. **Update Dependencies**
   ```yaml
   dependencies:
     all_paystack_payments: ^1.0.0
   ```

2. **Update Method Calls**
   ```dart
   // Old
   PaystackManager.paystackTransaction(...)

   // New
   AllPaystackPayments.initializeCardPayment(...)
   ```

### Key Differences

- **Unified API**: Single plugin for all payment methods
- **Better Error Handling**: Detailed error messages and codes
- **Type Safety**: Strongly typed enums and responses
- **Cross-Platform**: Supports all Flutter platforms
- **Modern Async**: Uses async/await throughout

## API Reference

For detailed API documentation with comprehensive examples, see [USAGE_README.md](USAGE_README.md).

### Key Classes

- [`AllPaystackPayments`](lib/all_paystack_payments.dart) - Main plugin class with all payment methods
- [`PaymentResponse`](lib/payment_response.dart) - Payment response model with status and details
- [`PaystackError`](lib/paystack_error.dart) - Error handling class with detailed error information
- [`PaymentRequest`](lib/payment_request.dart) - Base payment request class
- [`CardPaymentRequest`](lib/card_payment_request.dart) - Card payment request model
- [`BankTransferRequest`](lib/bank_transfer_request.dart) - Bank transfer request model
- [`MobileMoneyRequest`](lib/mobile_money_request.dart) - Mobile money request model

### Main Methods

- `initialize(String publicKey)` - Initialize the plugin with Paystack public key
- `initializeCardPayment(...)` - Process card payments
- `initializeBankTransfer(...)` - Initiate bank transfer payments
- `initializeMobileMoney(...)` - Process mobile money payments
- `initializePayment(PaymentRequest)` - Process custom payment requests
- `verifyPayment(String reference)` - Verify payment completion
- `getPaymentStatus(String reference)` - Check current payment status
- `cancelPayment(String reference)` - Cancel pending payments

### Enums

- [`Currency`](lib/enums.dart) - Supported currencies (NGN, USD, GHS, ZAR, KES)
- [`PaymentMethod`](lib/enums.dart) - Available payment methods (card, bankTransfer, mobileMoney)
- [`PaymentStatus`](lib/enums.dart) - Payment status values (pending, success, failed, cancelled)
- [`MobileMoneyProvider`](lib/enums.dart) - Mobile money providers (mpesa, airtel, vodafone, tigo)
- [`BankTransferType`](lib/enums.dart) - Bank transfer types (account, otp)

## Example App

Check out the [example app](example/) for a complete implementation with UI forms for all payment methods.

To run the example:

```bash
cd example
flutter run
```

**Screenshot: Example App Payment Options**
```
📱 [Screenshot showing the example app with different payment method buttons]
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Support

- 📖 [Documentation](https://pub.dev/packages/all_paystack_payments)
- 🐛 [Issues](https://github.com/your-repo/all_paystack_payments/issues)
- 💬 [Discussions](https://github.com/your-repo/all_paystack_payments/discussions)
- 📧 Contact: support@xeplas.com

## License

This project is licensed under the MIT License, which allows free use, modification, and distribution with proper attribution. See the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

Made with ❤️ for the Flutter community
