# All Paystack Payments - Comprehensive API Documentation

This document provides detailed API documentation for the `all_paystack_payments` Flutter plugin, including comprehensive code examples, error handling patterns, and best practices for production use.

## Table of Contents

- [Getting Started](#getting-started)
- [API Overview](#api-overview)
- [Payment Methods](#payment-methods)
  - [Card Payments](#card-payments)
  - [Bank Transfer Payments](#bank-transfer-payments)
  - [Mobile Money Payments](#mobile-money-payments)
- [Payment Management](#payment-management)
  - [Payment Verification](#payment-verification)
  - [Payment Status Checking](#payment-status-checking)
  - [Payment Cancellation](#payment-cancellation)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)

## Getting Started

### Initialization

Before using any payment methods, initialize the plugin with your Paystack public key:

```dart
import 'package:all_paystack_payments/all_paystack_payments.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with your Paystack public key
  // Use test key for development: pk_test_...
  // Use live key for production: pk_live_...
  await AllPaystackPayments.initialize('pk_test_your_public_key_here');

  runApp(MyApp());
}
```

### Environment Setup

- **Development**: Use Paystack test keys and test card numbers
- **Production**: Use live keys and implement proper error handling
- **Security**: Never hardcode keys; use environment variables or secure storage

## API Overview

The plugin provides a type-safe, async API with comprehensive error handling:

### Main Classes

- `AllPaystackPayments`: Main API class with static methods
- `PaymentResponse`: Response object containing payment details and status
- `PaystackError`: Custom exception for Paystack-specific errors
- `PaymentRequest`: Base class for payment requests
- `CardPaymentRequest`, `BankTransferRequest`, `MobileMoneyRequest`: Specific request types

### Enums

- `PaymentMethod`: card, bankTransfer, mobileMoney
- `PaymentStatus`: pending, success, failed, cancelled
- `Currency`: ngn, usd, ghs, zar, kes
- `MobileMoneyProvider`: mpesa, airtel, vodafone, tigo

## Payment Methods

### Card Payments

Process debit/credit card payments with secure tokenization.

#### Basic Card Payment

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
      await handlePaymentSuccess(response);
    } else {
      print('Payment failed: ${response.gatewayResponse}');
      // Handle failure - show error message
      await handlePaymentFailure(response);
    }
  } on PaystackError catch (e) {
    print('Paystack Error: ${e.message}');
    if (e.code != null) {
      print('Error Code: ${e.code}');
    }
    // Handle Paystack-specific errors
  } catch (e) {
    print('General Error: $e');
    // Handle network, validation, or other errors
  }
}
```

#### Card Payment with All Options

```dart
final response = await AllPaystackPayments.initializeCardPayment(
  amount: 100000,
  email: 'customer@example.com',
  cardNumber: '4084084084084081',
  expiryMonth: '12',
  expiryYear: '25',
  cvv: '408',
  cardHolderName: 'John Doe',
  reference: 'custom_ref_${DateTime.now().millisecondsSinceEpoch}',
  pin: '1234', // Required for some debit cards
  currency: Currency.ngn,
  metadata: {
    'order_id': '12345',
    'customer_type': 'premium',
    'custom_field': 'value'
  },
  callbackUrl: 'https://yourapp.com/payment/callback',
);
```

#### Card Validation

The plugin includes built-in validation. For additional client-side validation:

```dart
import 'package:all_paystack_payments/validation_utils.dart';

bool isValidCard = ValidationUtils.isValidCardNumber('4084084084084081');
bool isValidExpiry = ValidationUtils.isValidExpiryDate('12', '25');
bool isValidCvv = ValidationUtils.isValidCvv('408');
```

### Bank Transfer Payments

Generate account details for customers to transfer money directly from their bank accounts.

#### Basic Bank Transfer

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
      await displayBankDetails(response);
    } else {
      print('Transfer failed: ${response.gatewayResponse}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

#### Bank Transfer with Options

```dart
final response = await AllPaystackPayments.initializeBankTransfer(
  amount: 500000,
  email: 'customer@example.com',
  currency: Currency.ngn,
  reference: 'bank_transfer_${DateTime.now().millisecondsSinceEpoch}',
  metadata: {
    'invoice_id': 'INV-001',
    'payment_type': 'deposit'
  },
  callbackUrl: 'https://yourapp.com/bank-transfer/callback',
);
```

#### Displaying Bank Details

```dart
Future<void> displayBankDetails(PaymentResponse response) async {
  // The rawResponse contains bank account details
  final rawData = response.rawResponse;
  if (rawData != null && rawData['data'] != null) {
    final data = rawData['data'];
    final accountNumber = data['account_number'];
    final bankName = data['bank_name'];
    final accountName = data['account_name'];

    // Display these details to the user
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bank Transfer Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bank: $bankName'),
            Text('Account Name: $accountName'),
            Text('Account Number: $accountNumber'),
            Text('Amount: ₦${response.amount / 100}'),
            SizedBox(height: 16),
            Text('Please transfer the exact amount to this account within 30 minutes.'),
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

### Mobile Money Payments

Accept payments from mobile money wallets (M-Pesa, Airtel Money, etc.).

#### Basic Mobile Money Payment

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
      await showMobileMoneyInstructions();
    } else {
      print('Mobile money payment failed: ${response.gatewayResponse}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

#### Mobile Money with All Options

```dart
final response = await AllPaystackPayments.initializeMobileMoney(
  amount: 100000,
  email: 'customer@example.com',
  provider: MobileMoneyProvider.mpesa,
  phoneNumber: '+254712345678',
  currency: Currency.kes, // For M-Pesa, use KES
  reference: 'mobile_money_${DateTime.now().millisecondsSinceEpoch}',
  metadata: {
    'user_id': 'user123',
    'service_type': 'premium_subscription'
  },
  callbackUrl: 'https://yourapp.com/mobile-money/callback',
);
```

#### Supported Providers and Countries

| Provider | Countries | Currency | Phone Format |
|----------|-----------|----------|--------------|
| M-Pesa | Kenya | KES | +254XXXXXXXXX |
| Airtel Money | Kenya, Tanzania, Uganda | KES, TZS, UGX | +254/+255/+256XXXXXXXXX |
| Vodafone Cash | Ghana | GHS | +233XXXXXXXXX |
| Tigo Cash | Ghana | GHS | +233XXXXXXXXX |

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
        await handleSuccessfulVerification(response);
        break;
      case PaymentStatus.failed:
        print('Payment verification failed');
        await handleFailedVerification(response);
        break;
      case PaymentStatus.pending:
        print('Payment is still pending verification');
        // Implement retry logic or polling
        await scheduleVerificationRetry(reference);
        break;
      case PaymentStatus.cancelled:
        print('Payment was cancelled');
        await handleCancelledPayment(response);
        break;
    }
  } on PaystackError catch (e) {
    print('Verification error: ${e.message}');
    // Handle verification-specific errors
  } catch (e) {
    print('Network error during verification: $e');
    // Handle network issues
  }
}
```

### Payment Status Checking

Check the current status of any payment without full verification:

```dart
Future<void> checkPaymentStatus(String reference) async {
  try {
    final response = await AllPaystackPayments.getPaymentStatus(reference);

    print('Current status: ${response.status}');
    print('Amount: ${response.amount}');
    print('Currency: ${response.currency}');

    if (response.isPending) {
      // Payment is still processing
      await showPendingStatus();
    } else if (response.isSuccessful) {
      // Payment completed
      await handleCompletedPayment(response);
    }
  } catch (e) {
    print('Error checking status: $e');
  }
}
```

### Payment Cancellation

Cancel pending payments (useful for timeout scenarios):

```dart
Future<void> cancelPendingPayment(String reference) async {
  try {
    final success = await AllPaystackPayments.cancelPayment(reference);
    if (success) {
      print('Payment cancelled successfully');
      await handleCancellationSuccess();
    } else {
      print('Failed to cancel payment - may already be processed');
      await handleCancellationFailure();
    }
  } on PaystackError catch (e) {
    print('Cancellation error: ${e.message}');
    // Handle cancellation errors
  } catch (e) {
    print('Network error during cancellation: $e');
  }
}
```

## Error Handling

### Comprehensive Error Handling Pattern

```dart
Future<void> processPaymentWithFullErrorHandling() async {
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
    // Validation errors (invalid parameters)
    await handleValidationError(e);

  } on FormatException catch (e) {
    // Data format errors
    await handleFormatError(e);

  } catch (e) {
    // Network, timeout, or unexpected errors
    await handleGeneralError(e);
  }
}
```

### Error Response Handling

```dart
Future<void> handlePaymentResponse(PaymentResponse response) async {
  if (response.isSuccessful) {
    // Success
    await showSuccessMessage('Payment successful!');
  } else {
    // Failed with gateway response
    final errorMessage = response.gatewayResponse ?? 'Payment failed';
    await showErrorMessage(errorMessage);
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
    default:
      userMessage = e.message;
  }

  await showErrorMessage(userMessage);
}
```

## Best Practices

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
   // Use async/await properly
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
   // Implement timeouts for long-running operations
   final response = await AllPaystackPayments.initializeCardPayment(...)
       .timeout(Duration(seconds: 30));
   ```

### User Experience Best Practices

1. **Loading States**
   ```dart
   // Show loading during payment processing
   setState(() => _isProcessing = true);
   try {
     final response = await processPayment();
     // Handle response
   } finally {
     setState(() => _isProcessing = false);
   }
   ```

2. **Clear Messaging**
   ```dart
   // Provide clear feedback
   if (response.isPending) {
     showMessage('Payment initiated. Please complete the transaction.');
   } else if (response.isSuccessful) {
     showMessage('Payment successful! Thank you.');
   }
   ```

## Advanced Usage

### Custom Payment Requests

```dart
// Create custom payment request
final customRequest = CardPaymentRequest(
  amount: 50000,
  currency: Currency.ngn,
  email: 'customer@example.com',
  reference: 'custom_ref',
  cardNumber: '4084084084084081',
  expiryMonth: '12',
  expiryYear: '25',
  cvv: '408',
  cardHolderName: 'John Doe',
  metadata: {'custom': 'data'},
);

// Process with custom request
final response = await AllPaystackPayments.initializePayment(customRequest);
```

### Batch Operations

```dart
Future<void> processMultiplePayments(List<PaymentData> payments) async {
  for (final payment in payments) {
    try {
      final response = await AllPaystackPayments.initializeCardPayment(
        amount: payment.amount,
        email: payment.email,
        // ... other parameters
      );

      // Handle individual response
      await handleIndividualPayment(response, payment);

      // Add delay between requests to avoid rate limiting
      await Future.delayed(Duration(milliseconds: 500));

    } catch (e) {
      // Handle individual errors
      await handlePaymentError(e, payment);
    }
  }
}
```

### Webhook Integration

```dart
// Handle webhooks for real-time updates
Future<void> handlePaymentWebhook(Map<String, dynamic> webhookData) async {
  final event = webhookData['event'];
  final data = webhookData['data'];

  switch (event) {
    case 'charge.success':
      await handleSuccessfulCharge(data);
      break;
    case 'charge.failed':
      await handleFailedCharge(data);
      break;
    case 'transfer.success':
      await handleSuccessfulTransfer(data);
      break;
  }
}
```

## Troubleshooting

### Common Issues and Solutions

#### Initialization Issues

**"Plugin not initialized"**
- Ensure `AllPaystackPayments.initialize()` is called before any payment methods
- Call it in `main()` or app startup

**"Invalid public key"**
- Verify the key format (starts with `pk_test_` or `pk_live_`)
- Check for typos in the key
- Ensure using correct environment key

#### Payment Processing Issues

**Card payment fails with "Invalid card details"**
- Verify card number using Luhn algorithm
- Check expiry date format (MM/YY)
- Ensure CVV is 3-4 digits
- Test with Paystack test cards

**Bank transfer account not generated**
- Check Paystack dashboard settings
- Ensure bank transfers are enabled
- Verify account has necessary permissions

**Mobile money payment timeout**
- Confirm phone number includes correct country code
- Verify customer has sufficient balance
- Check if provider is supported in customer's country

#### Verification Issues

**Verification returns "pending"**
- Some payments take time to process
- Implement polling with reasonable intervals (30s, 1m, 5m)
- Consider using webhooks for real-time updates

**Verification fails with network error**
- Implement retry logic with exponential backoff
- Check device network connectivity
- Verify API key permissions

### Debug Mode

Enable detailed logging for troubleshooting:

```dart
import 'dart:developer';

Future<void> debugPaymentProcess() async {
  try {
    final response = await AllPaystackPayments.initializeCardPayment(...);

    // Log response details (remove in production)
    log('Response: ${response.toString()}');
    log('Raw response: ${response.rawResponse}');

  } catch (e) {
    log('Error: $e');
  }
}
```

### Testing

Use Paystack test credentials for development:

```dart
// Test keys (replace with your actual test keys)
const testPublicKey = 'pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

// Test card numbers
const testCards = {
  'success': '4084084084084081',
  'declined': '4084084084084082',
  'insufficient_funds': '4084084084084083',
};
```

### Platform-Specific Issues

**Android**: Ensure internet permission in `AndroidManifest.xml`

**iOS**: Configure App Transport Security in `Info.plist`

**Web**: No additional setup required

**Desktop**: Ensure network access and proper TLS support

---

For more examples, see the [example app](example/) and [README.md](README.md) for quick start guides.