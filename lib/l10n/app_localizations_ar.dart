// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'دينك';

  @override
  String get appTitle => 'دينك';

  @override
  String get appDescription => 'إدارة ديون بالسلف';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get settings => 'الإعدادات';

  @override
  String get loans => 'السلف';

  @override
  String get reports => 'التقارير';

  @override
  String get home => 'الرئيسية';

  @override
  String get addLoan => 'إضافة سلف';

  @override
  String get editLoan => 'تعديل السلف';

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get borrowerName => 'اسم المستلف';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get fullNameRequired => 'يرجى إدخال الاسم الكامل';

  @override
  String get countryLabel => 'الدولة';

  @override
  String get selectCountry => 'اختر الدولة';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get loanDate => 'تاريخ السلف';

  @override
  String get dueDate => 'تاريخ السداد';

  @override
  String get amount => 'المبلغ';

  @override
  String get profit => 'الربح';

  @override
  String get total => 'الإجمالي';

  @override
  String get notes => 'ملاحظات';

  @override
  String get status => 'الحالة';

  @override
  String get active => 'نشط';

  @override
  String get overdue => 'متأخر';

  @override
  String get completed => 'مكتمل';

  @override
  String get theme => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get guestUser => 'مستخدم ضيف';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get version => 'الإصدار';

  @override
  String get developedBy => 'تم التطوير بواسطة';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterUsername => 'أدخل اسم المستخدم';

  @override
  String get enterPhoneNumber => 'أدخل رقم الهاتف';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get usernameRequired => 'يرجى إدخال اسم المستخدم';

  @override
  String get passwordRequired => 'يرجى إدخال كلمة المرور';

  @override
  String get noAccount => 'ليس لديك حساب؟ إنشاء حساب جديد';

  @override
  String get continueAsGuest => 'متابعة بدون حساب (ضيف)';

  @override
  String get invalidPhoneNumber =>
      'رقم الهاتف غير صحيح. يجب أن يتكون من 8 أرقام ويبدأ بـ 2 أو 3 أو 4';

  @override
  String get loginError => 'خطأ في تسجيل الدخول';

  @override
  String get totalLentAmount => 'إجمالي الـمبالغ الـمستلفة';

  @override
  String activeLoansCount(int count) {
    return '$count سلف نشط';
  }

  @override
  String get todayProfitLabel => 'أرباح اليوم';

  @override
  String get expectedProfitLabel => 'أرباح متوقعة';

  @override
  String overdueLoansTitle(int count) {
    return 'سلف متأخرة ($count)';
  }

  @override
  String get recentLoans => 'السلف الأخيرة';

  @override
  String get noActiveLoans => 'لا توجد سلف نشطة';

  @override
  String get newLoan => 'سلف جديد';

  @override
  String get guestBannerText => 'أنت تستخدم التطبيق كضيف. بياناتك محلية فقط.';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get confirmLogout => 'هل تريد تسجيل الخروج؟';

  @override
  String get logoutButton => 'خروج';

  @override
  String get passwordsNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get registerError => 'خطأ في إنشاء الحساب';

  @override
  String get registerTitle => 'إنشاء حساب جديد';

  @override
  String get createAccount => 'إنشاء الحساب';

  @override
  String get passwordTooShort => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get confirmPasswordRequired => 'يرجى تأكيد كلمة المرور';

  @override
  String get borrowerInfo => 'معلومات المستلف';

  @override
  String get loanDetails => 'تفاصيل السلف';

  @override
  String get loanDuration => 'الأجل';

  @override
  String get repaymentDate => 'موعد السداد';

  @override
  String get cardCompany => 'شركة البطاقة';

  @override
  String get cardCategory => 'فئة البطاقة (القيمة)';

  @override
  String get cardCount => 'عدد البطاقات';

  @override
  String get customValue => 'أخرى';

  @override
  String get cardValueLabel => 'قيمة البطاقة (MRU)';

  @override
  String get profitType => 'نوع الربح';

  @override
  String get profitPercentage => 'نسبة %';

  @override
  String get fixedAmount => 'مبلغ ثابت';

  @override
  String get profitRate => 'نسبة الربح (%)';

  @override
  String get profitAmount => 'مبلغ الربح (MRU)';

  @override
  String get loanSummary => 'ملخص السلف';

  @override
  String get totalCardsAmount => 'إجمالي البطاقات';

  @override
  String get finalAmount => 'المبلغ النهائي';

  @override
  String get addNoteHint => 'أضف ملاحظة (اختياري)...';

  @override
  String get invalidCardValue => 'يرجى إدخال قيمة صحيحة للبطاقة';

  @override
  String get loanUpdated => 'تم تحديث السلف بنجاح';

  @override
  String get loanAdded => 'تم إضافة السلف بنجاح';

  @override
  String get nameRequired => 'يرجى إدخال الاسم';

  @override
  String get phoneRequired => 'يرجى إدخال رقم الهاتف';

  @override
  String get cardCountRequired => 'يرجى إدخال عدد البطاقات';

  @override
  String get profitValueRequired => 'يرجى إدخال قيمة الربح';

  @override
  String get confirmPaidTitle => 'تأكيد السداد';

  @override
  String confirmPaidMessage(String name) {
    return 'هل تم سداد $name؟';
  }

  @override
  String get yesPaid => 'نعم، تم السداد';

  @override
  String get no => 'لا';

  @override
  String get paidSuccess => 'تم تسجيل السداد بنجاح';

  @override
  String get confirmDeleteTitle => 'حذف السلف';

  @override
  String confirmDeleteMessage(String name) {
    return 'هل أنت متأكد من حذف سلف $name؟';
  }

  @override
  String get amounts => 'المبالغ';

  @override
  String get dates => 'التواريخ';

  @override
  String get company => 'الشركة';

  @override
  String get categoryAndCount => 'الفئة × العدد';

  @override
  String get endsSoon => 'ينتهي قريبًا';

  @override
  String get paidAt => 'تاريخ السداد';

  @override
  String get markAsPaid => 'تم السداد';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get totalLoansCount => 'إجمالي السلف';

  @override
  String get totalLent => 'إجمالي مُقرض';

  @override
  String get earnedProfit => 'أرباح محققة';

  @override
  String get monthProfitLabel => 'أرباح الشهر';

  @override
  String get loanDistribution => 'توزيع السلف';

  @override
  String get recentCompletedLoansTitle => 'أحدث السلف المسددة';

  @override
  String get noCompletedLoans => 'لا توجد سلف مسددة بعد';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get profitSuffix => 'ربح';

  @override
  String get searchHint => 'بحث باسم المستلف أو رقم الهاتف...';

  @override
  String activeTab(int count) {
    return 'نشطة ($count)';
  }

  @override
  String overdueTab(int count) {
    return 'متأخرة ($count)';
  }

  @override
  String completedTab(int count) {
    return 'مسددة ($count)';
  }

  @override
  String get noLoansList => 'لا توجد سلف في هذه القائمة';

  @override
  String get deleteSuccess => 'تم حذف السلف بنجاح';

  @override
  String get loanWarningTitle => '⚠️ تحذير موعد السداد';

  @override
  String loanWarningBody(String name, String amount) {
    return 'تبقى 24 ساعة على موعد سداد $name - المبلغ: $amount MRU';
  }

  @override
  String get loanDueTitle => '🔴 موعد السداد اليوم';

  @override
  String loanDueBody(String name, String amount) {
    return 'حان موعد سداد $name - المبلغ: $amount MRU';
  }

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get slogan => 'إدارة السلف والديون بكل سهولة';

  @override
  String get mauritel => 'موريتل';

  @override
  String get chinguitel => 'شنقيتل';

  @override
  String get mattel => 'ماتل';

  @override
  String get other => 'أخرى';

  @override
  String get threeDays => '3 أيام';

  @override
  String get sevenDays => 'أسبوع';

  @override
  String get twoWeeks => 'أسبوعين';

  @override
  String get month => 'شهر';

  @override
  String get twoMonths => 'شهرين';

  @override
  String get threeMonths => '3 أشهر';

  @override
  String get sixMonths => '6 أشهر';

  @override
  String get system => 'تلقائي';

  @override
  String get dark => 'داكن';

  @override
  String get light => 'فاتح';

  @override
  String get adminUser => 'مسؤول النظام';

  @override
  String get betaVersion => 'نسخة تجريبية';

  @override
  String get security => 'الأمان';

  @override
  String get pinLock => 'قفل بالـ PIN';

  @override
  String get enabled => 'مفعّل';

  @override
  String get disabled => 'غير مفعّل';

  @override
  String get setupPin => 'إعداد رمز PIN';

  @override
  String get enterPin => 'أدخل رمز PIN';

  @override
  String get pinLengthHint => '(4-6 أرقام)';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get french => 'الفرنسية (Français)';

  @override
  String get settingsSaved => 'تم حفظ الإعدادات بنجاح';

  @override
  String get percentage => 'نسبة';

  @override
  String get fixed => 'ثابت';

  @override
  String get defaultProfitPercentage => 'النسبة الافتراضية (%)';

  @override
  String get defaultProfitAmount => 'المبلغ الافتراضي (MRU)';

  @override
  String get accountCreated => 'لقد تم انشاء حسابك';
}
