// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Deinak';

  @override
  String get appTitle => 'Deinak';

  @override
  String get appDescription => 'Gestion des dettes et prêts';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'S\'inscrire';

  @override
  String get settings => 'Paramètres';

  @override
  String get loans => 'Prêts';

  @override
  String get reports => 'Rapports';

  @override
  String get home => 'Accueil';

  @override
  String get addLoan => 'Ajouter un prêt';

  @override
  String get editLoan => 'Modifier le prêt';

  @override
  String get delete => 'Supprimer';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get borrowerName => 'Nom de l\'emprunteur';

  @override
  String get fullNameLabel => 'Nom complet';

  @override
  String get fullNameRequired => 'Veuillez entrer votre nom complet';

  @override
  String get countryLabel => 'Pays';

  @override
  String get selectCountry => 'Choisir le pays';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get loanDate => 'Date du prêt';

  @override
  String get dueDate => 'Date d\'échéance';

  @override
  String get amount => 'Montant';

  @override
  String get profit => 'Bénéfice';

  @override
  String get total => 'Total';

  @override
  String get notes => 'Notes';

  @override
  String get status => 'Statut';

  @override
  String get active => 'Actif';

  @override
  String get overdue => 'En retard';

  @override
  String get completed => 'Remboursé';

  @override
  String get theme => 'Thème';

  @override
  String get language => 'Langue';

  @override
  String get logout => 'Déconnexion';

  @override
  String get guestUser => 'Invité';

  @override
  String get aboutApp => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get developedBy => 'Développé par';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get enterUsername => 'Entrez le nom d\'utilisateur';

  @override
  String get enterPhoneNumber => 'Entrez le numéro de téléphone';

  @override
  String get enterPassword => 'Entrez le mot de passe';

  @override
  String get usernameRequired => 'Nom d\'utilisateur requis';

  @override
  String get passwordRequired => 'Mot de passe requis';

  @override
  String get noAccount => 'Pas de compte ? S\'inscrire';

  @override
  String get continueAsGuest => 'Continuer en tant qu\'invité';

  @override
  String get invalidPhoneNumber =>
      'Numéro de téléphone invalide. Il doit être composé de 8 chiffres et commencer par 2, 3 ou 4';

  @override
  String get loginError => 'Erreur de connexion';

  @override
  String get totalLentAmount => 'Total prêté';

  @override
  String activeLoansCount(int count) {
    return '$count prêts actifs';
  }

  @override
  String get todayProfitLabel => 'Bénéfices du jour';

  @override
  String get expectedProfitLabel => 'Bénéfices attendus';

  @override
  String overdueLoansTitle(int count) {
    return 'Prêts en retard ($count)';
  }

  @override
  String get recentLoans => 'Prêts récents';

  @override
  String get noActiveLoans => 'Aucun prêt actif';

  @override
  String get newLoan => 'Nouveau prêt';

  @override
  String get guestBannerText =>
      'Vous utilisez l\'application en tant qu\'invité. Données locales.';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get confirmLogout => 'Voulez-vous vous déconnecter ?';

  @override
  String get logoutButton => 'Déconnexion';

  @override
  String get passwordsNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get registerError => 'Erreur d\'inscription';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get createAccount => 'Créer le compte';

  @override
  String get passwordTooShort => '6 caractères minimum';

  @override
  String get confirmPasswordRequired => 'Veuillez confirmer le mot de passe';

  @override
  String get borrowerInfo => 'Infos de l\'emprunteur';

  @override
  String get loanDetails => 'Détails du prêt';

  @override
  String get loanDuration => 'Durée';

  @override
  String get repaymentDate => 'Date de remboursement';

  @override
  String get cardCompany => 'Compagnie de carte';

  @override
  String get cardCategory => 'Catégorie (Valeur)';

  @override
  String get cardCount => 'Nombre de cartes';

  @override
  String get customValue => 'Autre';

  @override
  String get cardValueLabel => 'Valeur de la carte (MRU)';

  @override
  String get profitType => 'Type de bénéfice';

  @override
  String get profitPercentage => 'Pourcentage %';

  @override
  String get fixedAmount => 'Montant fixe';

  @override
  String get profitRate => 'Taux de bénéfice (%)';

  @override
  String get profitAmount => 'Montant du bénéfice (MRU)';

  @override
  String get loanSummary => 'Résumé du prêt';

  @override
  String get totalCardsAmount => 'Total des cartes';

  @override
  String get finalAmount => 'Montant final';

  @override
  String get addNoteHint => 'Ajouter une note (optionnel)...';

  @override
  String get invalidCardValue => 'Veuillez entrer une valeur valide';

  @override
  String get loanUpdated => 'Prêt mis à jour avec succès';

  @override
  String get loanAdded => 'Prêt ajouté avec succès';

  @override
  String get nameRequired => 'Nom requis';

  @override
  String get phoneRequired => 'Téléphone requis';

  @override
  String get cardCountRequired => 'Nombre de cartes requis';

  @override
  String get profitValueRequired => 'Valeur du bénéfice requise';

  @override
  String get confirmPaidTitle => 'Confirmer le paiement';

  @override
  String confirmPaidMessage(String name) {
    return 'Est-ce que $name a payé ?';
  }

  @override
  String get yesPaid => 'Oui, payé';

  @override
  String get no => 'Non';

  @override
  String get paidSuccess => 'Paiement enregistré avec succès';

  @override
  String get confirmDeleteTitle => 'Supprimer le prêt';

  @override
  String confirmDeleteMessage(String name) {
    return 'Voulez-vous supprimer le prêt de $name ?';
  }

  @override
  String get amounts => 'Montants';

  @override
  String get dates => 'Dates';

  @override
  String get company => 'Compagnie';

  @override
  String get categoryAndCount => 'Catégorie × Nombre';

  @override
  String get endsSoon => 'Bientôt fini';

  @override
  String get paidAt => 'Payé le';

  @override
  String get markAsPaid => 'Marquer comme payé';

  @override
  String get overview => 'Aperçu';

  @override
  String get totalLoansCount => 'Total des prêts';

  @override
  String get totalLent => 'Total prêté';

  @override
  String get earnedProfit => 'Bénéfices réalisés';

  @override
  String get monthProfitLabel => 'Bénéfices du mois';

  @override
  String get loanDistribution => 'Répartition des prêts';

  @override
  String get recentCompletedLoansTitle => 'Derniers prêts remboursés';

  @override
  String get noCompletedLoans => 'Aucun prêt remboursé pour le moment';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get profitSuffix => 'bénéfice';

  @override
  String get searchHint => 'Rechercher par nom ou téléphone...';

  @override
  String activeTab(int count) {
    return 'Actifs ($count)';
  }

  @override
  String overdueTab(int count) {
    return 'En retard ($count)';
  }

  @override
  String completedTab(int count) {
    return 'Remboursés ($count)';
  }

  @override
  String get noLoansList => 'Aucun prêt dans cette liste';

  @override
  String get deleteSuccess => 'Prêt supprimé avec succès';

  @override
  String get loanWarningTitle => '⚠️ Avertissement échéance';

  @override
  String loanWarningBody(String name, String amount) {
    return 'Il reste 24h pour le remboursement de $name - Montant: $amount MRU';
  }

  @override
  String get loanDueTitle => '🔴 Échéance aujourd\'hui';

  @override
  String loanDueBody(String name, String amount) {
    return 'C\'est le moment du remboursement de $name - Montant: $amount MRU';
  }

  @override
  String get loading => 'Chargement...';

  @override
  String get slogan => 'Gerez vos prêts et dettes en toute simplicité';

  @override
  String get mauritel => 'Mauritel';

  @override
  String get chinguitel => 'Chinguitel';

  @override
  String get mattel => 'Mattel';

  @override
  String get other => 'Autre';

  @override
  String get threeDays => '3 jours';

  @override
  String get sevenDays => 'Une semaine';

  @override
  String get twoWeeks => 'Deux semaines';

  @override
  String get month => 'Mois';

  @override
  String get twoMonths => 'Deux mois';

  @override
  String get threeMonths => '3 mois';

  @override
  String get sixMonths => 'Six mois';

  @override
  String get system => 'Système';

  @override
  String get dark => 'Sombre';

  @override
  String get light => 'Clair';

  @override
  String get adminUser => 'Administrateur';

  @override
  String get betaVersion => 'Version Bêta';

  @override
  String get security => 'Sécurité';

  @override
  String get pinLock => 'Verrouillage PIN';

  @override
  String get enabled => 'Activé';

  @override
  String get disabled => 'Désactivé';

  @override
  String get setupPin => 'Configurer le code PIN';

  @override
  String get enterPin => 'Entrez le code PIN';

  @override
  String get pinLengthHint => '(4-6 chiffres)';

  @override
  String get chooseLanguage => 'Choisir la langue';

  @override
  String get arabic => 'Arabe (العربية)';

  @override
  String get french => 'Français';

  @override
  String get settingsSaved => 'Paramètres enregistrés avec succès';

  @override
  String get percentage => 'Pourcentage';

  @override
  String get fixed => 'Fixe';

  @override
  String get defaultProfitPercentage => 'Pourcentage par défaut (%)';

  @override
  String get defaultProfitAmount => 'Montant par défaut (MRU)';

  @override
  String get accountCreated => 'Votre compte a été créé';
}
