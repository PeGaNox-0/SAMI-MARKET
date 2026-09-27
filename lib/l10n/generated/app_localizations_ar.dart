// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'SAMI MARKET';

  @override
  String get dashboard => 'الرئيسية';

  @override
  String get customers => 'الزبائن';

  @override
  String get reports => 'التقارير';

  @override
  String get settings => 'الإعدادات';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get marketName => 'اسم المحل';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordMessage =>
      'أدخل بريدك الإلكتروني لاستلام رابط إعادة التعيين.';

  @override
  String get sendResetLink => 'إرسال رابط التعيين';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get customerName => 'اسم الزبون';

  @override
  String get customerCode => 'رقم / كود الزبون';

  @override
  String get customerCodeHint => 'مثال: 101 أو A-12 (اختياري)';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get address => 'العنوان';

  @override
  String get notes => 'ملاحظات';

  @override
  String get addCustomer => 'إضافة زبون';

  @override
  String get editCustomer => 'تعديل الزبون';

  @override
  String get searchCustomer => 'بحث عن زبون...';

  @override
  String get noCustomers => 'لا يوجد زبائن بعد';

  @override
  String get noCustomersMessage => 'أضف أول زبون لبدء تتبع الديون.';

  @override
  String get debt => 'دين';

  @override
  String get payment => 'دفعة';

  @override
  String get addDebt => 'إضافة دين';

  @override
  String get addPayment => 'تسجيل دفعة';

  @override
  String get amount => 'المبلغ';

  @override
  String get description => 'الوصف';

  @override
  String get date => 'التاريخ';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get confirm => 'تأكيد';

  @override
  String get remainingDebt => 'الدين المتبقي';

  @override
  String get totalDebt => 'إجمالي الديون';

  @override
  String get totalPayments => 'إجمالي الدفعات';

  @override
  String get outstanding => 'المستحق';

  @override
  String get customersWithDebt => 'الزبائن المدينون';

  @override
  String get paymentsToday => 'دفعات اليوم';

  @override
  String get debtsToday => 'ديون اليوم';

  @override
  String get transactionHistory => 'سجل العمليات';

  @override
  String get recentTransactions => 'آخر العمليات';

  @override
  String get noTransactions => 'لا توجد عمليات بعد';

  @override
  String get fullyPaid => 'سدد بالكامل';

  @override
  String get hasDebt => 'عليه دين';

  @override
  String get all => 'الكل';

  @override
  String get today => 'اليوم';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get customRange => 'فترة مخصصة';

  @override
  String get deleteConfirmTitle => 'حذف العملية؟';

  @override
  String get deleteConfirmMessage =>
      'هل أنت متأكد من حذف هذه العملية؟ سيتغير رصيد الزبون.';

  @override
  String get archiveConfirmTitle => 'أرشفة الزبون؟';

  @override
  String get archiveConfirmMessage =>
      'سيتم أرشفة هذا الزبون وإخفاؤه من القائمة.';

  @override
  String get paymentExceedsDebt => 'الدفعة لا يمكن أن تتجاوز الدين المتبقي.';

  @override
  String get invalidAmount => 'يرجى إدخال مبلغ صالح.';

  @override
  String get requiredField => 'هذا الحقل مطلوب.';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت.';

  @override
  String get offlineSaved => 'تم حفظ العملية محلياً وستتم المزامنة تلقائياً.';

  @override
  String get syncFailed =>
      'فشلت المزامنة. بياناتك آمنة محلياً وسنحاول تلقائياً.';

  @override
  String get syncPending => 'بانتظار المزامنة';

  @override
  String get syncComplete => 'تمت مزامنة جميع البيانات';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get theme => 'المظهر';

  @override
  String get lightMode => 'فاتح';

  @override
  String get darkMode => 'داكن';

  @override
  String get systemMode => 'تلقائي';

  @override
  String get backup => 'النسخ الاحتياطي والاستعادة';

  @override
  String get createBackup => 'إنشاء نسخة احتياطية';

  @override
  String get restoreBackup => 'استعادة نسخة احتياطية';

  @override
  String get backupCreated => 'تم إنشاء النسخة الاحتياطية بنجاح.';

  @override
  String get restoreConfirm =>
      'هل أنت متأكد من استعادة هذه النسخة؟ ستُستبدل البيانات الحالية.';

  @override
  String get restoreSuccess => 'تمت استعادة البيانات بنجاح.';

  @override
  String get accountInfo => 'معلومات الحساب';

  @override
  String get success => 'تم بنجاح!';

  @override
  String get error => 'خطأ';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get customer => 'زبون';

  @override
  String customersCount(int count) {
    return '$count زبون';
  }

  @override
  String currencyAmount(String amount) {
    return '$amount ₺';
  }

  @override
  String get whoAreYou => 'من أنت؟';

  @override
  String get chooseAccountType => 'اختر نوع حسابك للمتابعة';

  @override
  String get marketOwner => 'صاحب الماركت';

  @override
  String get marketOwnerDesc => 'إدارة الزبائن والديون والتقارير';

  @override
  String get customerRoleDesc => 'متابعة ديونك ودفعاتك وسجل مشترياتك';

  @override
  String get customerLogin => 'تسجيل دخول الزبون';

  @override
  String get customerLoginSubtitle =>
      'أدخل رمز الزبون الخاص بك والشيفرة السرية';

  @override
  String get customerPin => 'الشيفرة السرية (PIN)';

  @override
  String get customerPinHint => 'أدخل 6 أرقام';

  @override
  String get loginButton => 'دخول';

  @override
  String get forgotPin => 'نسيت الشيفرة؟';

  @override
  String get forgotPinMessage =>
      'يرجى مراجعة صاحب الماركت لإعادة تعيين شيفرتك السرية.';

  @override
  String get backToRoleSelection => 'الرجوع لاختيار الحساب';

  @override
  String welcomeCustomer(String name) {
    return 'مرحباً $name 👋';
  }

  @override
  String get noRemainingDebt => 'لا توجد ديون متبقية';

  @override
  String get viewAllTransactions => 'عرض كل العمليات';

  @override
  String get myAccount => 'حسابي';

  @override
  String get changePin => 'تغيير الشيفرة';

  @override
  String get currentPin => 'الشيفرة الحالية';

  @override
  String get newPin => 'الشيفرة الجديدة';

  @override
  String get confirmNewPin => 'تأكيد الشيفرة الجديدة';

  @override
  String get pinChangedSuccess => 'تم تغيير الشيفرة بنجاح.';

  @override
  String get enableCustomerAccess => 'تفعيل وصول الزبون للتطبيق';

  @override
  String get enableCustomerAccessDesc =>
      'إنشاء حساب للزبون لمتابعة ديونه بنفسه';

  @override
  String get customerAccountCreated => 'تم إنشاء حساب الزبون بنجاح';

  @override
  String get saveCredentialsWarning =>
      'احفظ هذه المعلومات وأعطها للزبون للدخول.';

  @override
  String get copyCode => 'نسخ الرمز';

  @override
  String get copyPin => 'نسخ الشيفرة';

  @override
  String get copiedToClipboard => 'تم النسخ للحافظة';

  @override
  String get done => 'تم';

  @override
  String get appAccess => 'وصول التطبيق';

  @override
  String get accessEnabled => 'مفعّل';

  @override
  String get accessDisabled => 'معطّل';

  @override
  String get resetPin => 'إعادة تعيين الشيفرة';

  @override
  String get resetPinConfirm => 'هل تريد توليد شيفرة جديدة للزبون؟';

  @override
  String get newPinGenerated => 'الشيفرة الجديدة للزبون هي:';

  @override
  String get disableAccess => 'تعطيل الوصول';

  @override
  String get enableAccess => 'تفعيل الوصول';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get sendNotification => 'إرسال إشعار';

  @override
  String get notificationMessage => 'نص الإشعار';

  @override
  String get notificationMessageHint => 'مثال: تذكير بتسديد الدين المتبقي...';

  @override
  String get selectRecipients => 'اختيار المستلمين';

  @override
  String get sendToAll => 'إرسال للجميع';

  @override
  String get selectCustomers => 'اختيار زبائن محددين';

  @override
  String get sendNotificationBtn => 'إرسال';

  @override
  String get notificationSent => 'تم إرسال الإشعار';

  @override
  String notificationSentTo(int count) {
    return 'تم إرسال الإشعار لـ $count زبون';
  }

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get markAllRead => 'قراءة الكل';

  @override
  String get unread => 'غير مقروء';

  @override
  String get notificationHint => 'يرجى إدخال نص الإشعار';

  @override
  String get selectAtLeastOne => 'يرجى اختيار زبون واحد على الأقل';

  @override
  String get shareAccountStatement => 'مشاركة كشف الحساب';

  @override
  String get shareLastTransaction => 'مشاركة آخر عملية';

  @override
  String get shareDekont => 'مشاركة Dekont';

  @override
  String get accountStatement => 'كشف حساب الزبون';

  @override
  String get transactionDekont => 'إشعار عملية (Dekont)';

  @override
  String get transactionNumber => 'رقم العملية';

  @override
  String get statementNumber => 'رقم الكشف';

  @override
  String get beforeBalance => 'الدين قبل العملية';

  @override
  String get afterBalance => 'الدين بعد العملية';

  @override
  String get accountFullyPaid => 'الحساب مسدد بالكامل';

  @override
  String get thankYouForBusiness => 'شكراً لتعاملكم معنا';

  @override
  String get noTransactionsRegistered => 'لا توجد عمليات مسجلة حتى الآن.';

  @override
  String get generatingPdf => 'جاري إنشاء المستند...';

  @override
  String get pdfGenerationFailed => 'تعذر إنشاء كشف الحساب. حاول مرة أخرى.';

  @override
  String get noTransactionsToShare => 'لا توجد عمليات مسجلة لمشاركتها.';

  @override
  String get dailyStatistics => 'الإحصائيات والتقارير اليومية';

  @override
  String get selectDate => 'تحديد تاريخ';

  @override
  String get pickDay => 'اختيار يوم';

  @override
  String get yesterday => 'الأمس';

  @override
  String get previousDay => 'اليوم السابق';

  @override
  String get nextDay => 'اليوم التالي';

  @override
  String get netMovement => 'صافي الحركة';

  @override
  String get operationsCount => 'عدد العمليات';

  @override
  String get activeCustomersCount => 'الزبائن المتعامل معهم';

  @override
  String get debtsOnly => 'الديون فقط';

  @override
  String get paymentsOnly => 'الدفعات فقط';

  @override
  String get allOperations => 'كافة العمليات';

  @override
  String get noTransactionsForDate =>
      'لا توجد حركات ديون أو دفعات مسجلة في هذا اليوم.';

  @override
  String get dailySummary => 'ملخص اليوم';

  @override
  String get operations => 'عمليات';
}
