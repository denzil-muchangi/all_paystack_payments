import 'package:flutter_test/flutter_test.dart';
import 'package:all_paystack_payments/all_paystack_payments.dart';

void main() {
  group('PaymentResponse', () {
    test('should create payment response', () {
      final response = PaymentResponse(
        reference: 'test_ref',
        status: PaymentStatus.success,
        amount: 1000,
        currency: Currency.ngn,
        paymentMethod: PaymentMethod.card,
        gatewayResponse: 'Approved',
        rawResponse: {'key': 'value'},
        createdAt: DateTime(2023, 1, 1),
      );

      expect(response.reference, 'test_ref');
      expect(response.status, PaymentStatus.success);
      expect(response.amount, 1000);
      expect(response.currency, Currency.ngn);
      expect(response.paymentMethod, PaymentMethod.card);
      expect(response.gatewayResponse, 'Approved');
      expect(response.rawResponse, {'key': 'value'});
      expect(response.createdAt, DateTime(2023, 1, 1));
      expect(response.isSuccessful, true);
      expect(response.isPending, false);
      expect(response.isFailed, false);
    });

    group('fromApiResponse', () {
      test('should create from valid API response', () {
        final apiResponse = {
          'reference': 'ref123',
          'status': 'success',
          'amount': 2000,
          'currency': 'USD',
          'payment_method': 'card',
          'gateway_response': 'Transaction successful',
          'created_at': '2023-01-01T10:00:00Z',
          'extra_field': 'extra_value',
        };

        final response = PaymentResponse.fromApiResponse(apiResponse);

        expect(response.reference, 'ref123');
        expect(response.status, PaymentStatus.success);
        expect(response.amount, 2000);
        expect(response.currency, Currency.usd);
        expect(response.paymentMethod, PaymentMethod.card);
        expect(response.gatewayResponse, 'Transaction successful');
        expect(response.rawResponse, apiResponse);
        expect(response.createdAt, DateTime.parse('2023-01-01T10:00:00Z'));
      });

      test('should handle missing fields', () {
        final apiResponse = {'status': 'failed', 'currency': 'NGN'};

        final response = PaymentResponse.fromApiResponse(apiResponse);

        expect(response.reference, '');
        expect(response.status, PaymentStatus.failed);
        expect(response.amount, 0);
        expect(response.currency, Currency.ngn);
        expect(response.paymentMethod, PaymentMethod.card);
        expect(response.gatewayResponse, null);
        expect(response.createdAt, null);
      });

      test('should handle null values', () {
        final apiResponse = {
          'reference': null,
          'status': null,
          'amount': null,
          'currency': null,
          'payment_method': null,
        };

        final response = PaymentResponse.fromApiResponse(apiResponse);

        expect(response.reference, '');
        expect(response.status, PaymentStatus.pending);
        expect(response.amount, 0);
        expect(response.currency, Currency.ngn);
        expect(response.paymentMethod, PaymentMethod.card);
      });

      test('should handle invalid date format', () {
        final apiResponse = {
          'reference': 'ref123',
          'status': 'success',
          'amount': 1000,
          'currency': 'NGN',
          'payment_method': 'card',
          'created_at': 'invalid-date',
        };

        expect(
          () => PaymentResponse.fromApiResponse(apiResponse),
          throwsFormatException,
        );
      });
    });

    test('toString should return correct format', () {
      final response = PaymentResponse(
        reference: 'test_ref',
        status: PaymentStatus.success,
        amount: 1000,
        currency: Currency.ngn,
        paymentMethod: PaymentMethod.card,
      );

      expect(
        response.toString(),
        'PaymentResponse(reference: test_ref, status: PaymentStatus.success, amount: 1000, currency: Currency.ngn, paymentMethod: PaymentMethod.card)',
      );
    });

    group('Status getters', () {
      test('isSuccessful should return true for success status', () {
        final response = PaymentResponse(
          reference: 'ref',
          status: PaymentStatus.success,
          amount: 1000,
          currency: Currency.ngn,
          paymentMethod: PaymentMethod.card,
        );

        expect(response.isSuccessful, true);
      });

      test('isPending should return true for pending status', () {
        final response = PaymentResponse(
          reference: 'ref',
          status: PaymentStatus.pending,
          amount: 1000,
          currency: Currency.ngn,
          paymentMethod: PaymentMethod.card,
        );

        expect(response.isPending, true);
      });

      test('isFailed should return true for failed status', () {
        final response = PaymentResponse(
          reference: 'ref',
          status: PaymentStatus.failed,
          amount: 1000,
          currency: Currency.ngn,
          paymentMethod: PaymentMethod.card,
        );

        expect(response.isFailed, true);
      });
    });
  });
}
