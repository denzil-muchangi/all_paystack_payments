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
  String get initializationSuccess => 'Paystack initialized successfully. Ready to accept payments.';

  @override
  String initializationFailed(Object message) {
    return 'Paystack initialization failed: $message';
  }

  @override
  String unexpectedError(Object error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get cardPayment => 'Card Payment';

  @override
  String get bankTransfer => 'Bank Transfer';

  @override
  String get mobileMoney => 'Mobile Money';

  @override
  String get email => 'Email';

  @override
  String get amountKobo => 'Amount (in kobo)';

  @override
  String get required => 'Required';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get expiryMonth => 'Expiry Month';

  @override
  String get expiryYear => 'Expiry Year';

  @override
  String get cvv => 'CVV';

  @override
  String get cardHolderName => 'Card Holder Name';

  @override
  String get pay => 'Pay';

  @override
  String get processingCardPayment => 'Processing card payment...';

  @override
  String paymentStatus(Object status, Object gatewayResponse) {
    return 'Payment $status: $gatewayResponse';
  }

  @override
  String paymentFailed(Object message) {
    return 'Payment failed: $message';
  }

  @override
  String invalidCardDetails(Object message) {
    return 'Invalid card details: $message';
  }

  @override
  String get initiatingBankTransfer => 'Initiating bank transfer...';

  @override
  String transferStatus(Object status, Object gatewayResponse) {
    return 'Transfer $status: $gatewayResponse';
  }

  @override
  String transferFailed(Object message) {
    return 'Bank transfer failed: $message';
  }

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get provider => 'Provider';

  @override
  String get processingMobileMoney => 'Processing mobile money payment...';

  @override
  String get onlyMpesaSupported => 'Only M-Pesa supported for Kenya';

  @override
  String get verifyPayment => 'Verify Payment';

  @override
  String get reference => 'Reference';

  @override
  String get verify => 'Verify';

  @override
  String get verifyingPayment => 'Verifying payment...';

  @override
  String verificationFailed(Object message) {
    return 'Payment verification failed: $message';
  }

  @override
  String get getPaymentStatus => 'Get Payment Status';

  @override
  String get getStatus => 'Get Status';

  @override
  String get gettingPaymentStatus => 'Getting payment status...';

  @override
  String getStatusFailed(Object message) {
    return 'Failed to get payment status: $message';
  }

  @override
  String get cancelPayment => 'Cancel Payment';

  @override
  String get cancellingPayment => 'Cancelling payment...';

  @override
  String get paymentCancelledSuccessfully => 'Payment cancelled successfully.';

  @override
  String get paymentCancellationFailed => 'Payment cancellation failed.';

  @override
  String cancellationFailed(Object message) {
    return 'Payment cancellation failed: $message';
  }

  @override
  String get payWithCard => 'Pay with Card';

  @override
  String get payWithBankTransfer => 'Pay with Bank Transfer';

  @override
  String get payWithMobileMoney => 'Pay with Mobile Money';

  @override
  String get initiateTransfer => 'Initiate Transfer';

  @override
  String get currency => 'Currency';

  @override
  String get cancel => 'Cancel';

  @override
  String get invalidCardNumber => 'Invalid card number';

  @override
  String get invalidPhoneNumber => 'Invalid phone number (include country code)';
}
