import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:all_paystack_payments/all_paystack_payments.dart';
import 'package:all_paystack_payments/all_paystack_payments_platform_interface.dart';
import 'package:all_paystack_payments/all_paystack_payments_method_channel.dart';
import 'mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAllPaystackPaymentsPlatform mockPlatform;
  late MockWebViewPaymentHandler mockWebViewHandler;

  setUp(() {
    mockPlatform = MockAllPaystackPaymentsPlatform();
    mockWebViewHandler = MockWebViewPaymentHandler();

    // Set up the mock platform
    AllPaystackPaymentsPlatform.instance = mockPlatform;
  });

  tearDown(() {
    // Reset to default implementation
    AllPaystackPaymentsPlatform.instance = MethodChannelAllPaystackPayments();
  });

  group('Error Scenarios - Card Payments', () {
    setUp(() {
      when(
        mockPlatform.getCheckoutUrl(any),
      ).thenAnswer((_) async => 'https://checkout.paystack.com/test');
    });

    test('throws ArgumentError for invalid card number', () async {
      expect(
        () => AllPaystackPayments.initializeCardPayment(
          amount: 1000,
          email: 'test@example.com',
          cardNumber: 'invalid',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for expired card', () async {
      expect(
        () => AllPaystackPayments.initializeCardPayment(
          amount: 1000,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '01',
          expiryYear: '20', // Past year
          cvv: '123',
          cardHolderName: 'John Doe',
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for invalid CVV', () async {
      expect(
        () => AllPaystackPayments.initializeCardPayment(
          amount: 1000,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '12', // Too short
          cardHolderName: 'John Doe',
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for empty card holder name', () async {
      expect(
        () => AllPaystackPayments.initializeCardPayment(
          amount: 1000,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: '', // Empty
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for invalid PIN', () async {
      expect(
        () => AllPaystackPayments.initializeCardPayment(
          amount: 1000,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
          pin: '123', // Too short
        ),
        throwsArgumentError,
      );
    });

    test('throws PaystackError on card declined', () async {
      when(mockWebViewHandler.processPayment(any)).thenThrow(
        PaystackError(message: 'Card declined', code: 'card_declined'),
      );

      expect(
        () => AllPaystackPayments.initializeCardPayment(
          amount: 1000,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        ),
        throwsA(isA<PaystackError>()),
      );
    });

    test('throws PaystackError on insufficient funds', () async {
      when(mockWebViewHandler.processPayment(any)).thenThrow(
        PaystackError(
          message: 'Insufficient funds',
          code: 'insufficient_funds',
        ),
      );

      expect(
        () => AllPaystackPayments.initializeCardPayment(
          amount: 1000,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        ),
        throwsA(isA<PaystackError>()),
      );
    });
  });

  group('Error Scenarios - Bank Transfer', () {
    setUp(() {
      when(
        mockPlatform.getCheckoutUrl(any),
      ).thenAnswer((_) async => 'https://checkout.paystack.com/bank');
    });

    // Bank transfer validation is handled at the request level, not API level
    // These validations are tested in payment_request_test.dart

    test('throws PaystackError on bank transfer failure', () async {
      when(mockWebViewHandler.processPayment(any)).thenThrow(
        PaystackError(message: 'Bank transfer failed', code: 'bank_error'),
      );

      expect(
        () => AllPaystackPayments.initializeBankTransfer(
          amount: 1000,
          email: 'test@example.com',
        ),
        throwsA(isA<PaystackError>()),
      );
    });
  });

  group('Error Scenarios - Mobile Money', () {
    setUp(() {
      when(
        mockPlatform.getCheckoutUrl(any),
      ).thenAnswer((_) async => 'https://checkout.paystack.com/mobile');
    });

    test('throws ArgumentError for empty phone number', () async {
      expect(
        () => AllPaystackPayments.initializeMobileMoney(
          amount: 1000,
          email: 'test@example.com',
          provider: MobileMoneyProvider.mpesa,
          phoneNumber: '', // Empty
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for invalid phone format', () async {
      expect(
        () => AllPaystackPayments.initializeMobileMoney(
          amount: 1000,
          email: 'test@example.com',
          provider: MobileMoneyProvider.mpesa,
          phoneNumber: '0712345678', // Missing country code
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for M-Pesa with non-Kenyan number', () async {
      expect(
        () => AllPaystackPayments.initializeMobileMoney(
          amount: 1000,
          email: 'test@example.com',
          provider: MobileMoneyProvider.mpesa,
          phoneNumber: '+1234567890', // Not Kenyan
        ),
        throwsArgumentError,
      );
    });

    test('throws PaystackError on insufficient mobile money balance', () async {
      when(mockWebViewHandler.processPayment(any)).thenThrow(
        PaystackError(
          message: 'Insufficient balance',
          code: 'insufficient_balance',
        ),
      );

      expect(
        () => AllPaystackPayments.initializeMobileMoney(
          amount: 1000,
          email: 'test@example.com',
          provider: MobileMoneyProvider.airtel,
          phoneNumber: '+233501234567',
        ),
        throwsA(isA<PaystackError>()),
      );
    });

    test('throws PaystackError on invalid phone number for provider', () async {
      when(mockWebViewHandler.processPayment(any)).thenThrow(
        PaystackError(message: 'Invalid phone number', code: 'invalid_phone'),
      );

      expect(
        () => AllPaystackPayments.initializeMobileMoney(
          amount: 1000,
          email: 'test@example.com',
          provider: MobileMoneyProvider.mpesa,
          phoneNumber: '+254712345678',
        ),
        throwsA(isA<PaystackError>()),
      );
    });
  });

  group('Error Scenarios - General API Errors', () {
    test('throws PaystackError on initialization failure', () async {
      when(
        mockPlatform.initialize(any),
      ).thenThrow(PaystackError(message: 'Init failed', code: 'INIT_ERROR'));

      expect(
        () => AllPaystackPayments.initialize('invalid_key'),
        throwsA(isA<PaystackError>()),
      );
    });

    test('throws PaystackError on verification failure', () async {
      when(mockPlatform.verifyPayment(any)).thenThrow(
        PaystackError(message: 'Verification failed', code: 'VERIFY_ERROR'),
      );

      expect(
        () => AllPaystackPayments.verifyPayment('invalid_ref'),
        throwsA(isA<PaystackError>()),
      );
    });

    test('throws PaystackError on status check failure', () async {
      when(mockPlatform.getPaymentStatus(any)).thenThrow(
        PaystackError(message: 'Status check failed', code: 'STATUS_ERROR'),
      );

      expect(
        () => AllPaystackPayments.getPaymentStatus('invalid_ref'),
        throwsA(isA<PaystackError>()),
      );
    });

    test('throws PaystackError on cancellation failure', () async {
      when(mockPlatform.cancelPayment(any)).thenThrow(
        PaystackError(message: 'Cancellation failed', code: 'CANCEL_ERROR'),
      );

      expect(
        () => AllPaystackPayments.cancelPayment('invalid_ref'),
        throwsA(isA<PaystackError>()),
      );
    });
  });

  group('Error Scenarios - Network and Timeout', () {
    setUp(() {
      when(
        mockPlatform.getCheckoutUrl(any),
      ).thenAnswer((_) async => 'https://checkout.paystack.com/test');
    });

    test('throws TimeoutException on payment timeout', () async {
      when(
        mockWebViewHandler.processPayment(any),
      ).thenThrow(TimeoutException('Payment timed out'));

      expect(
        () => AllPaystackPayments.initializeCardPayment(
          amount: 1000,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('throws Exception on network failure', () async {
      when(
        mockWebViewHandler.processPayment(any),
      ).thenThrow(Exception('Network error'));

      expect(
        () => AllPaystackPayments.initializeCardPayment(
          amount: 1000,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Error Scenarios - Validation Edge Cases', () {
    test('throws ArgumentError for zero amount', () async {
      expect(
        () => AllPaystackPayments.initializeCardPayment(
          amount: 0, // Invalid amount
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for negative amount', () async {
      expect(
        () => AllPaystackPayments.initializeCardPayment(
          amount: -100, // Invalid amount
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for empty email', () async {
      expect(
        () => AllPaystackPayments.initializeCardPayment(
          amount: 1000,
          email: '', // Invalid email
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for invalid email format', () async {
      expect(
        () => AllPaystackPayments.initializeCardPayment(
          amount: 1000,
          email: 'invalid-email', // Invalid email
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for invalid expiry month', () async {
      expect(
        () => AllPaystackPayments.initializeCardPayment(
          amount: 1000,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '13', // Invalid month
          expiryYear: '25',
          cvv: '123',
          cardHolderName: 'John Doe',
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for invalid expiry year format', () async {
      expect(
        () => AllPaystackPayments.initializeCardPayment(
          amount: 1000,
          email: 'test@example.com',
          cardNumber: '4111111111111111',
          expiryMonth: '12',
          expiryYear: '123', // Invalid format
          cvv: '123',
          cardHolderName: 'John Doe',
        ),
        throwsArgumentError,
      );
    });
  });

  group('Error Scenarios - Currency and Provider Validation', () {
    test('throws ArgumentError for M-Pesa with non-KES currency', () async {
      expect(
        () => AllPaystackPayments.initializeMobileMoney(
          amount: 1000,
          email: 'test@example.com',
          provider: MobileMoneyProvider.mpesa,
          phoneNumber: '+254712345678',
          currency: Currency.ngn, // Should be KES for M-Pesa
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for Vodafone with non-GHS currency', () async {
      expect(
        () => AllPaystackPayments.initializeMobileMoney(
          amount: 1000,
          email: 'test@example.com',
          provider: MobileMoneyProvider.vodafone,
          phoneNumber: '+233501234567',
          currency: Currency.ngn, // Should be GHS for Vodafone
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for Tigo with non-GHS currency', () async {
      expect(
        () => AllPaystackPayments.initializeMobileMoney(
          amount: 1000,
          email: 'test@example.com',
          provider: MobileMoneyProvider.tigo,
          phoneNumber: '+233501234567',
          currency: Currency.ngn, // Should be GHS for Tigo
        ),
        throwsArgumentError,
      );
    });
  });
}
