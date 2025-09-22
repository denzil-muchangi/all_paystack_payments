import 'enums.dart';
import 'payment_request.dart';

/// Payment request for mobile money payments
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
    required this.phoneNumber,
  }) : super(paymentMethod: PaymentMethod.mobileMoney);

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

    // Basic phone number validation (should start with country code)
    if (!phoneNumber.startsWith('+') || phoneNumber.length < 10) {
      throw ArgumentError(
        'Phone number must include country code and be valid',
      );
    }
  }
}
