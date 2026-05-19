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
  String get homeFilterByMonth => 'Month';

  @override
  String get homeFilterByDay => 'Day';

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
  String get deleteAccountConfirmMessage =>
      'This will permanently remove your profile, incomes, expenses, and plans. This cannot be undone.';

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
  String get logoutConfirmMessage =>
      'You will need to sign in again to use the app.';

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
  String get forgotPasswordDescription =>
      'Enter your email address and we\'ll send you a password reset link.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get errorTryAgainGeneric => 'An error occurred. Please try again.';

  @override
  String get setNewPasswordTitle => 'Set New Password 🔒';

  @override
  String get setNewPasswordSubtitle =>
      'Enter the OTP code and create your new password.';

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
  String get errorDeleteAccountFailed =>
      'Could not delete your account. Please try again.';

  @override
  String get errorDeleteAccountRpcRequired =>
      'Account deletion is not set up on the server. Run supabase/delete_account.sql in your Supabase project.';

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
  String get noIncomesSubtitle =>
      'Tap the button below to record your first income';

  @override
  String get noExpensesTitle => 'No expenses yet';

  @override
  String get noExpensesSubtitle =>
      'Tap the button below to record your first expense';

  @override
  String get titleField => 'Title';

  @override
  String get hintExpenseTitle => 'e.g. Groceries';

  @override
  String get hintIncomeTitle => 'e.g. Salary';

  @override
  String get amountField => 'Amount';

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
  String get balanceStatIncome => 'Income';

  @override
  String get balanceStatExpense => 'Expenses';

  @override
  String get balanceRecentActivity => 'Recent Activity';

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String listEntryCount(int count) {
    return '$count entries';
  }

  @override
  String get balanceIncomeVsExpenses => 'Income vs Expenses';

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
  String get plansEmptySubtitle =>
      'Set a target, track what you save, and watch your progress grow.';

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
}
