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
  String get initializationSuccess => 'Paystack initialisé avec succès. Prêt à accepter les paiements.';

  @override
  String initializationFailed(Object message) {
    return 'Échec de l\'initialisation de Paystack : $message';
  }

  @override
  String unexpectedError(Object error) {
    return 'Erreur inattendue: $error';
  }

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
  String get required => 'Requis';

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
  String get pay => 'Payer';

  @override
  String get processingCardPayment => 'Traitement du paiement par carte...';

  @override
  String paymentStatus(Object status, Object gatewayResponse) {
    return 'Paiement $status: $gatewayResponse';
  }

  @override
  String paymentFailed(Object message) {
    return 'Échec du paiement: $message';
  }

  @override
  String invalidCardDetails(Object message) {
    return 'Détails de carte invalides: $message';
  }

  @override
  String get initiatingBankTransfer => 'Initiation du virement bancaire...';

  @override
  String transferStatus(Object status, Object gatewayResponse) {
    return 'Transfert $status: $gatewayResponse';
  }

  @override
  String transferFailed(Object message) {
    return 'Échec du transfert: $message';
  }

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get provider => 'Fournisseur';

  @override
  String get processingMobileMoney => 'Traitement du paiement mobile...';

  @override
  String get onlyMpesaSupported => 'Seul M-Pesa est pris en charge pour le Kenya';

  @override
  String get verifyPayment => 'Vérifier le paiement';

  @override
  String get reference => 'Référence';

  @override
  String get verify => 'Vérifier';

  @override
  String get verifyingPayment => 'Vérification du paiement...';

  @override
  String verificationFailed(Object message) {
    return 'Échec de la vérification du paiement: $message';
  }

  @override
  String get getPaymentStatus => 'Obtenir le statut du paiement';

  @override
  String get getStatus => 'Obtenir le statut';

  @override
  String get gettingPaymentStatus => 'Obtention du statut du paiement...';

  @override
  String getStatusFailed(Object message) {
    return 'Échec de l\'obtention du statut: $message';
  }

  @override
  String get cancelPayment => 'Annuler le paiement';

  @override
  String get cancellingPayment => 'Annulation du paiement...';

  @override
  String get paymentCancelledSuccessfully => 'Paiement annulé avec succès.';

  @override
  String get paymentCancellationFailed => 'Échec de l\'annulation du paiement.';

  @override
  String cancellationFailed(Object message) {
    return 'Échec de l\'annulation: $message';
  }

  @override
  String get payWithCard => 'Payer par carte';

  @override
  String get payWithBankTransfer => 'Payer par virement bancaire';

  @override
  String get payWithMobileMoney => 'Payer avec Mobile Money';

  @override
  String get initiateTransfer => 'Initier le transfert';

  @override
  String get currency => 'Devise';

  @override
  String get cancel => 'Annuler';

  @override
  String get invalidCardNumber => 'Numéro de carte invalide';

  @override
  String get invalidPhoneNumber => 'Numéro de téléphone invalide (inclure le code pays)';
}
