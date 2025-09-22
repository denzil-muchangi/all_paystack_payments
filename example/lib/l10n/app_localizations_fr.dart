// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Exemple de paiements Paystack';

  @override
  String get readyToAcceptPayments => 'Prêt à accepter les paiements';

  @override
  String get initializing => 'Initialisation...';

  @override
  String get cardPayment => 'Paiement par carte';

  @override
  String get bankTransfer => 'Virement bancaire';

  @override
  String get mobileMoney => 'Argent mobile';

  @override
  String get email => 'E-mail';

  @override
  String get amountKobo => 'Montant (kobo)';

  @override
  String get cardNumber => 'Numéro de carte';

  @override
  String get expiryMonth => 'Mois d\'expiration (MM)';

  @override
  String get expiryYear => 'Année d\'expiration (AA)';

  @override
  String get cvv => 'CVV';

  @override
  String get cardHolderName => 'Nom du titulaire de la carte';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get provider => 'Fournisseur';

  @override
  String get cancel => 'Annuler';

  @override
  String get pay => 'Payer';

  @override
  String get initiateTransfer => 'Initier le transfert';

  @override
  String get payWithCard => 'Payer par carte';

  @override
  String get payWithBankTransfer => 'Payer par virement bancaire';

  @override
  String get payWithMobileMoney => 'Payer avec de l\'argent mobile';

  @override
  String get required => 'Requis';

  @override
  String get processingCardPayment => 'Traitement du paiement par carte...';

  @override
  String paymentStatus(String status, String response) {
    return 'Paiement $status: $response';
  }

  @override
  String paymentFailed(String message) {
    return 'Échec du paiement: $message';
  }

  @override
  String unexpectedError(String error) {
    return 'Erreur inattendue: $error';
  }

  @override
  String get initiatingBankTransfer => 'Initiation du virement bancaire...';

  @override
  String transferStatus(String status, String response) {
    return 'Transfert $status: $response';
  }

  @override
  String transferFailed(String message) {
    return 'Échec du transfert: $message';
  }

  @override
  String get processingMobileMoney => 'Traitement du paiement mobile...';

  @override
  String get paystackInitialized => 'Paystack initialisé avec succès';

  @override
  String paystackInitFailed(String error) {
    return 'Échec de l\'initialisation de Paystack: $error';
  }
}
