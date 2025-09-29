/// Payment method types supported by Paystack.
///
/// This enum defines the available payment methods that can be used with the plugin.
/// Each payment method has different characteristics and supported currencies.
enum PaymentMethod {
  /// Debit/credit card payments with secure tokenization
  card,

  /// Direct bank transfer to generated account details
  bankTransfer,

  /// Mobile money wallet payments (M-Pesa, Airtel, etc.)
  mobileMoney,
}

/// Currency codes supported by Paystack.
///
/// Paystack supports multiple currencies across different African countries.
/// The currency affects available payment methods and formatting.
enum Currency {
  /// Nigerian Naira (₦)
  ngn,

  /// US Dollar ($)
  usd,

  /// Ghanaian Cedi (₵)
  ghs,

  /// South African Rand (R)
  zar,

  /// Kenyan Shilling (KSh)
  kes,
}

/// Payment status values.
///
/// This enum represents the possible states of a payment transaction throughout its lifecycle.
enum PaymentStatus {
  /// Payment is being processed or awaiting completion
  pending,

  /// Payment completed successfully
  success,

  /// Payment failed or was declined
  failed,

  /// Payment was cancelled before completion
  cancelled,
}

/// Mobile money providers supported by Paystack.
///
/// Each provider supports different countries and may require specific currencies.
/// Phone number format and validation rules vary by provider.
enum MobileMoneyProvider {
  /// M-Pesa (Kenya) - requires KES currency and +254 phone numbers
  mpesa,

  /// Airtel Money (Kenya, Tanzania, Uganda)
  airtel,

  /// Vodafone Cash (Ghana) - requires GHS currency
  vodafone,

  /// Tigo Cash (Ghana) - requires GHS currency
  tigo,
}

/// Bank transfer types.
///
/// Defines the different types of bank transfer flows supported by Paystack.
enum BankTransferType {
  /// Standard account-based transfer
  account,

  /// OTP-based transfer verification
  otp,
}
