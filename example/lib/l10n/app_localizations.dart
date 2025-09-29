import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// The title of the app
  ///
  /// In en, this message translates to:
  /// **'Paystack Payments Example'**
  String get appTitle;

  /// Status message when Paystack is initialized
  ///
  /// In en, this message translates to:
  /// **'Ready to accept payments'**
  String get readyToAcceptPayments;

  /// Status message during initialization
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// Message for successful Paystack initialization
  ///
  /// In en, this message translates to:
  /// **'Paystack initialized successfully. Ready to accept payments.'**
  String get initializationSuccess;

  /// Message for failed Paystack initialization
  ///
  /// In en, this message translates to:
  /// **'Paystack initialization failed: {message}'**
  String initializationFailed(Object message);

  /// Message for unexpected errors
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String unexpectedError(Object error);

  /// Title for card payment dialog
  ///
  /// In en, this message translates to:
  /// **'Card Payment'**
  String get cardPayment;

  /// Title for bank transfer dialog
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// Title for mobile money dialog
  ///
  /// In en, this message translates to:
  /// **'Mobile Money'**
  String get mobileMoney;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label for amount input field in kobo
  ///
  /// In en, this message translates to:
  /// **'Amount (in kobo)'**
  String get amountKobo;

  /// Validation message for required fields
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Label for card number input field
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// Label for expiry month input field
  ///
  /// In en, this message translates to:
  /// **'Expiry Month'**
  String get expiryMonth;

  /// Label for expiry year input field
  ///
  /// In en, this message translates to:
  /// **'Expiry Year'**
  String get expiryYear;

  /// Label for CVV input field
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// Label for card holder name input field
  ///
  /// In en, this message translates to:
  /// **'Card Holder Name'**
  String get cardHolderName;

  /// Pay button text
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// Message shown while processing card payment
  ///
  /// In en, this message translates to:
  /// **'Processing card payment...'**
  String get processingCardPayment;

  /// Payment status message with placeholders
  ///
  /// In en, this message translates to:
  /// **'Payment {status}: {gatewayResponse}'**
  String paymentStatus(Object status, Object gatewayResponse);

  /// Payment failure message with placeholder
  ///
  /// In en, this message translates to:
  /// **'Payment failed: {message}'**
  String paymentFailed(Object message);

  /// Invalid card details message with placeholder
  ///
  /// In en, this message translates to:
  /// **'Invalid card details: {message}'**
  String invalidCardDetails(Object message);

  /// Message shown while initiating bank transfer
  ///
  /// In en, this message translates to:
  /// **'Initiating bank transfer...'**
  String get initiatingBankTransfer;

  /// Transfer status message with placeholders
  ///
  /// In en, this message translates to:
  /// **'Transfer {status}: {gatewayResponse}'**
  String transferStatus(Object status, Object gatewayResponse);

  /// Transfer failure message with placeholder
  ///
  /// In en, this message translates to:
  /// **'Bank transfer failed: {message}'**
  String transferFailed(Object message);

  /// Label for phone number input field
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Label for mobile money provider dropdown
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// Message shown while processing mobile money payment
  ///
  /// In en, this message translates to:
  /// **'Processing mobile money payment...'**
  String get processingMobileMoney;

  /// Message indicating only M-Pesa is supported
  ///
  /// In en, this message translates to:
  /// **'Only M-Pesa supported for Kenya'**
  String get onlyMpesaSupported;

  /// Title for verify payment dialog
  ///
  /// In en, this message translates to:
  /// **'Verify Payment'**
  String get verifyPayment;

  /// Label for reference input field
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// Verify button text
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// Message shown while verifying payment
  ///
  /// In en, this message translates to:
  /// **'Verifying payment...'**
  String get verifyingPayment;

  /// Payment verification failure message with placeholder
  ///
  /// In en, this message translates to:
  /// **'Payment verification failed: {message}'**
  String verificationFailed(Object message);

  /// Title for get payment status dialog
  ///
  /// In en, this message translates to:
  /// **'Get Payment Status'**
  String get getPaymentStatus;

  /// Get Status button text
  ///
  /// In en, this message translates to:
  /// **'Get Status'**
  String get getStatus;

  /// Message shown while getting payment status
  ///
  /// In en, this message translates to:
  /// **'Getting payment status...'**
  String get gettingPaymentStatus;

  /// Get status failure message with placeholder
  ///
  /// In en, this message translates to:
  /// **'Failed to get payment status: {message}'**
  String getStatusFailed(Object message);

  /// Title for cancel payment dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel Payment'**
  String get cancelPayment;

  /// Message shown while cancelling payment
  ///
  /// In en, this message translates to:
  /// **'Cancelling payment...'**
  String get cancellingPayment;

  /// Message for successful payment cancellation
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled successfully.'**
  String get paymentCancelledSuccessfully;

  /// Message for failed payment cancellation
  ///
  /// In en, this message translates to:
  /// **'Payment cancellation failed.'**
  String get paymentCancellationFailed;

  /// Cancellation failure message with placeholder
  ///
  /// In en, this message translates to:
  /// **'Payment cancellation failed: {message}'**
  String cancellationFailed(Object message);

  /// Button text for card payment
  ///
  /// In en, this message translates to:
  /// **'Pay with Card'**
  String get payWithCard;

  /// Button text for bank transfer payment
  ///
  /// In en, this message translates to:
  /// **'Pay with Bank Transfer'**
  String get payWithBankTransfer;

  /// Button text for mobile money payment
  ///
  /// In en, this message translates to:
  /// **'Pay with Mobile Money'**
  String get payWithMobileMoney;

  /// Initiate transfer button text
  ///
  /// In en, this message translates to:
  /// **'Initiate Transfer'**
  String get initiateTransfer;

  /// Label for currency dropdown
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Error message for invalid card number
  ///
  /// In en, this message translates to:
  /// **'Invalid card number'**
  String get invalidCardNumber;

  /// Error message for invalid phone number
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number (include country code)'**
  String get invalidPhoneNumber;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
