import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr')
  ];

  /// Application name
  ///
  /// In ar, this message translates to:
  /// **'دينك'**
  String get appName;

  /// Application title
  ///
  /// In ar, this message translates to:
  /// **'دينك'**
  String get appTitle;

  /// Application description
  ///
  /// In ar, this message translates to:
  /// **'إدارة ديون بالسلف'**
  String get appDescription;

  /// Login button text
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// Register button text
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get register;

  /// Settings menu item
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// Loans menu item
  ///
  /// In ar, this message translates to:
  /// **'السلف'**
  String get loans;

  /// Reports menu item
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reports;

  /// Home menu item
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// Add loan button
  ///
  /// In ar, this message translates to:
  /// **'إضافة سلف'**
  String get addLoan;

  /// Edit loan button
  ///
  /// In ar, this message translates to:
  /// **'تعديل السلف'**
  String get editLoan;

  /// Delete button label
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// Cancel button label
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// Save button label
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// Borrower name label
  ///
  /// In ar, this message translates to:
  /// **'اسم المستلف'**
  String get borrowerName;

  /// Full name label for user profile
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullNameLabel;

  /// Error message when full name is empty
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال الاسم الكامل'**
  String get fullNameRequired;

  /// Country label for registration
  ///
  /// In ar, this message translates to:
  /// **'الدولة'**
  String get countryLabel;

  /// Select country hint
  ///
  /// In ar, this message translates to:
  /// **'اختر الدولة'**
  String get selectCountry;

  /// Phone number label
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// Loan date label
  ///
  /// In ar, this message translates to:
  /// **'تاريخ السلف'**
  String get loanDate;

  /// Due date label
  ///
  /// In ar, this message translates to:
  /// **'تاريخ السداد'**
  String get dueDate;

  /// Amount label
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get amount;

  /// Profit label
  ///
  /// In ar, this message translates to:
  /// **'الربح'**
  String get profit;

  /// Total label
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get total;

  /// Notes label
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notes;

  /// Status label
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get status;

  /// Active status label
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get active;

  /// Overdue status label
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get overdue;

  /// Completed status label
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get completed;

  /// Theme settings label
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get theme;

  /// Language settings label
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// Logout button
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// Guest user label
  ///
  /// In ar, this message translates to:
  /// **'مستخدم ضيف'**
  String get guestUser;

  /// About app menu
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// Version label
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get version;

  /// Developed by label
  ///
  /// In ar, this message translates to:
  /// **'تم التطوير بواسطة'**
  String get developedBy;

  /// Username label
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get username;

  /// Password label
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// Enter username hint
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم المستخدم'**
  String get enterUsername;

  /// Enter phone number hint
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الهاتف'**
  String get enterPhoneNumber;

  /// Enter password hint
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get enterPassword;

  /// Username required error
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسم المستخدم'**
  String get usernameRequired;

  /// Password required error
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال كلمة المرور'**
  String get passwordRequired;

  /// Link to registration
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟ إنشاء حساب جديد'**
  String get noAccount;

  /// Continue as guest button
  ///
  /// In ar, this message translates to:
  /// **'متابعة بدون حساب (ضيف)'**
  String get continueAsGuest;

  /// Phone number validation error message
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف غير صحيح. يجب أن يتكون من 8 أرقام ويبدأ بـ 2 أو 3 أو 4'**
  String get invalidPhoneNumber;

  /// Login error message
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تسجيل الدخول'**
  String get loginError;

  /// Total lent amount label
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الـمبالغ الـمستلفة'**
  String get totalLentAmount;

  /// Count of active loans
  ///
  /// In ar, this message translates to:
  /// **'{count} سلف نشط'**
  String activeLoansCount(int count);

  /// Today's profit label
  ///
  /// In ar, this message translates to:
  /// **'أرباح اليوم'**
  String get todayProfitLabel;

  /// Expected profit label
  ///
  /// In ar, this message translates to:
  /// **'أرباح متوقعة'**
  String get expectedProfitLabel;

  /// Title for overdue loans list
  ///
  /// In ar, this message translates to:
  /// **'سلف متأخرة ({count})'**
  String overdueLoansTitle(int count);

  /// Recent loans header
  ///
  /// In ar, this message translates to:
  /// **'السلف الأخيرة'**
  String get recentLoans;

  /// Message when no active loans exist
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سلف نشطة'**
  String get noActiveLoans;

  /// New loan button
  ///
  /// In ar, this message translates to:
  /// **'سلف جديد'**
  String get newLoan;

  /// Warning message for guest users
  ///
  /// In ar, this message translates to:
  /// **'أنت تستخدم التطبيق كضيف. بياناتك محلية فقط.'**
  String get guestBannerText;

  /// Change password title
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get changePassword;

  /// Current password label
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get currentPassword;

  /// New password label
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get newPassword;

  /// Confirm password label
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// Confirmation message for logout
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج؟'**
  String get confirmLogout;

  /// Logout confirmation button
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get logoutButton;

  /// Password mismatch error
  ///
  /// In ar, this message translates to:
  /// **'كلمات المرور غير متطابقة'**
  String get passwordsNotMatch;

  /// Registration error message
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إنشاء الحساب'**
  String get registerError;

  /// Registration title
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get registerTitle;

  /// Create account button label
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get createAccount;

  /// Password too short error
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تكون كلمة المرور 6 أحرف على الأقل'**
  String get passwordTooShort;

  /// Confirmation password required error
  ///
  /// In ar, this message translates to:
  /// **'يرجى تأكيد كلمة المرور'**
  String get confirmPasswordRequired;

  /// Borrower info section header
  ///
  /// In ar, this message translates to:
  /// **'معلومات المستلف'**
  String get borrowerInfo;

  /// Loan details section header
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل السلف'**
  String get loanDetails;

  /// Loan duration label
  ///
  /// In ar, this message translates to:
  /// **'الأجل'**
  String get loanDuration;

  /// Repayment date label
  ///
  /// In ar, this message translates to:
  /// **'موعد السداد'**
  String get repaymentDate;

  /// Card company label
  ///
  /// In ar, this message translates to:
  /// **'شركة البطاقة'**
  String get cardCompany;

  /// Card category label
  ///
  /// In ar, this message translates to:
  /// **'فئة البطاقة (القيمة)'**
  String get cardCategory;

  /// Card count label
  ///
  /// In ar, this message translates to:
  /// **'عدد البطاقات'**
  String get cardCount;

  /// Other/custom value option
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get customValue;

  /// Card value input label
  ///
  /// In ar, this message translates to:
  /// **'قيمة البطاقة (MRU)'**
  String get cardValueLabel;

  /// Profit type label
  ///
  /// In ar, this message translates to:
  /// **'نوع الربح'**
  String get profitType;

  /// Profit percentage label
  ///
  /// In ar, this message translates to:
  /// **'نسبة %'**
  String get profitPercentage;

  /// Fixed profit amount label
  ///
  /// In ar, this message translates to:
  /// **'مبلغ ثابت'**
  String get fixedAmount;

  /// Profit rate label
  ///
  /// In ar, this message translates to:
  /// **'نسبة الربح (%)'**
  String get profitRate;

  /// Profit amount label
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الربح (MRU)'**
  String get profitAmount;

  /// Loan summary header
  ///
  /// In ar, this message translates to:
  /// **'ملخص السلف'**
  String get loanSummary;

  /// Total cards amount label
  ///
  /// In ar, this message translates to:
  /// **'إجمالي البطاقات'**
  String get totalCardsAmount;

  /// Final loan amount label
  ///
  /// In ar, this message translates to:
  /// **'المبلغ النهائي'**
  String get finalAmount;

  /// Add note hint text
  ///
  /// In ar, this message translates to:
  /// **'أضف ملاحظة (اختياري)...'**
  String get addNoteHint;

  /// Invalid card value error
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال قيمة صحيحة للبطاقة'**
  String get invalidCardValue;

  /// Loan updated success message
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث السلف بنجاح'**
  String get loanUpdated;

  /// Loan added success message
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة السلف بنجاح'**
  String get loanAdded;

  /// Name required error
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال الاسم'**
  String get nameRequired;

  /// Phone required error
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم الهاتف'**
  String get phoneRequired;

  /// Card count required error
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال عدد البطاقات'**
  String get cardCountRequired;

  /// Profit value required error
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال قيمة الربح'**
  String get profitValueRequired;

  /// Confirm paid dialog title
  ///
  /// In ar, this message translates to:
  /// **'تأكيد السداد'**
  String get confirmPaidTitle;

  /// Confirm paid dialog message
  ///
  /// In ar, this message translates to:
  /// **'هل تم سداد {name}؟'**
  String confirmPaidMessage(String name);

  /// Confirm paid button
  ///
  /// In ar, this message translates to:
  /// **'نعم، تم السداد'**
  String get yesPaid;

  /// No button
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// Payment marked as success message
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل السداد بنجاح'**
  String get paidSuccess;

  /// Confirm delete loan title
  ///
  /// In ar, this message translates to:
  /// **'حذف السلف'**
  String get confirmDeleteTitle;

  /// Confirm delete loan message
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف سلف {name}؟'**
  String confirmDeleteMessage(String name);

  /// Amounts label
  ///
  /// In ar, this message translates to:
  /// **'المبالغ'**
  String get amounts;

  /// Dates label
  ///
  /// In ar, this message translates to:
  /// **'التواريخ'**
  String get dates;

  /// Company label
  ///
  /// In ar, this message translates to:
  /// **'الشركة'**
  String get company;

  /// Category and count label
  ///
  /// In ar, this message translates to:
  /// **'الفئة × العدد'**
  String get categoryAndCount;

  /// Ends soon badge label
  ///
  /// In ar, this message translates to:
  /// **'ينتهي قريبًا'**
  String get endsSoon;

  /// Paid date label
  ///
  /// In ar, this message translates to:
  /// **'تاريخ السداد'**
  String get paidAt;

  /// Mark as paid button
  ///
  /// In ar, this message translates to:
  /// **'تم السداد'**
  String get markAsPaid;

  /// Overview summary title
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة'**
  String get overview;

  /// Total loans count label
  ///
  /// In ar, this message translates to:
  /// **'إجمالي السلف'**
  String get totalLoansCount;

  /// Total lent amount label
  ///
  /// In ar, this message translates to:
  /// **'إجمالي مُقرض'**
  String get totalLent;

  /// Earned profit amount label
  ///
  /// In ar, this message translates to:
  /// **'أرباح محققة'**
  String get earnedProfit;

  /// Monthly profit label
  ///
  /// In ar, this message translates to:
  /// **'أرباح الشهر'**
  String get monthProfitLabel;

  /// Loan distribution title
  ///
  /// In ar, this message translates to:
  /// **'توزيع السلف'**
  String get loanDistribution;

  /// Recently completed loans title
  ///
  /// In ar, this message translates to:
  /// **'أحدث السلف المسددة'**
  String get recentCompletedLoansTitle;

  /// Message when no completed loans exist
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سلف مسددة بعد'**
  String get noCompletedLoans;

  /// Message when no data is available
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noData;

  /// Profit suffix for charts
  ///
  /// In ar, this message translates to:
  /// **'ربح'**
  String get profitSuffix;

  /// Search field hint
  ///
  /// In ar, this message translates to:
  /// **'بحث باسم المستلف أو رقم الهاتف...'**
  String get searchHint;

  /// Active loans tab label
  ///
  /// In ar, this message translates to:
  /// **'نشطة ({count})'**
  String activeTab(int count);

  /// Overdue loans tab label
  ///
  /// In ar, this message translates to:
  /// **'متأخرة ({count})'**
  String overdueTab(int count);

  /// Completed loans tab label
  ///
  /// In ar, this message translates to:
  /// **'مسددة ({count})'**
  String completedTab(int count);

  /// Empty list message
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سلف في هذه القائمة'**
  String get noLoansList;

  /// Loan deleted success message
  ///
  /// In ar, this message translates to:
  /// **'تم حذف السلف بنجاح'**
  String get deleteSuccess;

  /// Loan warning notification title
  ///
  /// In ar, this message translates to:
  /// **'⚠️ تحذير موعد السداد'**
  String get loanWarningTitle;

  /// Loan warning notification body
  ///
  /// In ar, this message translates to:
  /// **'تبقى 24 ساعة على موعد سداد {name} - المبلغ: {amount} MRU'**
  String loanWarningBody(String name, String amount);

  /// Loan due today notification title
  ///
  /// In ar, this message translates to:
  /// **'🔴 موعد السداد اليوم'**
  String get loanDueTitle;

  /// Loan due today notification body
  ///
  /// In ar, this message translates to:
  /// **'حان موعد سداد {name} - المبلغ: {amount} MRU'**
  String loanDueBody(String name, String amount);

  /// Loading indicator text
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// App slogan
  ///
  /// In ar, this message translates to:
  /// **'إدارة السلف والديون بكل سهولة'**
  String get slogan;

  /// Mauritel operator name
  ///
  /// In ar, this message translates to:
  /// **'موريتل'**
  String get mauritel;

  /// Chinguitel operator name
  ///
  /// In ar, this message translates to:
  /// **'شنقيتل'**
  String get chinguitel;

  /// Mattel operator name
  ///
  /// In ar, this message translates to:
  /// **'ماتل'**
  String get mattel;

  /// Other operator name
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get other;

  /// 3 days duration option
  ///
  /// In ar, this message translates to:
  /// **'3 أيام'**
  String get threeDays;

  /// One week duration option
  ///
  /// In ar, this message translates to:
  /// **'أسبوع'**
  String get sevenDays;

  /// Two weeks duration option
  ///
  /// In ar, this message translates to:
  /// **'أسبوعين'**
  String get twoWeeks;

  /// One month duration option
  ///
  /// In ar, this message translates to:
  /// **'شهر'**
  String get month;

  /// Two months duration option
  ///
  /// In ar, this message translates to:
  /// **'شهرين'**
  String get twoMonths;

  /// Three months duration option
  ///
  /// In ar, this message translates to:
  /// **'3 أشهر'**
  String get threeMonths;

  /// Six months duration option
  ///
  /// In ar, this message translates to:
  /// **'6 أشهر'**
  String get sixMonths;

  /// System theme option
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get system;

  /// Dark theme option
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get dark;

  /// Light theme option
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get light;

  /// Admin user role label
  ///
  /// In ar, this message translates to:
  /// **'مسؤول النظام'**
  String get adminUser;

  /// Beta version badge
  ///
  /// In ar, this message translates to:
  /// **'نسخة تجريبية'**
  String get betaVersion;

  /// Security settings section title
  ///
  /// In ar, this message translates to:
  /// **'الأمان'**
  String get security;

  /// PIN lock settings label
  ///
  /// In ar, this message translates to:
  /// **'قفل بالـ PIN'**
  String get pinLock;

  /// Feature enabled status
  ///
  /// In ar, this message translates to:
  /// **'مفعّل'**
  String get enabled;

  /// Feature disabled status
  ///
  /// In ar, this message translates to:
  /// **'غير مفعّل'**
  String get disabled;

  /// Setup PIN button label
  ///
  /// In ar, this message translates to:
  /// **'إعداد رمز PIN'**
  String get setupPin;

  /// Enter PIN screen title
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز PIN'**
  String get enterPin;

  /// PIN length requirements hint
  ///
  /// In ar, this message translates to:
  /// **'(4-6 أرقام)'**
  String get pinLengthHint;

  /// Language selection dialog title
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get chooseLanguage;

  /// Arabic language option
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// French language option
  ///
  /// In ar, this message translates to:
  /// **'الفرنسية (Français)'**
  String get french;

  /// Settings saved success message
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الإعدادات بنجاح'**
  String get settingsSaved;

  /// Percentage profit type option
  ///
  /// In ar, this message translates to:
  /// **'نسبة'**
  String get percentage;

  /// Fixed profit type option
  ///
  /// In ar, this message translates to:
  /// **'ثابت'**
  String get fixed;

  /// Default profit percentage settings label
  ///
  /// In ar, this message translates to:
  /// **'النسبة الافتراضية (%)'**
  String get defaultProfitPercentage;

  /// Default profit amount settings label
  ///
  /// In ar, this message translates to:
  /// **'المبلغ الافتراضي (MRU)'**
  String get defaultProfitAmount;

  /// Message shown when a new account is successfully created
  ///
  /// In ar, this message translates to:
  /// **'لقد تم انشاء حسابك'**
  String get accountCreated;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
