// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'imrpo';

  @override
  String get tabIncomes => 'Incomes';

  @override
  String get tabExpenses => 'Expenses';

  @override
  String get tabBalance => 'Balance';

  @override
  String get tabPlans => 'Plans';

  @override
  String get homeWelcomeBack => 'Welcome back';

  @override
  String homeWelcomeUser(String name) {
    return 'Welcome back, $name';
  }

  @override
  String get homeFinanceOverview => 'Finance Overview';

  @override
  String get homeDateFilterTitle => 'Filter by date';

  @override
  String get homeFilterAllMonths => 'All months';

  @override
  String get homeFilterByMonth => 'Month';

  @override
  String get homeFilterByDay => 'Day';

  @override
  String get homeFilterThisMonth => 'This month';

  @override
  String get homeFilterPickMonth => 'Pick month';

  @override
  String get homeFilterPickDay => 'Pick day';

  @override
  String get homeFilterToday => 'Today';

  @override
  String get homeFilterNoEntries => 'No entries for this period';

  @override
  String get accountSettingsTitle => 'Account settings';

  @override
  String get changeUsername => 'Change username';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsCalculator => 'Calculator';

  @override
  String get calculatorTitle => 'Calculator';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get logout => 'Log out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirmTitle => 'Delete account?';

  @override
  String get deleteAccountConfirmMessage => 'This will permanently remove your profile, incomes, expenses, and plans. This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get usernameUpdated => 'Username updated';

  @override
  String get errorEnterUsername => 'Please enter a username';

  @override
  String get logoutConfirmTitle => 'Log out?';

  @override
  String get logoutConfirmMessage => 'You will need to sign in again to use the app.';

  @override
  String get loginWelcomeTitle => 'Welcome Back 👋';

  @override
  String get loginWelcomeSubtitle => 'Login to continue using your account';

  @override
  String get labelEmail => 'Email';

  @override
  String get hintEmail => 'example@gmail.com';

  @override
  String get labelPassword => 'Password';

  @override
  String get hintPasswordDots => '••••••••';

  @override
  String get forgotPasswordQuestion => 'Forgot Password?';

  @override
  String get loginButton => 'Login';

  @override
  String get orDivider => 'OR';

  @override
  String get noAccountPrompt => 'Don\'t have an account?';

  @override
  String get signUpLink => 'Sign Up';

  @override
  String get messageEnterEmailPassword => 'Enter email and password';

  @override
  String get messageLoginFailed => 'Login failed';

  @override
  String get messageLoginSuccess => 'Login successfully';

  @override
  String get signupCreateTitle => 'Create Account 🚀';

  @override
  String get signupCreateSubtitle => 'Create your account to continue';

  @override
  String get labelFullName => 'Full Name';

  @override
  String get hintEnterYourName => 'Enter your name';

  @override
  String get labelConfirmPassword => 'Confirm Password';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get loginLinkShort => 'Login';

  @override
  String get signupErrorGeneric => 'An error occurred';

  @override
  String get signupSuccessful => 'Signup successful';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordDescription => 'Enter your email address and we\'ll send you a password reset link.';

  @override
  String get sendResetLink => 'Send Reset OTP';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get errorTryAgainGeneric => 'An error occurred. Please try again.';

  @override
  String get setNewPasswordTitle => 'Set New Password 🔒';

  @override
  String get setNewPasswordSubtitle => 'Enter the OTP code and create your new password.';

  @override
  String get labelOtpCode => 'OTP Code';

  @override
  String get hintOtpCode => 'Enter verification code';

  @override
  String get labelNewPassword => 'New Password';

  @override
  String get buttonSetNewPassword => 'Set New Password';

  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully ✅';

  @override
  String noRouteForName(Object name) {
    return 'No route defined for $name';
  }

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorDeleteFailed => 'Could not delete. Please try again.';

  @override
  String get errorDeleteAccountFailed => 'Could not delete your account. Please try again.';

  @override
  String get errorDeleteAccountRpcRequired => 'Account deletion is not set up on the server. Run supabase/delete_account.sql in your Supabase project.';

  @override
  String get addIncome => 'Add Income';

  @override
  String get editIncome => 'Edit Income';

  @override
  String get recentIncomes => 'Recent Incomes';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get recentExpenses => 'Recent Expenses';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get noIncomesTitle => 'No incomes yet';

  @override
  String get noIncomesSubtitle => 'Tap the button below to record your first income';

  @override
  String get noExpensesTitle => 'No expenses yet';

  @override
  String get noExpensesSubtitle => 'Tap the button below to record your first expense';

  @override
  String get titleField => 'Title';

  @override
  String get hintExpenseTitle => 'e.g. Groceries';

  @override
  String get hintIncomeTitle => 'e.g. March payment';

  @override
  String get incomeSourceField => 'Source';

  @override
  String get hintIncomeSource => 'e.g. Visa card, Rents, Salary';

  @override
  String get incomeBySource => 'By source';

  @override
  String get incomeFilterAllSources => 'All sources';

  @override
  String get incomeFilterNoSourceEntries => 'No incomes for this source in the selected period';

  @override
  String get incomeSourceRents => 'Rents';

  @override
  String get incomeSourceVisaCard => 'Visa card';

  @override
  String get incomeSourceCash => 'Cash';

  @override
  String get amountField => 'Amount';

  @override
  String get expenseByCategory => 'By category';

  @override
  String get expenseCategoryEdit => 'Edit category';

  @override
  String get expenseCategoryRemove => 'Remove category';

  @override
  String get expenseCategoryRenameTitle => 'Rename category';

  @override
  String expenseCategoryRenameHint(String name) {
    return 'Updates all expenses in \"$name\".';
  }

  @override
  String get expenseCategoryNameTaken => 'That category name is already in use';

  @override
  String get expenseCategoryUpdatedSuccess => 'Category updated';

  @override
  String get expenseCategoryRemoveTitle => 'Remove category';

  @override
  String expenseCategoryRemoveMessage(int count, String name) {
    return 'What should happen to $count expense(s) in \"$name\"?';
  }

  @override
  String get expenseCategoryMoveToOther => 'Move all to Other';

  @override
  String get expenseCategoryDeleteAll => 'Delete all expenses in this category';

  @override
  String get expenseCategoryDeleteConfirmTitle => 'Delete expenses?';

  @override
  String expenseCategoryDeleteConfirmMessage(int count) {
    return 'This permanently deletes $count expense(s). This cannot be undone.';
  }

  @override
  String get expenseCategoryDeleteConfirmAction => 'Delete';

  @override
  String get expenseFilterAllCategories => 'All categories';

  @override
  String get expenseFilterNoCategoryEntries => 'No expenses for this category in the selected period';

  @override
  String get budgetMonthlyTitle => 'Monthly budgets';

  @override
  String get budgetSetAction => 'Set budget';

  @override
  String get budgetSetTitle => 'Set monthly budget';

  @override
  String get budgetSetHint => 'Pick a category and set how much you plan to spend this month.';

  @override
  String get budgetCustomCategory => 'Category name';

  @override
  String get budgetMonthlyLimit => 'Monthly limit';

  @override
  String get budgetSave => 'Save budget';

  @override
  String get budgetEmptyHint => 'Set a limit per category to see how much of your budget you\'ve used.';

  @override
  String get budgetSetFirst => 'Create first budget';

  @override
  String get budgetTotalSpent => 'Total spent';

  @override
  String budgetRemaining(String amount) {
    return '$amount left';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Over by $amount';
  }

  @override
  String get budgetDeleteTitle => 'Remove budget?';

  @override
  String budgetDeleteMessage(String category) {
    return 'Remove the budget for $category?';
  }

  @override
  String get budgetDeleteConfirm => 'Remove';

  @override
  String budgetAlertNear(int count) {
    return '$count category near the limit';
  }

  @override
  String budgetAlertOver(int count) {
    return '$count category over budget';
  }

  @override
  String budgetAlertOverAndNear(int over, int near) {
    return '$over over budget, $near near limit';
  }

  @override
  String get categoryField => 'Category';

  @override
  String get otherCategoryField => 'Other category';

  @override
  String get otherCategoryHint => 'Enter category name';

  @override
  String get saveExpense => 'Save Expense';

  @override
  String get updateExpense => 'Update Expense';

  @override
  String get expenseAddedSuccess => 'Expense added successfully';

  @override
  String get expenseUpdatedSuccess => 'Expense updated successfully';

  @override
  String get saveIncome => 'Save Income';

  @override
  String get updateIncome => 'Update Income';

  @override
  String get incomeAddedSuccess => 'Income added successfully';

  @override
  String get incomeUpdatedSuccess => 'Income updated successfully';

  @override
  String get errorEnterTitle => 'Please enter a title';

  @override
  String get errorEnterValidAmount => 'Please enter a valid amount';

  @override
  String get errorEnterCategoryName => 'Please enter a category name';

  @override
  String get errorSavedExceedsTarget => 'Saved amount cannot exceed target';

  @override
  String get expenseCatFood => 'Food';

  @override
  String get expenseCatRent => 'Rent';

  @override
  String get expenseCatTransport => 'Transport';

  @override
  String get expenseCatShopping => 'Shopping';

  @override
  String get expenseCatBills => 'Bills';

  @override
  String get expenseCatOther => 'Other';

  @override
  String get incomeCatWork => 'Work';

  @override
  String get incomeCatFreelance => 'Freelance';

  @override
  String get incomeCatBusiness => 'Business';

  @override
  String get incomeCatInvestment => 'Investment';

  @override
  String get incomeCatOther => 'Other';

  @override
  String get planCatSavings => 'Savings';

  @override
  String get planCatTravel => 'Travel';

  @override
  String get planCatPurchase => 'Purchase';

  @override
  String get planCatEducation => 'Education';

  @override
  String get planCatOther => 'Other';

  @override
  String get planNewFab => 'New goal';

  @override
  String get planEditGoal => 'Edit Goal';

  @override
  String get planAddPlan => 'Add Plan';

  @override
  String get goalTitleLabel => 'Goal title';

  @override
  String get goalTitleHint => 'e.g. Emergency Fund';

  @override
  String get targetAmountLabel => 'Target amount';

  @override
  String get amountSavedLabel => 'Amount saved';

  @override
  String get setDeadlineOptional => 'Set deadline (optional)';

  @override
  String get savePlan => 'Save Plan';

  @override
  String get updateGoal => 'Update Goal';

  @override
  String get errorEnterGoalTitle => 'Please enter a goal title';

  @override
  String get errorEnterTargetAmount => 'Please enter a valid target amount';

  @override
  String get errorEnterAmountSaved => 'Please enter amount saved';

  @override
  String get updateSavedTitle => 'Update saved';

  @override
  String targetWithAmount(Object amount) {
    return 'Target: $amount';
  }

  @override
  String get saveAmountButton => 'Save amount';

  @override
  String get errorEnterValidSavedAmount => 'Please enter a valid saved amount';

  @override
  String get balanceNetBalance => 'Net Balance';

  @override
  String balanceSavedThisMonth(int percent) {
    return '$percent% saved this month';
  }

  @override
  String balanceSavedPercent(int percent) {
    return '$percent% saved';
  }

  @override
  String get balanceStatIncome => 'Income';

  @override
  String get balanceStatExpense => 'Expenses';

  @override
  String get balanceRecentActivity => 'Recent Activity';

  @override
  String get balanceAddToPlan => 'Add to goal';

  @override
  String get balanceAddToPlanTitle => 'Add to savings goal';

  @override
  String balanceAddToPlanHint(Object amount) {
    return 'Available from balance: $amount';
  }

  @override
  String get balanceSelectPlan => 'Choose a goal';

  @override
  String get balanceAmountToAllocate => 'Amount to add';

  @override
  String balancePlanRemaining(Object amount) {
    return '$amount left to reach target';
  }

  @override
  String get balanceAddToPlanSuccess => 'Amount added to your savings goal';

  @override
  String balancePlanAllocationExpenseTitle(String planTitle) {
    return 'Savings goal: $planTitle';
  }

  @override
  String get balanceNoPlansForAllocation => 'Create a savings goal in the Plans tab first.';

  @override
  String get balanceAmountExceedsSurplus => 'Amount exceeds your available balance';

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String listEntryCount(int count) {
    return '$count entries';
  }

  @override
  String get clearAllExpenses => 'Clear all';

  @override
  String get clearAllIncomes => 'Clear all';

  @override
  String get clearAllExpensesConfirmTitle => 'Delete all expenses?';

  @override
  String get clearAllIncomesConfirmTitle => 'Delete all incomes?';

  @override
  String clearAllExpensesConfirmMessage(int count) {
    return 'This will permanently delete all $count expenses. This cannot be undone.';
  }

  @override
  String clearAllIncomesConfirmMessage(int count) {
    return 'This will permanently delete all $count incomes. This cannot be undone.';
  }

  @override
  String get clearAllExpensesSuccess => 'All expenses deleted';

  @override
  String get clearAllIncomesSuccess => 'All incomes deleted';

  @override
  String get balanceIncomeVsExpenses => 'Income vs Expenses';

  @override
  String get balanceFilterAll => 'All';

  @override
  String get balanceFilterIncome => 'Income';

  @override
  String get balanceFilterExpense => 'Expenses';

  @override
  String get balanceNoFilteredActivity => 'No activity matches this filter';

  @override
  String get activityIncome => 'Income';

  @override
  String get activityExpense => 'Expense';

  @override
  String get plansActive => 'Active';

  @override
  String get plansDone => 'Done';

  @override
  String get plansRemaining => 'Left';

  @override
  String get plansSavingsGoalsSection => 'Savings goals';

  @override
  String get plansGoalsOverview => 'Goals overview';

  @override
  String plansSavedOfTarget(Object total) {
    return 'of $total saved';
  }

  @override
  String get plansDonePercentLabel => 'done';

  @override
  String plansGoalsCompletedSummary(int completed, int total) {
    return '$completed of $total goals completed';
  }

  @override
  String plansMoneyLeft(Object amount) {
    return '$amount left';
  }

  @override
  String ofTargetAmount(Object amount) {
    return 'of $amount';
  }

  @override
  String dueDateLabel(Object date) {
    return 'Due $date';
  }

  @override
  String get planGoalCompleted => 'Goal completed';

  @override
  String get planTapToEditGoal => 'Tap to edit goal';

  @override
  String get plansEmptyTitle => 'Start your first goal';

  @override
  String get plansEmptySubtitle => 'Set a target, track what you save, and watch your progress grow.';

  @override
  String get plansCreateGoalButton => 'Create goal';

  @override
  String get demoSalary => 'Salary';

  @override
  String get demoRent => 'Rent';

  @override
  String get demoFreelanceProject => 'Freelance Project';

  @override
  String get demoGroceries => 'Groceries';

  @override
  String get demoGas => 'Gas';

  @override
  String get demoElectricBill => 'Electric Bill';

  @override
  String get demoUtilities => 'Utilities';

  @override
  String get demoSideBusiness => 'Side Business';

  @override
  String get demoEmergencyFund => 'Emergency Fund';

  @override
  String get demoSummerVacation => 'Summer Vacation';

  @override
  String get demoNewLaptop => 'New Laptop';

  @override
  String storedAsBase(Object amount) {
    return 'Stored as $amount base';
  }

  @override
  String get smartImportTitle => 'Smart import';

  @override
  String get smartImportShort => 'Scan / SMS';

  @override
  String get smartImportInvoiceTab => 'Invoice OCR';

  @override
  String get smartImportSmsTab => 'SMS';

  @override
  String get smartImportInvoiceHint => 'Take a photo of a receipt or invoice. We\'ll read the amount and date automatically.';

  @override
  String get smartImportDefaultBillTitle => 'Bill';

  @override
  String get smartImportScanCamera => 'Camera';

  @override
  String get smartImportScanGallery => 'Gallery';

  @override
  String get smartImportOcrProcessing => 'Reading invoice…';

  @override
  String get smartImportOcrNoData => 'Could not find amount or details on this image.';

  @override
  String get smartImportOcrFailed => 'Failed to read the invoice. Try a clearer photo.';

  @override
  String get smartImportCameraDenied => 'Camera permission is required to scan invoices.';

  @override
  String get smartImportExtractedData => 'Extracted data';

  @override
  String get smartImportDateField => 'Date';

  @override
  String get smartImportTypeField => 'Type';

  @override
  String get smartImportAddToApp => 'Add to app';

  @override
  String get smartImportSmsNotSupported => 'SMS import is available on Android only.';

  @override
  String get smartImportSmsEmpty => 'No financial SMS messages found. Grant SMS permission if prompted.';

  @override
  String get smartImportSmsFailed => 'Could not read SMS messages.';

  @override
  String get smartImportReloadSms => 'Reload';

  @override
  String get smartImportSmsAlreadyAdded => 'Already added';

  @override
  String get smartImportSmsAddAgain => 'Add again';

  @override
  String get smartImportSmsClearAllAdded => 'Clear all added';

  @override
  String get smartImportSmsClearAllAddedConfirmTitle => 'Clear imported history?';

  @override
  String get smartImportSmsClearAllAddedConfirmMessage => 'All SMS will show as not added. You can import them again. Your existing expenses and incomes are not deleted.';

  @override
  String get smartImportSmsClearAllAddedDone => 'Imported history cleared';

  @override
  String smartImportSmsSkippedDuplicate(int count) {
    return '$count message(s) were already in the app.';
  }

  @override
  String get smartImportSmsLoadMore => 'Load more messages';

  @override
  String get smartImportSmsLoading => 'Reading your SMS messages…';

  @override
  String get smartImportSmsLoadingMore => 'Loading more…';

  @override
  String get smartImportUnknownSender => 'Unknown sender';

  @override
  String get smartImportSmsTitleExpense => 'Bank expense';

  @override
  String get smartImportSmsTitleIncome => 'Bank income';

  @override
  String get smartImportTapToImport => 'Tap to import';

  @override
  String smartImportAddAllExpenses(int count) {
    return 'Add all expenses ($count)';
  }

  @override
  String smartImportAddAllIncomes(int count) {
    return 'Add all incomes ($count)';
  }

  @override
  String smartImportAddSelected(int count) {
    return 'Add selected ($count)';
  }

  @override
  String get smartImportSelectAll => 'Select all';

  @override
  String get smartImportClearSelection => 'Clear';

  @override
  String get smartImportBulkCategorySheetTitle => 'Category for import';

  @override
  String get smartImportBulkCategorySheetHint => 'Apply the same category or source to all selected messages.';

  @override
  String get smartImportBulkExpenseCategory => 'Expense category';

  @override
  String get smartImportBulkIncomeSource => 'Income source';

  @override
  String get smartImportBulkApplyAndImport => 'Import';

  @override
  String get smartImportBulkImporting => 'Importing messages…';

  @override
  String get smartImportBulkNothingToAdd => 'No messages with a valid amount to import.';

  @override
  String smartImportBulkResult(int incomes, int expenses) {
    return 'Added $incomes incomes and $expenses expenses.';
  }

  @override
  String smartImportBulkPartialFail(int failed) {
    return '$failed message(s) could not be imported.';
  }

  @override
  String get settingsAppLock => 'App lock';

  @override
  String get settingsAppLockBiometric => 'Face ID / fingerprint';

  @override
  String get settingsAppLockChangePin => 'Change PIN';

  @override
  String get appLockTitle => 'Unlock Pocketly';

  @override
  String get appLockSubtitle => 'Enter your PIN to continue';

  @override
  String get appLockWrongPin => 'Incorrect PIN. Try again.';

  @override
  String get appLockBiometricReason => 'Unlock your finances';

  @override
  String get appLockEnterPinTitle => 'Enter your PIN';

  @override
  String get appLockEnterPinSubtitle => 'Confirm to continue';

  @override
  String get appLockCreatePinTitle => 'Create a PIN';

  @override
  String get appLockCreatePinSubtitle => 'Use 4 digits you will remember';

  @override
  String get appLockConfirmPinTitle => 'Confirm your PIN';

  @override
  String get appLockConfirmPinSubtitle => 'Enter the same PIN again';

  @override
  String get appLockPinMismatch => 'PINs do not match';

  @override
  String get appLockEnabledSuccess => 'App lock is on';

  @override
  String get appLockDisabledSuccess => 'App lock is off';

  @override
  String get appLockEnableFailed => 'Could not enable app lock';

  @override
  String get appLockBiometricPromptTitle => 'Use biometrics?';

  @override
  String get appLockBiometricPromptMessage => 'Unlock faster with Face ID or fingerprint on this device.';

  @override
  String get appLockBiometricFailed => 'Biometrics could not be enabled';

  @override
  String get appLockChangePinSuccess => 'PIN updated';

  @override
  String get appLockChangePinFailed => 'Could not update PIN';

  @override
  String get notNow => 'Not now';

  @override
  String get enable => 'Enable';

  @override
  String get monthlyReportTitle => 'Monthly report';

  @override
  String get monthlyReportShort => 'Report';

  @override
  String get monthlyReportVsLastMonth => 'Compared to last month';

  @override
  String get monthlyReportBudgetTitle => 'Budget vs actual';

  @override
  String get monthlyReportNoBudgets => 'No budgets set for this month. Add limits on the Expenses tab to track spending here.';

  @override
  String monthlyReportEntrySummary(int incomeCount, int expenseCount) {
    return '$incomeCount income sources · $expenseCount expense categories';
  }

  @override
  String get globalSearchTitle => 'Search';

  @override
  String get globalSearchHint => 'Title, category, source, amount…';

  @override
  String get globalSearchAll => 'All';

  @override
  String get globalSearchNoResults => 'No matching entries';

  @override
  String get globalSearchAllTime => 'All time';

  @override
  String get globalSearchCurrentPeriod => 'This period';
}
