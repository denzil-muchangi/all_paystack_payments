import 'package:mockito/annotations.dart';
import 'package:all_paystack_payments/all_paystack_payments_platform_interface.dart';
import 'package:all_paystack_payments/webview_payment_handler.dart';

// Generate mocks for all platform interfaces
@GenerateMocks([AllPaystackPaymentsPlatform, WebViewPaymentHandler])
void main() {}
