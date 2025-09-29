import 'enums.dart';
import 'payment_request.dart';
import 'validation_utils.dart';

/// Payment request for mobile money payments.
///
/// This class represents a mobile money payment request for wallets like M-Pesa, Airtel Money,
/// Vodafone Cash, and Tigo Cash. The customer will receive a prompt on their mobile device.
///
/// ## Properties
/// - [provider]: Mobile money provider ([MobileMoneyProvider])
/// - [phoneNumber]: Customer's phone number with country code
///
/// ## Supported Providers
/// - [MobileMoneyProvider.mpesa]: M-Pesa (Kenya, requires KES)
/// - [MobileMoneyProvider.airtel]: Airtel Money (multiple countries)
/// - [MobileMoneyProvider.vodafone]: Vodafone Cash (Ghana, requires GHS)
/// - [MobileMoneyProvider.tigo]: Tigo Cash (Ghana, requires GHS)
///
/// ## Example
/// ```dart
/// final request = MobileMoneyRequest(
///   amount: 25000, // ₦250.00
///   currency: Currency.ngn,
///   email: 'customer@example.com',
///   provider: MobileMoneyProvider.mpesa,
///   phoneNumber: '+254712345678',
///   reference: 'mobile_money_123',
/// );
///
/// final response = await AllPaystackPayments.initializePayment(request);
/// ```
class MobileMoneyRequest extends PaymentRequest {
  /// Mobile money provider
  final MobileMoneyProvider provider;

  /// Phone number associated with the mobile money account
  final String phoneNumber;

  MobileMoneyRequest({
    required super.amount,
    required super.currency,
    required super.email,
    super.reference,
    super.metadata,
    super.callbackUrl,
    required this.provider,
    required String phoneNumber,
  }) : phoneNumber = ValidationUtils.sanitizeString(phoneNumber),
       super(paymentMethod: PaymentMethod.mobileMoney);

  @override
  Map<String, dynamic> getSpecificJson() {
    return {
      'mobile_money': {'provider': provider.name, 'phone_number': phoneNumber},
    };
  }

  @override
  void validate() {
    super.validate();

    if (phoneNumber.isEmpty) {
      throw ArgumentError('Phone number is required for mobile money payments');
    }

    if (!ValidationUtils.isValidPhoneNumber(phoneNumber)) {
      throw ArgumentError(
        'Phone number must be in E.164 format (e.g., +1234567890) and be valid',
      );
    }

    // Validate provider-specific requirements
    switch (provider) {
      case MobileMoneyProvider.mpesa:
        // M-Pesa is primarily for Kenya, so check for Kenyan numbers
        if (!phoneNumber.startsWith('+254')) {
          throw ArgumentError(
            'M-Pesa payments require a Kenyan phone number (+254)',
          );
        }
        break;
      case MobileMoneyProvider.airtel:
      case MobileMoneyProvider.vodafone:
      case MobileMoneyProvider.tigo:
        // These are primarily for Ghana, so check for Ghanaian numbers
        if (!phoneNumber.startsWith('+233')) {
          throw ArgumentError(
            '${provider.name} payments require a Ghanaian phone number (+233)',
          );
        }
        break;
    }
  }
}
