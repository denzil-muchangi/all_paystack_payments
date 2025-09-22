// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Paystack Payments Example';

  @override
  String get readyToAcceptPayments => 'Ready to accept payments';

  @override
  String get initializing => 'Initializing...';

  @override
  String get cardPayment => 'Card Payment';

  @override
  String get bankTransfer => 'Bank Transfer';

  @override
  String get mobileMoney => 'Mobile Money';

  @override
  String get email => 'Email';

  @override
  String get amountKobo => 'Amount (kobo)';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get expiryMonth => 'Expiry Month (MM)';

  @override
  String get expiryYear => 'Expiry Year (YY)';

  @override
  String get cvv => 'CVV';

  @override
  String get cardHolderName => 'Card Holder Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get provider => 'Provider';

  @override
  String get cancel => 'Cancel';

  @override
  String get pay => 'Pay';

  @override
  String get initiateTransfer => 'Initiate Transfer';

  @override
  String get payWithCard => 'Pay with Card';

  @override
  String get payWithBankTransfer => 'Pay with Bank Transfer';

  @override
  String get payWithMobileMoney => 'Pay with Mobile Money';

  @override
  String get required => 'Required';

  @override
  String get processingCardPayment => 'Processing card payment...';

  @override
  String paymentStatus(String status, String response) {
    return 'Payment $status: $response';
  }

  @override
  String paymentFailed(String message) {
    return 'Payment failed: $message';
  }

  @override
  String unexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get initiatingBankTransfer => 'Initiating bank transfer...';

  @override
  String transferStatus(String status, String response) {
    return 'Transfer $status: $response';
  }

  @override
  String transferFailed(String message) {
    return 'Transfer failed: $message';
  }

  @override
  String get processingMobileMoney => 'Processing mobile money payment...';

  @override
  String get paystackInitialized => 'Paystack initialized successfully';

  @override
  String paystackInitFailed(String error) {
    return 'Failed to initialize Paystack: $error';
  }
}
