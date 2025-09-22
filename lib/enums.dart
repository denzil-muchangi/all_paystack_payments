/// Payment method types supported by Paystack
enum PaymentMethod { card, bankTransfer, mobileMoney }

/// Currency codes supported by Paystack
enum Currency { ngn, usd, ghs, zar, kes }

/// Payment status values
enum PaymentStatus { pending, success, failed, cancelled }

/// Mobile money providers supported by Paystack
enum MobileMoneyProvider { mpesa, airtel, vodafone, tigo }

/// Bank transfer types
enum BankTransferType { account, otp }
