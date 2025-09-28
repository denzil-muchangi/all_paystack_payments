# All Paystack Payments

[![pub package](https://img.shields.io/pub/v/all_paystack_payments.svg)](https://pub.dev/packages/all_paystack_payments)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.3+-02569B.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2.svg)](https://dart.dev)

A comprehensive Flutter plugin for integrating Paystack payment services, supporting card payments, bank transfers, and mobile money transactions across multiple platforms including Android, iOS, Web, Windows, Linux, and macOS.
## Screenshots

![Screenshot 1](screenshots/screenshot_1.png)
![Screenshot 2](screenshots/screenshot_2.png)
![Screenshot 3](screenshots/screenshot_3.png)

*Replace these placeholder images with actual screenshots of your app demonstrating the payment flows.*

## Features

- **🔐 Secure Payment Processing**: PCI DSS compliant card tokenization and secure payment flows
- **💳 Multiple Payment Methods**: Support for debit/credit cards, bank transfers, and mobile money
- **🌍 Multi-Currency Support**: NGN, USD, GHS, ZAR, KES
- **📱 Cross-Platform**: Works seamlessly on Android, iOS, Web, Windows, Linux, and macOS
- **🔍 Transaction Verification**: Built-in methods for real-time payment verification
- **⚡ Type-Safe APIs**: Strongly typed Dart APIs with comprehensive enums
- **🛡️ Error Handling**: Robust error handling with detailed error messages
- **🎯 Easy Integration**: Simple, intuitive API design for quick implementation

## Supported Platforms

| Platform | Minimum Version | Status |
|----------|-----------------|--------|
| Android | API 21 (Android 5.0) | ✅ Fully Supported |
| iOS | 11.0 | ✅ Fully Supported |
| Web | Modern browsers | ✅ Fully Supported |
| Windows | Windows 10+ | ✅ Fully Supported |
| Linux | Ubuntu 18.04+ | ✅ Fully Supported |
| macOS | 10.14+ | ✅ Fully Supported |

## Installation

Add `all_paystack_payments` to your `pubspec.yaml` file:

```yaml
dependencies:
  all_paystack_payments: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### Platform-Specific Setup

#### Android

Add internet permission to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <!-- ... other permissions -->
</manifest>
```

#### iOS

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Quick Start

1. **Initialize the plugin** with your Paystack public key:

```dart
import 'package:all_paystack_payments/all_paystack_payments.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with your Paystack public key
  await AllPaystackPayments.initialize('pk_test_your_public_key_here');

  runApp(MyApp());
}
```

2. **Process a payment**:

```dart
// Card Payment
final response = await AllPaystackPayments.initializeCardPayment(
  amount: 50000, // ₦500.00 in kobo
  email: 'customer@example.com',
  cardNumber: '4084084084084081',
  expiryMonth: '12',
  expiryYear: '25',
  cvv: '408',
  cardHolderName: 'John Doe',
);

// Bank Transfer
final response = await AllPaystackPayments.initializeBankTransfer(
  amount: 100000, // ₦1,000.00 in kobo
  email: 'customer@example.com',
);

// Mobile Money
final response = await AllPaystackPayments.initializeMobileMoney(
  amount: 25000, // ₦250.00 in kobo
  email: 'customer@example.com',
  provider: MobileMoneyProvider.mpesa,
  phoneNumber: '+254712345678',
);
```

## Usage Examples

### Card Payments

Card payments allow customers to pay using debit or credit cards with secure tokenization:

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

### Bank Transfer Payments

Generate account details for customers to transfer money directly from their bank accounts:

```dart
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

### Mobile Money Payments

Accept payments from mobile money wallets (M-Pesa, Airtel Money, etc.):

```dart
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

**Supported Mobile Money Providers:**
- `MobileMoneyProvider.mpesa` - M-Pesa (Kenya)
- `MobileMoneyProvider.airtel` - Airtel Money
- `MobileMoneyProvider.vodafone` - Vodafone Cash
- `MobileMoneyProvider.tigo` - Tigo Cash

## Transaction Verification

Always verify payment status after initiation to confirm completion:

```dart
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

## Error Handling

The plugin provides comprehensive error handling through the `PaystackError` class:

```dart
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

## API Reference

For detailed API documentation, see the [API Reference](https://pub.dev/documentation/all_paystack_payments/latest/).

### Key Classes

- [`AllPaystackPayments`](lib/all_paystack_payments.dart) - Main plugin class
- [`PaymentResponse`](lib/payment_response.dart) - Payment response model
- [`PaystackError`](lib/paystack_error.dart) - Error handling class
- [`PaymentRequest`](lib/payment_request.dart) - Base payment request class

### Enums

- [`Currency`](lib/enums.dart) - Supported currencies
- [`PaymentMethod`](lib/enums.dart) - Available payment methods
- [`PaymentStatus`](lib/enums.dart) - Payment status values
- [`MobileMoneyProvider`](lib/enums.dart) - Mobile money providers

## Example App

Check out the [example app](example/) for a complete implementation with UI forms for all payment methods.

To run the example:

```bash
cd example
flutter run
```

## Testing

The plugin includes comprehensive unit tests. Run tests with:

```bash
flutter test
```

For integration testing:

```bash
flutter test integration_test/
```

## Troubleshooting

### Common Issues

**"Invalid public key" error**
- Ensure you're using a valid Paystack public key
- Check that the key matches your environment (test/live)

**Card payment fails with "Invalid card details"**
- Verify card number format and length
- Check expiry date format (MM/YY)
- Ensure CVV is 3-4 digits

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
// Add this before initialization
import 'dart:developer';

log('Response: ${response.rawResponse}');
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License, which allows free use, modification, and distribution with proper attribution. See the [LICENSE](LICENSE) file for details.

## Support

- 📖 [Documentation](https://pub.dev/packages/all_paystack_payments)
- 🐛 [Issues](https://github.com/your-repo/all_paystack_payments/issues)
- 💬 [Discussions](https://github.com/your-repo/all_paystack_payments/discussions)
- 📧 Contact: support@xeplas.com

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

Made with ❤️ for the Flutter community
