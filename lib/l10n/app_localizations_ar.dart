// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'imrpo';

  @override
  String get tabIncomes => 'الدخل';

  @override
  String get tabExpenses => 'المصروفات';

  @override
  String get tabBalance => 'الرصيد';

  @override
  String get tabPlans => 'الخطط';

  @override
  String get homeWelcomeBack => 'مرحبًا بعودتك';

  @override
  String homeWelcomeUser(String name) {
    return 'مرحبًا بعودتك، $name';
  }

  @override
  String get homeFinanceOverview => 'نظرة مالية';

  @override
  String get homeDateFilterTitle => 'تصفية حسب التاريخ';

  @override
  String get homeFilterAllMonths => 'كل الشهور';

  @override
  String get homeFilterByMonth => 'شهر';

  @override
  String get homeFilterByDay => 'يوم';

  @override
  String get homeFilterThisMonth => 'هذا الشهر';

  @override
  String get homeFilterPickMonth => 'اختر الشهر';

  @override
  String get homeFilterPickDay => 'اختر اليوم';

  @override
  String get homeFilterToday => 'اليوم';

  @override
  String get homeFilterNoEntries => 'لا توجد عناصر لهذه الفترة';

  @override
  String get accountSettingsTitle => 'إعدادات الحساب';

  @override
  String get changeUsername => 'تغيير اسم المستخدم';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirmTitle => 'حذف الحساب؟';

  @override
  String get deleteAccountConfirmMessage => 'سيتم حذف ملفك الشخصي والدخل والمصروفات والخطط نهائيًا. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get usernameUpdated => 'تم تحديث اسم المستخدم';

  @override
  String get errorEnterUsername => 'يرجى إدخال اسم المستخدم';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get logoutConfirmMessage => 'ستحتاج إلى تسجيل الدخول مرة أخرى لاستخدام التطبيق.';

  @override
  String get loginWelcomeTitle => 'مرحبًا بعودتك 👋';

  @override
  String get loginWelcomeSubtitle => 'سجّل الدخول لمتابعة استخدام حسابك';

  @override
  String get labelEmail => 'البريد الإلكتروني';

  @override
  String get hintEmail => 'example@gmail.com';

  @override
  String get labelPassword => 'كلمة المرور';

  @override
  String get hintPasswordDots => '••••••••';

  @override
  String get forgotPasswordQuestion => 'نسيت كلمة المرور؟';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get orDivider => 'أو';

  @override
  String get noAccountPrompt => 'ليس لديك حساب؟';

  @override
  String get signUpLink => 'إنشاء حساب';

  @override
  String get messageEnterEmailPassword => 'أدخل البريد الإلكتروني وكلمة المرور';

  @override
  String get messageLoginFailed => 'فشل تسجيل الدخول';

  @override
  String get messageLoginSuccess => 'تم تسجيل الدخول بنجاح';

  @override
  String get signupCreateTitle => 'إنشاء حساب 🚀';

  @override
  String get signupCreateSubtitle => 'أنشئ حسابك للمتابعة';

  @override
  String get labelFullName => 'الاسم الكامل';

  @override
  String get hintEnterYourName => 'أدخل اسمك';

  @override
  String get labelConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get createAccountButton => 'إنشاء حساب';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get loginLinkShort => 'تسجيل الدخول';

  @override
  String get signupErrorGeneric => 'حدث خطأ';

  @override
  String get signupSuccessful => 'تم إنشاء الحساب بنجاح';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور؟';

  @override
  String get forgotPasswordDescription => 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور.';

  @override
  String get sendResetLink => 'إرسال كود';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get errorTryAgainGeneric => 'حدث خطأ. يرجى المحاولة مرة أخرى.';

  @override
  String get setNewPasswordTitle => 'تعيين كلمة مرور جديدة 🔒';

  @override
  String get setNewPasswordSubtitle => 'أدخل رمز التحقق وأنشئ كلمة المرور الجديدة.';

  @override
  String get labelOtpCode => 'رمز التحقق';

  @override
  String get hintOtpCode => 'أدخل رمز التحقق';

  @override
  String get labelNewPassword => 'كلمة المرور الجديدة';

  @override
  String get buttonSetNewPassword => 'تعيين كلمة المرور';

  @override
  String get passwordUpdatedSuccessfully => 'تم تحديث كلمة المرور بنجاح ✅';

  @override
  String noRouteForName(Object name) {
    return 'لا يوجد مسار معرّف لـ $name';
  }

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get errorGeneric => 'حدث خطأ ما';

  @override
  String get errorDeleteFailed => 'تعذر الحذف. يرجى المحاولة مرة أخرى.';

  @override
  String get errorDeleteAccountFailed => 'تعذر حذف حسابك. يرجى المحاولة مرة أخرى.';

  @override
  String get errorDeleteAccountRpcRequired => 'حذف الحساب غير مُعد على الخادم. نفّذ supabase/delete_account.sql في مشروع Supabase.';

  @override
  String get addIncome => 'إضافة دخل';

  @override
  String get editIncome => 'تعديل الدخل';

  @override
  String get recentIncomes => 'الدخل الأخير';

  @override
  String get totalIncome => 'إجمالي الدخل';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get editExpense => 'تعديل المصروف';

  @override
  String get recentExpenses => 'المصروفات الأخيرة';

  @override
  String get totalExpenses => 'إجمالي المصروفات';

  @override
  String get noIncomesTitle => 'لا يوجد دخل بعد';

  @override
  String get noIncomesSubtitle => 'اضغط الزر أدناه لتسجيل أول دخل';

  @override
  String get noExpensesTitle => 'لا توجد مصروفات بعد';

  @override
  String get noExpensesSubtitle => 'اضغط الزر أدناه لتسجيل أول مصروف';

  @override
  String get titleField => 'العنوان';

  @override
  String get hintExpenseTitle => 'مثال: مشتريات';

  @override
  String get hintIncomeTitle => 'مثال: الراتب';

  @override
  String get amountField => 'المبلغ';

  @override
  String get categoryField => 'التصنيف';

  @override
  String get otherCategoryField => 'تصنيف آخر';

  @override
  String get otherCategoryHint => 'أدخل اسم التصنيف';

  @override
  String get saveExpense => 'حفظ المصروف';

  @override
  String get updateExpense => 'تحديث المصروف';

  @override
  String get expenseAddedSuccess => 'تمت إضافة المصروف بنجاح';

  @override
  String get expenseUpdatedSuccess => 'تم تحديث المصروف بنجاح';

  @override
  String get saveIncome => 'حفظ الدخل';

  @override
  String get updateIncome => 'تحديث الدخل';

  @override
  String get incomeAddedSuccess => 'تمت إضافة الدخل بنجاح';

  @override
  String get incomeUpdatedSuccess => 'تم تحديث الدخل بنجاح';

  @override
  String get errorEnterTitle => 'يرجى إدخال عنوان';

  @override
  String get errorEnterValidAmount => 'يرجى إدخال مبلغ صالح';

  @override
  String get errorEnterCategoryName => 'يرجى إدخال اسم التصنيف';

  @override
  String get errorSavedExceedsTarget => 'المبلغ المحفوظ لا يمكن أن يتجاوز الهدف';

  @override
  String get expenseCatFood => 'طعام';

  @override
  String get expenseCatRent => 'إيجار';

  @override
  String get expenseCatTransport => 'مواصلات';

  @override
  String get expenseCatShopping => 'تسوق';

  @override
  String get expenseCatBills => 'فواتير';

  @override
  String get expenseCatOther => 'أخرى';

  @override
  String get incomeCatWork => 'عمل';

  @override
  String get incomeCatFreelance => 'عمل حر';

  @override
  String get incomeCatBusiness => 'أعمال';

  @override
  String get incomeCatInvestment => 'استثمار';

  @override
  String get incomeCatOther => 'أخرى';

  @override
  String get planCatSavings => 'ادخار';

  @override
  String get planCatTravel => 'سفر';

  @override
  String get planCatPurchase => 'شراء';

  @override
  String get planCatEducation => 'تعليم';

  @override
  String get planCatOther => 'أخرى';

  @override
  String get planNewFab => 'هدف جديد';

  @override
  String get planEditGoal => 'تعديل الهدف';

  @override
  String get planAddPlan => 'إضافة خطة';

  @override
  String get goalTitleLabel => 'عنوان الهدف';

  @override
  String get goalTitleHint => 'مثال: صندوق الطوارئ';

  @override
  String get targetAmountLabel => 'المبلغ المستهدف';

  @override
  String get amountSavedLabel => 'المبلغ المدخر';

  @override
  String get setDeadlineOptional => 'تحديد موعد نهائي (اختياري)';

  @override
  String get savePlan => 'حفظ الخطة';

  @override
  String get updateGoal => 'تحديث الهدف';

  @override
  String get errorEnterGoalTitle => 'يرجى إدخال عنوان الهدف';

  @override
  String get errorEnterTargetAmount => 'يرجى إدخال مبلغ مستهدف صالح';

  @override
  String get errorEnterAmountSaved => 'يرجى إدخال المبلغ المدخر';

  @override
  String get updateSavedTitle => 'تحديث المدخرات';

  @override
  String targetWithAmount(Object amount) {
    return 'الهدف: $amount';
  }

  @override
  String get saveAmountButton => 'حفظ المبلغ';

  @override
  String get errorEnterValidSavedAmount => 'يرجى إدخال مبلغ مدخر صالح';

  @override
  String get balanceNetBalance => 'صافي الرصيد';

  @override
  String balanceSavedThisMonth(int percent) {
    return 'تم توفير $percent% هذا الشهر';
  }

  @override
  String balanceSavedPercent(int percent) {
    return 'تم توفير $percent%';
  }

  @override
  String get balanceStatIncome => 'الدخل';

  @override
  String get balanceStatExpense => 'المصروفات';

  @override
  String get balanceRecentActivity => 'النشاط الأخير';

  @override
  String get balanceAddToPlan => 'إضافة لهدف';

  @override
  String get balanceAddToPlanTitle => 'إضافة لهدف ادخار';

  @override
  String balanceAddToPlanHint(Object amount) {
    return 'المتاح من الرصيد: $amount';
  }

  @override
  String get balanceSelectPlan => 'اختر هدفاً';

  @override
  String get balanceAmountToAllocate => 'المبلغ للإضافة';

  @override
  String balancePlanRemaining(Object amount) {
    return 'متبقي $amount لإكمال الهدف';
  }

  @override
  String get balanceAddToPlanSuccess => 'تمت إضافة المبلغ لهدف الادخار';

  @override
  String balancePlanAllocationExpenseTitle(String planTitle) {
    return 'هدف ادخار: $planTitle';
  }

  @override
  String get balanceNoPlansForAllocation => 'أنشئ هدف ادخار من تبويب الخطط أولاً.';

  @override
  String get balanceAmountExceedsSurplus => 'المبلغ أكبر من الرصيد المتاح';

  @override
  String itemsCount(int count) {
    return '$count عناصر';
  }

  @override
  String listEntryCount(int count) {
    return '$count سجلًا';
  }

  @override
  String get clearAllExpenses => 'مسح الكل';

  @override
  String get clearAllIncomes => 'مسح الكل';

  @override
  String get clearAllExpensesConfirmTitle => 'حذف كل المصروفات؟';

  @override
  String get clearAllIncomesConfirmTitle => 'حذف كل الإيرادات؟';

  @override
  String clearAllExpensesConfirmMessage(int count) {
    return 'سيتم حذف جميع المصروفات ($count) نهائيًا. لا يمكن التراجع.';
  }

  @override
  String clearAllIncomesConfirmMessage(int count) {
    return 'سيتم حذف جميع الإيرادات ($count) نهائيًا. لا يمكن التراجع.';
  }

  @override
  String get clearAllExpensesSuccess => 'تم حذف كل المصروفات';

  @override
  String get clearAllIncomesSuccess => 'تم حذف كل الإيرادات';

  @override
  String get balanceIncomeVsExpenses => 'الدخل مقابل المصروفات';

  @override
  String get activityIncome => 'دخل';

  @override
  String get activityExpense => 'مصروف';

  @override
  String get plansActive => 'نشط';

  @override
  String get plansDone => 'مكتمل';

  @override
  String get plansRemaining => 'متبقي';

  @override
  String get plansSavingsGoalsSection => 'أهداف الادخار';

  @override
  String get plansGoalsOverview => 'نظرة على الأهداف';

  @override
  String plansSavedOfTarget(Object total) {
    return 'من $total مدخر';
  }

  @override
  String get plansDonePercentLabel => 'مكتمل';

  @override
  String plansGoalsCompletedSummary(int completed, int total) {
    return '$completed من $total أهداف مكتملة';
  }

  @override
  String plansMoneyLeft(Object amount) {
    return 'متبقي $amount';
  }

  @override
  String ofTargetAmount(Object amount) {
    return 'من $amount';
  }

  @override
  String dueDateLabel(Object date) {
    return 'الاستحقاق $date';
  }

  @override
  String get planGoalCompleted => 'اكتمل الهدف';

  @override
  String get planTapToEditGoal => 'اضغط لتعديل الهدف';

  @override
  String get plansEmptyTitle => 'ابدأ هدفك الأول';

  @override
  String get plansEmptySubtitle => 'حدد هدفًا، تتبع ما توفره، وشاهد تقدمك ينمو.';

  @override
  String get plansCreateGoalButton => 'إنشاء هدف';

  @override
  String get demoSalary => 'راتب';

  @override
  String get demoRent => 'إيجار';

  @override
  String get demoFreelanceProject => 'مشروع عمل حر';

  @override
  String get demoGroceries => 'مشتريات';

  @override
  String get demoGas => 'وقود';

  @override
  String get demoElectricBill => 'فاتورة كهرباء';

  @override
  String get demoUtilities => 'مرافق';

  @override
  String get demoSideBusiness => 'عمل جانبي';

  @override
  String get demoEmergencyFund => 'صندوق الطوارئ';

  @override
  String get demoSummerVacation => 'إجازة صيفية';

  @override
  String get demoNewLaptop => 'لابتوب جديد';

  @override
  String storedAsBase(Object amount) {
    return 'يُحفظ كـ $amount (عملة الحساب)';
  }

  @override
  String get smartImportTitle => 'استيراد ذكي';

  @override
  String get smartImportShort => 'فاتورة / SMS';

  @override
  String get smartImportInvoiceTab => 'OCR فواتير';

  @override
  String get smartImportSmsTab => 'رسائل SMS';

  @override
  String get smartImportInvoiceHint => 'التقط صورة للفاتورة أو الإيصال. سنقرأ المبلغ والتاريخ تلقائياً.';

  @override
  String get smartImportDefaultBillTitle => 'فاتورة';

  @override
  String get smartImportScanCamera => 'الكاميرا';

  @override
  String get smartImportScanGallery => 'المعرض';

  @override
  String get smartImportOcrProcessing => 'جاري قراءة الفاتورة…';

  @override
  String get smartImportOcrNoData => 'لم نتمكن من العثور على مبلغ أو تفاصيل في الصورة.';

  @override
  String get smartImportOcrFailed => 'فشلت قراءة الفاتورة. جرّب صورة أوضح.';

  @override
  String get smartImportCameraDenied => 'يلزم إذن الكاميرا لمسح الفواتير.';

  @override
  String get smartImportExtractedData => 'البيانات المستخرجة';

  @override
  String get smartImportDateField => 'التاريخ';

  @override
  String get smartImportTypeField => 'النوع';

  @override
  String get smartImportAddToApp => 'إضافة للتطبيق';

  @override
  String get smartImportSmsNotSupported => 'قراءة SMS متاحة على أندرويد فقط.';

  @override
  String get smartImportSmsEmpty => 'لم يتم العثور على رسائل مالية. امنح إذن SMS إن طُلب.';

  @override
  String get smartImportSmsFailed => 'تعذرت قراءة رسائل SMS.';

  @override
  String get smartImportReloadSms => 'إعادة التحميل';

  @override
  String get smartImportSmsAlreadyAdded => 'مضاف مسبقاً';

  @override
  String get smartImportSmsAddAgain => 'إضافة مرة أخرى';

  @override
  String get smartImportSmsClearAllAdded => 'مسح كل المضاف';

  @override
  String get smartImportSmsClearAllAddedConfirmTitle => 'مسح سجل الاستيراد؟';

  @override
  String get smartImportSmsClearAllAddedConfirmMessage => 'ستظهر كل الرسائل كغير مضافة ويمكنك استيرادها مجدداً. لن تُحذف مصروفاتك أو دخلك الحالي من التطبيق.';

  @override
  String get smartImportSmsClearAllAddedDone => 'تم مسح سجل الاستيراد';

  @override
  String smartImportSmsSkippedDuplicate(int count) {
    return '$count رسالة موجودة بالفعل في التطبيق.';
  }

  @override
  String get smartImportSmsLoadMore => 'تحميل المزيد من الرسائل';

  @override
  String get smartImportSmsLoadingMore => 'جاري التحميل…';

  @override
  String get smartImportUnknownSender => 'مرسل غير معروف';

  @override
  String get smartImportSmsTitleExpense => 'مصروف بنكي';

  @override
  String get smartImportSmsTitleIncome => 'دخل بنكي';

  @override
  String get smartImportTapToImport => 'اضغط للاستيراد';

  @override
  String smartImportAddAllExpenses(int count) {
    return 'إضافة كل المصروفات ($count)';
  }

  @override
  String smartImportAddAllIncomes(int count) {
    return 'إضافة كل الدخل ($count)';
  }

  @override
  String smartImportAddSelected(int count) {
    return 'إضافة المحدد ($count)';
  }

  @override
  String get smartImportSelectAll => 'تحديد الكل';

  @override
  String get smartImportClearSelection => 'إلغاء التحديد';

  @override
  String get smartImportBulkImporting => 'جاري استيراد الرسائل…';

  @override
  String get smartImportBulkNothingToAdd => 'لا توجد رسائل بمبلغ صالح للاستيراد.';

  @override
  String smartImportBulkResult(int incomes, int expenses) {
    return 'تمت إضافة $incomes دخل و$expenses مصروف.';
  }

  @override
  String smartImportBulkPartialFail(int failed) {
    return 'تعذر استيراد $failed رسالة.';
  }
}
