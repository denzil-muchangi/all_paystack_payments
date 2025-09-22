# All Paystack Payments Flutter Plugin - Usage Guide

A comprehensive Flutter plugin for integrating Paystack payment services, supporting card payments, bank transfers, and mobile money transactions across multiple platforms.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Setup and Initialization](#setup-and-initialization)
- [Usage Examples](#usage-examples)
  - [Card Payments](#card-payments)
  - [Bank Transfer Payments](#bank-transfer-payments)
  - [Mobile Money Payments](#mobile-money-payments)
- [Transaction Verification](#transaction-verification)
- [Error Handling](#error-handling)
- [Platform-Specific Notes](#platform-specific-notes)
- [Troubleshooting](#troubleshooting)

## Overview

The All Paystack Payments plugin provides a unified interface for integrating Paystack's payment services into your Flutter applications. It supports multiple payment methods and currencies, making it easy to accept payments from customers worldwide.

## Features

- **Multiple Payment Methods**: Support for card payments, bank transfers, and mobile money
- **Multi-Currency Support**: NGN, USD, GHS, ZAR, KES
- **Cross-Platform**: Works on Android, iOS, Web, Windows, Linux, and macOS
- **Transaction Verification**: Built-in methods for verifying payment status
- **Error Handling**: Comprehensive error handling with detailed error messages
- **Type Safety**: Strongly typed APIs with enums for better developer experience

## Installation

Add the plugin to your `pubspec.yaml` file:

```yaml
dependencies:
  all_paystack_payments: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Setup and Initialization

Before using any payment methods, you must initialize the plugin with your Paystack public key:

```dart
import 'package:all_paystack_payments/all_paystack_payments.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with your Paystack public key
  await AllPaystackPayments.initialize('pk_test_your_public_key_here');

  runApp(MyApp());
}
```

> **Note**: Always use your test keys during development and switch to live keys for production.

## Usage Examples

### Card Payments

Card payments allow customers to pay using debit or credit cards. The plugin handles card tokenization securely.

```dart
import 'package:all_paystack_payments/all_paystack_payments.dart';

Future<void> processCardPayment() async {
  try {
    final response = await AllPaystackPayments.initializeCardPayment(
      amount: 50000, // Amount in kobo (₦500.00)
      email: 'customer@example.com',
      cardNumber: '4084084084084081',
      expiryMonth: '12',
      expiryYear: '25',
      cvv: '408',
      cardHolderName: 'John Doe',
      reference: 'unique_reference_123', // Optional
      pin: '1234', // Optional for debit cards
      metadata: {'custom_field': 'value'}, // Optional
    );

    if (response.isSuccessful) {
      print('Payment successful: ${response.reference}');
      // Handle successful payment
    } else {
      print('Payment failed: ${response.gatewayResponse}');
      // Handle failed payment
    }
  } catch (e) {
    print('Error: $e');
    // Handle error
  }
}
```

**Parameters:**
- `amount`: Amount in kobo (smallest currency unit). ₦500 = 50000 kobo
- `email`: Customer's email address
- `cardNumber`: Valid card number (13-19 digits)
- `expiryMonth`: Card expiry month (MM format)
- `expiryYear`: Card expiry year (YY or YYYY format)
- `cvv`: Card CVV (3-4 digits)
- `cardHolderName`: Name on the card
- `reference`: Optional unique transaction reference
- `pin`: Optional PIN for debit cards
- `metadata`: Optional additional data
- `callbackUrl`: Optional callback URL for web payments

### Bank Transfer Payments

Bank transfer payments generate account details for customers to transfer money directly from their bank accounts.

```dart
import 'package:all_paystack_payments/all_paystack_payments.dart';

Future<void> processBankTransferPayment() async {
  try {
    final response = await AllPaystackPayments.initializeBankTransfer(
      amount: 100000, // ₦1,000.00 in kobo
      email: 'customer@example.com',
      reference: 'bank_transfer_ref_456', // Optional
      metadata: {'order_id': '12345'}, // Optional
    );

    if (response.isSuccessful) {
      print('Bank transfer initiated: ${response.reference}');
      // Display account details to customer from response.rawResponse
      // The response will contain bank account details for the transfer
    } else {
      print('Bank transfer failed: ${response.gatewayResponse}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

**Note**: Paystack generates the bank account details automatically. The customer will need to transfer the exact amount to the provided account.

### Mobile Money Payments

Mobile money payments allow customers to pay using their mobile money wallets (M-Pesa, Airtel Money, etc.).

```dart
import 'package:all_paystack_payments/all_paystack_payments.dart';

Future<void> processMobileMoneyPayment() async {
  try {
    final response = await AllPaystackPayments.initializeMobileMoney(
      amount: 25000, // ₦250.00 in kobo
      email: 'customer@example.com',
      provider: MobileMoneyProvider.mpesa, // or airtel, vodafone, tigo
      phoneNumber: '+254712345678', // Include country code
      reference: 'mobile_money_ref_789', // Optional
      metadata: {'user_id': 'user123'}, // Optional
    );

    if (response.isSuccessful) {
      print('Mobile money payment initiated: ${response.reference}');
      // Customer will receive a prompt on their mobile device
    } else {
      print('Mobile money payment failed: ${response.gatewayResponse}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

**Supported Providers:**
- `MobileMoneyProvider.mpesa` - M-Pesa (Kenya)
- `MobileMoneyProvider.airtel` - Airtel Money
- `MobileMoneyProvider.vodafone` - Vodafone Cash
- `MobileMoneyProvider.tigo` - Tigo Cash

## Transaction Verification

After initiating a payment, you should verify the transaction status to confirm completion:

```dart
import 'package:all_paystack_payments/all_paystack_payments.dart';

Future<void> verifyPayment(String reference) async {
  try {
    final response = await AllPaystackPayments.verifyPayment(reference);

    switch (response.status) {
      case PaymentStatus.success:
        print('Payment verified successfully');
        // Update order status, deliver product, etc.
        break;
      case PaymentStatus.failed:
        print('Payment verification failed');
        // Handle failed verification
        break;
      case PaymentStatus.pending:
        print('Payment is still pending');
        // Wait and check again later
        break;
      case PaymentStatus.cancelled:
        print('Payment was cancelled');
        // Handle cancellation
        break;
    }
  } catch (e) {
    print('Verification error: $e');
  }
}
```

You can also check payment status without full verification:

```dart
final statusResponse = await AllPaystackPayments.getPaymentStatus(reference);
```

## Error Handling

The plugin provides comprehensive error handling through the `PaystackError` class:

```dart
import 'package:all_paystack_payments/all_paystack_payments.dart';

Future<void> handlePaymentWithErrorHandling() async {
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
  } on PaystackError catch (e) {
    print('Paystack Error: ${e.message}');
    if (e.code != null) {
      print('Error Code: ${e.code}');
    }
    // Handle specific Paystack errors
  } catch (e) {
    print('General Error: $e');
    // Handle other errors (network, validation, etc.)
  }
}
```

**Common Error Scenarios:**
- Invalid card details
- Insufficient funds
- Network connectivity issues
- Invalid API keys
- Amount validation errors

## Platform-Specific Notes

### Android
- Requires minimum API level 21 (Android 5.0)
- Add internet permission to `AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.INTERNET" />
  ```

### iOS
- Requires iOS 11.0 or later
- Add to `ios/Runner/Info.plist`:
  ```xml
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
  </dict>
  ```

### Web
- Works in all modern browsers
- Ensure your Paystack account has web payments enabled
- Callback URLs are supported for web payments

### Desktop (Windows, Linux, macOS)
- Full functionality supported
- Web-based payment flows may open external browsers

## Troubleshooting

### Common Issues

**1. "Invalid public key" error**
- Ensure you're using a valid Paystack public key
- Check that the key matches your environment (test/live)

**2. Card payment fails with "Invalid card details"**
- Verify card number format and length
- Check expiry date format (MM/YY)
- Ensure CVV is 3-4 digits

**3. Mobile money payment not working**
- Verify phone number includes country code
- Check that the provider is supported in the customer's country
- Ensure customer has sufficient balance

**4. Bank transfer account not generated**
- Check your Paystack dashboard for account generation settings
- Ensure bank transfers are enabled for your account

**5. Verification returns pending status**
- Some payment methods take time to process
- Implement polling or webhooks for real-time updates
- Check Paystack dashboard for transaction status

### Debug Mode

Enable detailed logging for debugging:

```dart
// Add this before initialization
import 'dart:developer';

// In your payment methods, log responses
log('Response: ${response.rawResponse}');
```

### Getting Help

- Check the [Paystack Documentation](https://paystack.com/docs)
- Review the plugin's GitHub issues
- Contact Paystack support for API-related issues

---

For more advanced usage and custom implementations, refer to the API documentation in the plugin's source code.