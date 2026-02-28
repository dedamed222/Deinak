class AppConstants {
  // App Info
  static const String appName = 'دينك';
  static const String appVersion = '1.0.0';

  // Database
  static const String dbName = 'deinak.db';
  static const int dbVersion = 2;

  // Tables
  static const String usersTable = 'users';
  static const String loansTable = 'loans';
  static const String settingsTable = 'settings';

  // Guest User
  static const int guestUserId = 0;

  // Shared Prefs Keys
  static const String prefKeyLoggedIn = 'isLoggedIn';
  static const String prefKeyUserId = 'userId';
  static const String prefKeyUsername = 'username';
  static const String prefKeyIsGuest = 'isGuest';
  static const String prefKeyThemeMode = 'themeMode';
  static const String prefKeyPinEnabled = 'pinEnabled';
  static const String prefKeyPin = 'pin';
  static const String prefKeyDefaultProfit = 'defaultProfit';
  static const String prefKeyDefaultProfitType = 'defaultProfitType';
  static const String prefKeyBiometricEnabled = 'biometricEnabled';

  // Loan Status
  static const String statusActive = 'active';
  static const String statusOverdue = 'overdue';
  static const String statusCompleted = 'completed';

  // Profit Type
  static const String profitTypeFixed = 'fixed';
  static const String profitTypePercentage = 'percentage';

  // Loan Duration
  static const Map<String, int> loanDurations = {
    '10 أيام': 10,
    '15 يوم': 15,
    '20 يوم': 20,
    '30 يوم': 30,
    '40 يوم': 40,
    '60 يوم': 60,
    '90 يوم': 90,
    '120 يوم': 120,
    '180 يوم': 180,
  };

  // Card Companies
  static const List<String> cardCompanies = [
    'موريتل',
    'شنقيتل',
    'ماتل',
    'أخرى',
  ];

  // Card Categories (in MRU/local currency)
  static const List<String> cardCategories = [
    '10',
    '20',
    '50',
    '100',
    '200',
    '500',
    '1000',
    'أخرى',
  ];

  // Currency
  static const String currencyLabel = 'MRU';

  // Notification IDs
  static const String notifChannelId = 'deinak_notifications';
  static const String notifChannelName = 'تنبيهات دينك';
  static const String notifChannelDesc = 'تنبيهات مواعيد سداد الديون';
}
