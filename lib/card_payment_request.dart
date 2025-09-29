import 'enums.dart';
import 'payment_request.dart';
import 'validation_utils.dart';

/// Payment request for card payments.
///
/// This class represents a debit/credit card payment request with secure tokenization.
/// All sensitive card data is automatically sanitized and validated before processing.
///
/// ## Properties
/// - [cardNumber]: Card number (13-19 digits, automatically sanitized and validated)
/// - [expiryMonth]: Expiry month (MM format)
/// - [expiryYear]: Expiry year (YY or YYYY format)
/// - [cvv]: Card verification value (3-4 digits)
/// - [cardHolderName]: Name on the card (automatically sanitized)
/// - [pin]: Optional PIN for debit cards (4 digits)
///
/// ## Security
/// Card details are never stored locally and are immediately tokenized by Paystack's
/// PCI DSS compliant infrastructure.
///
/// ## Example
/// ```dart
/// final request = CardPaymentRequest(
///   amount: 50000, // ₦500.00
///   currency: Currency.ngn,
///   email: 'customer@example.com',
///   cardNumber: '4084084084084081',
///   expiryMonth: '12',
///   expiryYear: '25',
///   cvv: '408',
///   cardHolderName: 'John Doe',
///   pin: '1234', // Optional for debit cards
///   reference: 'card_payment_123',
/// );
///
/// final response = await AllPaystackPayments.initializePayment(request);
/// ```
class CardPaymentRequest extends PaymentRequest {
  /// Card number (will be tokenized by Paystack)
  final String cardNumber;

  /// Card expiry month (MM)
  final String expiryMonth;

  /// Card expiry year (YY or YYYY)
  final String expiryYear;

  /// Card CVV
  final String cvv;

  /// Card holder's name
  final String cardHolderName;

  /// PIN for debit cards (optional)
  final String? pin;

  CardPaymentRequest({
    required super.amount,
    required super.currency,
    required super.email,
    super.reference,
    super.metadata,
    super.callbackUrl,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardHolderName,
    this.pin,
  }) : cardNumber = ValidationUtils.sanitizeString(
         cardNumber,
       ).replaceAll(RegExp(r'\s+'), ''),
       expiryMonth = ValidationUtils.sanitizeString(expiryMonth),
       expiryYear = ValidationUtils.sanitizeString(expiryYear),
       cvv = ValidationUtils.sanitizeString(cvv),
       cardHolderName = ValidationUtils.sanitizeString(cardHolderName),
       super(paymentMethod: PaymentMethod.card);

  @override
  Map<String, dynamic> getSpecificJson() {
    return {
      'card': {
        'number': cardNumber,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'cvv': cvv,
        'holder_name': cardHolderName,
        'pin': pin,
      },
    };
  }

  @override
  void validate() {
    super.validate();

    // Validate card number
    if (cardNumber.isEmpty) {
      throw ArgumentError('Card number is required');
    }
    if (!ValidationUtils.isValidCardNumber(cardNumber)) {
      throw ArgumentError('Invalid card number format or checksum');
    }

    // Validate expiry date
    if (!ValidationUtils.isValidExpiryDate(expiryMonth, expiryYear)) {
      throw ArgumentError('Invalid or expired card expiry date');
    }

    // Validate CVV
    if (!ValidationUtils.isValidCvv(cvv)) {
      throw ArgumentError('CVV must be 3 or 4 digits');
    }

    // Validate card holder name
    if (cardHolderName.isEmpty || cardHolderName.length < 2) {
      throw ArgumentError(
        'Card holder name must be at least 2 characters long',
      );
    }

    // Validate PIN if provided
    if (pin != null &&
        (pin!.isEmpty ||
            pin!.length != 4 ||
            !RegExp(r'^\d{4}$').hasMatch(pin!))) {
      throw ArgumentError('PIN must be exactly 4 digits if provided');
    }
  }
}
