import 'enums.dart';
import 'payment_request.dart';

/// Payment request for card payments
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
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.cardHolderName,
    this.pin,
  }) : super(paymentMethod: PaymentMethod.card);

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

    if (cardNumber.isEmpty ||
        cardNumber.length < 13 ||
        cardNumber.length > 19) {
      throw ArgumentError('Invalid card number');
    }

    if (expiryMonth.isEmpty ||
        int.tryParse(expiryMonth) == null ||
        int.parse(expiryMonth) < 1 ||
        int.parse(expiryMonth) > 12) {
      throw ArgumentError('Invalid expiry month');
    }

    if (expiryYear.isEmpty || expiryYear.length < 2 || expiryYear.length > 4) {
      throw ArgumentError('Invalid expiry year');
    }

    if (cvv.isEmpty || cvv.length < 3 || cvv.length > 4) {
      throw ArgumentError('Invalid CVV');
    }

    if (cardHolderName.isEmpty) {
      throw ArgumentError('Card holder name is required');
    }
  }
}
