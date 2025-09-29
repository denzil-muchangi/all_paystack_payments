import 'enums.dart';

/// Utility class for input validation and sanitization.
///
/// This class provides static methods for validating and sanitizing user input
/// related to payment processing. It includes validation for emails, phone numbers,
/// card details, amounts, and other payment-related data.
///
/// ## Features
/// - Email format validation
/// - Phone number validation (E.164 format)
/// - Card number validation with Luhn algorithm
/// - CVV and expiry date validation
/// - Amount validation with currency-specific limits
/// - Input sanitization
///
/// ## Example
/// ```dart
/// // Validate card details
/// bool validCard = ValidationUtils.isValidCardNumber('4084084084084081');
/// bool validExpiry = ValidationUtils.isValidExpiryDate('12', '25');
/// bool validCvv = ValidationUtils.isValidCvv('408');
///
/// // Validate amount
/// bool validAmount = ValidationUtils.isValidAmount(50000, Currency.ngn);
/// ```
class ValidationUtils {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');

  static final RegExp _cardNumberRegex = RegExp(r'^\d{13,19}$');

  static final RegExp _cvvRegex = RegExp(r'^\d{3,4}$');

  static final RegExp _expiryRegex = RegExp(r'^\d{2}(?:\d{2})?$');

  /// Sanitize string input by trimming and removing control characters.
  ///
  /// Removes leading/trailing whitespace and control characters that could cause issues.
  /// This helps prevent injection attacks and ensures clean input data.
  ///
  /// ## Parameters
  /// - [input]: The string to sanitize
  ///
  /// ## Returns
  /// A sanitized string with whitespace trimmed and control characters removed.
  static String sanitizeString(String input) {
    return input.trim().replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
  }

  /// Validate email format.
  ///
  /// Checks if the provided string matches standard email format using regex.
  ///
  /// ## Parameters
  /// - [email]: The email address to validate
  ///
  /// ## Returns
  /// `true` if the email format is valid, `false` otherwise.
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }

  /// Validate phone number format (E.164).
  ///
  /// Checks if the phone number follows E.164 international format (+country code).
  /// Supports country codes from 1 to 3 digits and phone numbers up to 14 digits.
  ///
  /// ## Parameters
  /// - [phone]: The phone number to validate (e.g., '+254712345678')
  ///
  /// ## Returns
  /// `true` if the phone number format is valid, `false` otherwise.
  static bool isValidPhoneNumber(String phone) {
    return _phoneRegex.hasMatch(phone);
  }

  /// Validate card number format and Luhn algorithm.
  ///
  /// Performs two validations:
  /// 1. Format check: 13-19 digits only
  /// 2. Luhn algorithm check: Mathematical validation for card number integrity
  ///
  /// ## Parameters
  /// - [cardNumber]: The card number to validate (digits only, no spaces)
  ///
  /// ## Returns
  /// `true` if the card number is valid, `false` otherwise.
  static bool isValidCardNumber(String cardNumber) {
    if (!_cardNumberRegex.hasMatch(cardNumber)) return false;
    return _luhnCheck(cardNumber);
  }

  /// Validate CVV format.
  ///
  /// Checks if the CVV is 3-4 digits (standard for most card types).
  ///
  /// ## Parameters
  /// - [cvv]: The CVV to validate
  ///
  /// ## Returns
  /// `true` if the CVV format is valid, `false` otherwise.
  static bool isValidCvv(String cvv) {
    return _cvvRegex.hasMatch(cvv);
  }

  /// Validate expiry date format and not expired.
  ///
  /// Checks both format and expiration status:
  /// - Format: Month (1-12), Year (2 or 4 digits)
  /// - Expiration: Must not be in the past
  ///
  /// ## Parameters
  /// - [month]: Expiry month (MM format)
  /// - [year]: Expiry year (YY or YYYY format)
  ///
  /// ## Returns
  /// `true` if the expiry date is valid and not expired, `false` otherwise.
  static bool isValidExpiryDate(String month, String year) {
    if (!_expiryRegex.hasMatch(month) || !_expiryRegex.hasMatch(year)) {
      return false;
    }

    final intMonth = int.parse(month);
    if (intMonth < 1 || intMonth > 12) return false;

    final intYear = int.parse(year.length == 2 ? '20$year' : year);
    final now = DateTime.now();
    final expiry = DateTime(intYear, intMonth + 1, 0); // Last day of month

    return expiry.isAfter(now);
  }

  /// Validate amount (must be positive, reasonable limit).
  ///
  /// Ensures the amount is positive and within reasonable limits for the specified currency.
  /// Limits are set based on typical transaction sizes for each currency.
  ///
  /// ## Parameters
  /// - [amount]: The amount to validate (in smallest currency unit, e.g., kobo for NGN)
  /// - [currency]: The currency for amount validation
  ///
  /// ## Returns
  /// `true` if the amount is valid for the currency, `false` otherwise.
  ///
  /// ## Currency Limits
  /// - NGN: Up to 100,000,000.00 (100 million)
  /// - USD: Up to 1,000,000.00 (1 million)
  /// - GHS: Up to 10,000,000.00 (10 million)
  /// - ZAR: Up to 100,000,000.00 (100 million)
  /// - KES: Up to 100,000,000.00 (100 million)
  static bool isValidAmount(int amount, Currency currency) {
    if (amount <= 0) return false;

    // Set maximum amounts based on currency (in smallest units)
    const maxAmounts = {
      Currency.ngn: 10000000000, // 100M NGN
      Currency.usd: 100000000, // 1M USD
      Currency.ghs: 1000000000, // 10M GHS
      Currency.zar: 10000000000, // 100M ZAR
      Currency.kes: 10000000000, // 100M KES
    };

    final maxAmount = maxAmounts[currency] ?? 100000000; // Default 1M
    return amount <= maxAmount;
  }

  /// Luhn algorithm for card number validation
  static bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }
}
