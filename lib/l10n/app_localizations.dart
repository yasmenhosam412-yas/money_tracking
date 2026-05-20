import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'imrpo'**
  String get appTitle;

  /// No description provided for @tabIncomes.
  ///
  /// In en, this message translates to:
  /// **'Incomes'**
  String get tabIncomes;

  /// No description provided for @tabExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get tabExpenses;

  /// No description provided for @tabBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get tabBalance;

  /// No description provided for @tabPlans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get tabPlans;

  /// No description provided for @homeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeWelcomeBack;

  /// No description provided for @homeWelcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String homeWelcomeUser(String name);

  /// No description provided for @homeFinanceOverview.
  ///
  /// In en, this message translates to:
  /// **'Finance Overview'**
  String get homeFinanceOverview;

  /// No description provided for @homeDateFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get homeDateFilterTitle;

  /// No description provided for @homeFilterAllMonths.
  ///
  /// In en, this message translates to:
  /// **'All months'**
  String get homeFilterAllMonths;

  /// No description provided for @homeFilterByMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get homeFilterByMonth;

  /// No description provided for @homeFilterByDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get homeFilterByDay;

  /// No description provided for @homeFilterThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get homeFilterThisMonth;

  /// No description provided for @homeFilterPickMonth.
  ///
  /// In en, this message translates to:
  /// **'Pick month'**
  String get homeFilterPickMonth;

  /// No description provided for @homeFilterPickDay.
  ///
  /// In en, this message translates to:
  /// **'Pick day'**
  String get homeFilterPickDay;

  /// No description provided for @homeFilterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeFilterToday;

  /// No description provided for @homeFilterNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries for this period'**
  String get homeFilterNoEntries;

  /// No description provided for @accountSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get accountSettingsTitle;

  /// No description provided for @changeUsername.
  ///
  /// In en, this message translates to:
  /// **'Change username'**
  String get changeUsername;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsCalculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get settingsCalculator;

  /// No description provided for @calculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculatorTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove your profile, incomes, expenses, and plans. This cannot be undone.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @usernameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Username updated'**
  String get usernameUpdated;

  /// No description provided for @errorEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get errorEnterUsername;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to use the app.'**
  String get logoutConfirmMessage;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back 👋'**
  String get loginWelcomeTitle;

  /// No description provided for @loginWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to continue using your account'**
  String get loginWelcomeSubtitle;

  /// No description provided for @labelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get labelEmail;

  /// No description provided for @hintEmail.
  ///
  /// In en, this message translates to:
  /// **'example@gmail.com'**
  String get hintEmail;

  /// No description provided for @labelPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get labelPassword;

  /// No description provided for @hintPasswordDots.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get hintPasswordDots;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordQuestion;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountPrompt;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpLink;

  /// No description provided for @messageEnterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter email and password'**
  String get messageEnterEmailPassword;

  /// No description provided for @messageLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get messageLoginFailed;

  /// No description provided for @messageLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successfully'**
  String get messageLoginSuccess;

  /// No description provided for @signupCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account 🚀'**
  String get signupCreateTitle;

  /// No description provided for @signupCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account to continue'**
  String get signupCreateSubtitle;

  /// No description provided for @labelFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get labelFullName;

  /// No description provided for @hintEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get hintEnterYourName;

  /// No description provided for @labelConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get labelConfirmPassword;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginLinkShort.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLinkShort;

  /// No description provided for @signupErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get signupErrorGeneric;

  /// No description provided for @signupSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Signup successful'**
  String get signupSuccessful;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a password reset link.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset OTP'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @errorTryAgainGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorTryAgainGeneric;

  /// No description provided for @setNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set New Password 🔒'**
  String get setNewPasswordTitle;

  /// No description provided for @setNewPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP code and create your new password.'**
  String get setNewPasswordSubtitle;

  /// No description provided for @labelOtpCode.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get labelOtpCode;

  /// No description provided for @hintOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get hintOtpCode;

  /// No description provided for @labelNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get labelNewPassword;

  /// No description provided for @buttonSetNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get buttonSetNewPassword;

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully ✅'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @noRouteForName.
  ///
  /// In en, this message translates to:
  /// **'No route defined for {name}'**
  String noRouteForName(Object name);

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @errorDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete. Please try again.'**
  String get errorDeleteFailed;

  /// No description provided for @errorDeleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your account. Please try again.'**
  String get errorDeleteAccountFailed;

  /// No description provided for @errorDeleteAccountRpcRequired.
  ///
  /// In en, this message translates to:
  /// **'Account deletion is not set up on the server. Run supabase/delete_account.sql in your Supabase project.'**
  String get errorDeleteAccountRpcRequired;

  /// No description provided for @addIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncome;

  /// No description provided for @editIncome.
  ///
  /// In en, this message translates to:
  /// **'Edit Income'**
  String get editIncome;

  /// No description provided for @recentIncomes.
  ///
  /// In en, this message translates to:
  /// **'Recent Incomes'**
  String get recentIncomes;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @recentExpenses.
  ///
  /// In en, this message translates to:
  /// **'Recent Expenses'**
  String get recentExpenses;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @noIncomesTitle.
  ///
  /// In en, this message translates to:
  /// **'No incomes yet'**
  String get noIncomesTitle;

  /// No description provided for @noIncomesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to record your first income'**
  String get noIncomesSubtitle;

  /// No description provided for @noExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpensesTitle;

  /// No description provided for @noExpensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to record your first expense'**
  String get noExpensesSubtitle;

  /// No description provided for @titleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleField;

  /// No description provided for @hintExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'e.g. Groceries'**
  String get hintExpenseTitle;

  /// No description provided for @hintIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'e.g. March payment'**
  String get hintIncomeTitle;

  /// No description provided for @incomeSourceField.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get incomeSourceField;

  /// No description provided for @hintIncomeSource.
  ///
  /// In en, this message translates to:
  /// **'e.g. Visa card, Rents, Salary'**
  String get hintIncomeSource;

  /// No description provided for @incomeBySource.
  ///
  /// In en, this message translates to:
  /// **'By source'**
  String get incomeBySource;

  /// No description provided for @balanceRemainingBySource.
  ///
  /// In en, this message translates to:
  /// **'Remaining by source'**
  String get balanceRemainingBySource;

  /// No description provided for @paymentMethodAddChip.
  ///
  /// In en, this message translates to:
  /// **'+ Add method'**
  String get paymentMethodAddChip;

  /// No description provided for @paymentMethodAddCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get paymentMethodAddCancel;

  /// No description provided for @paymentMethodNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New method name'**
  String get paymentMethodNewLabel;

  /// No description provided for @paymentMethodNewHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Vodafone Cash, InstaPay, Fawry'**
  String get paymentMethodNewHint;

  /// No description provided for @paymentMethodSave.
  ///
  /// In en, this message translates to:
  /// **'Save method'**
  String get paymentMethodSave;

  /// No description provided for @paymentMethodNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for the payment method.'**
  String get paymentMethodNameEmpty;

  /// No description provided for @paymentMethodAdded.
  ///
  /// In en, this message translates to:
  /// **'Added \"{name}\" to your methods.'**
  String paymentMethodAdded(String name);

  /// No description provided for @expensePaidFromField.
  ///
  /// In en, this message translates to:
  /// **'Paid from'**
  String get expensePaidFromField;

  /// No description provided for @expensePaidFromNone.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get expensePaidFromNone;

  /// No description provided for @incomeUnassignedSpending.
  ///
  /// In en, this message translates to:
  /// **'Unassigned spending'**
  String get incomeUnassignedSpending;

  /// No description provided for @incomeFilterAllSources.
  ///
  /// In en, this message translates to:
  /// **'All sources'**
  String get incomeFilterAllSources;

  /// No description provided for @incomeFilterNoSourceEntries.
  ///
  /// In en, this message translates to:
  /// **'No incomes for this source in the selected period'**
  String get incomeFilterNoSourceEntries;

  /// No description provided for @incomeSourceManageEdit.
  ///
  /// In en, this message translates to:
  /// **'Rename source'**
  String get incomeSourceManageEdit;

  /// No description provided for @incomeSourceManageRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove source'**
  String get incomeSourceManageRemove;

  /// No description provided for @incomeSourceRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename source'**
  String get incomeSourceRenameTitle;

  /// No description provided for @incomeSourceRenameHint.
  ///
  /// In en, this message translates to:
  /// **'Updates all incomes with source \"{name}\".'**
  String incomeSourceRenameHint(String name);

  /// No description provided for @incomeSourceNameTaken.
  ///
  /// In en, this message translates to:
  /// **'That source name is already in use'**
  String get incomeSourceNameTaken;

  /// No description provided for @incomeSourceUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sources updated'**
  String get incomeSourceUpdatedSuccess;

  /// No description provided for @incomeSourceRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove source'**
  String get incomeSourceRemoveTitle;

  /// No description provided for @incomeSourceRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'What should happen to {count} income(s) with source \"{name}\"?'**
  String incomeSourceRemoveMessage(int count, String name);

  /// No description provided for @incomeSourceMoveToOther.
  ///
  /// In en, this message translates to:
  /// **'Move all to Other'**
  String get incomeSourceMoveToOther;

  /// No description provided for @incomeSourceDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all incomes with this source'**
  String get incomeSourceDeleteAll;

  /// No description provided for @incomeSourceDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete incomes?'**
  String get incomeSourceDeleteConfirmTitle;

  /// No description provided for @incomeSourceDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes {count} income(s). This cannot be undone.'**
  String incomeSourceDeleteConfirmMessage(int count);

  /// No description provided for @incomeSourceDeleteConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get incomeSourceDeleteConfirmAction;

  /// No description provided for @incomeSourceRents.
  ///
  /// In en, this message translates to:
  /// **'Rents'**
  String get incomeSourceRents;

  /// No description provided for @incomeSourceVisaCard.
  ///
  /// In en, this message translates to:
  /// **'Visa card'**
  String get incomeSourceVisaCard;

  /// No description provided for @incomeSourceCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get incomeSourceCash;

  /// No description provided for @amountField.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountField;

  /// No description provided for @expenseAmountShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Quick amounts'**
  String get expenseAmountShortcuts;

  /// No description provided for @expenseShortcutTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get expenseShortcutTransport;

  /// No description provided for @expenseShortcutCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get expenseShortcutCoffee;

  /// No description provided for @expenseShortcutSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get expenseShortcutSnack;

  /// No description provided for @expenseFabMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get expenseFabMenuTitle;

  /// No description provided for @expenseFabBlankOption.
  ///
  /// In en, this message translates to:
  /// **'Blank form'**
  String get expenseFabBlankOption;

  /// No description provided for @expenseFabFromLastPaste.
  ///
  /// In en, this message translates to:
  /// **'From last parsed message'**
  String get expenseFabFromLastPaste;

  /// No description provided for @expenseFabFromLastPasteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Uses the last bank or wallet message you parsed in Smart import'**
  String get expenseFabFromLastPasteSubtitle;

  /// No description provided for @expenseLastPasteNotExpense.
  ///
  /// In en, this message translates to:
  /// **'Last parsed message looks like income. Add it from the Incomes tab.'**
  String get expenseLastPasteNotExpense;

  /// No description provided for @expenseShortcutsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'One-tap expenses'**
  String get expenseShortcutsSectionTitle;

  /// No description provided for @expenseShortcutsEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Set up one-tap shortcuts'**
  String get expenseShortcutsEmptyCta;

  /// No description provided for @expenseShortcutsManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense shortcuts'**
  String get expenseShortcutsManageTitle;

  /// No description provided for @expenseShortcutsManageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save a label, title, category, paid-from, and amount. Tap the chip on the Expenses tab to log instantly.'**
  String get expenseShortcutsManageSubtitle;

  /// No description provided for @expenseShortcutsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No shortcuts yet. Add your first coffee, transport, or other repeat purchase.'**
  String get expenseShortcutsEmptyBody;

  /// No description provided for @expenseShortcutAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New shortcut'**
  String get expenseShortcutAddTitle;

  /// No description provided for @expenseShortcutEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit shortcut'**
  String get expenseShortcutEditTitle;

  /// No description provided for @expenseShortcutChipLabelField.
  ///
  /// In en, this message translates to:
  /// **'Chip label'**
  String get expenseShortcutChipLabelField;

  /// No description provided for @expenseShortcutChipLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Coffee'**
  String get expenseShortcutChipLabelHint;

  /// No description provided for @expenseShortcutExpenseTitleField.
  ///
  /// In en, this message translates to:
  /// **'Expense title'**
  String get expenseShortcutExpenseTitleField;

  /// No description provided for @expenseShortcutFormHint.
  ///
  /// In en, this message translates to:
  /// **'The chip logs this expense for today with one tap — no form.'**
  String get expenseShortcutFormHint;

  /// No description provided for @expenseShortcutSave.
  ///
  /// In en, this message translates to:
  /// **'Save shortcut'**
  String get expenseShortcutSave;

  /// No description provided for @expenseShortcutDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get expenseShortcutDelete;

  /// No description provided for @expenseShortcutDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete shortcut?'**
  String get expenseShortcutDeleteConfirmTitle;

  /// No description provided for @expenseShortcutDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\"?'**
  String expenseShortcutDeleteConfirmMessage(String name);

  /// No description provided for @expenseShortcutLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged: {name}'**
  String expenseShortcutLogged(String name);

  /// No description provided for @expenseShortcutErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter a chip label'**
  String get expenseShortcutErrorLabel;

  /// No description provided for @expenseByCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get expenseByCategory;

  /// No description provided for @expenseCategoryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get expenseCategoryEdit;

  /// No description provided for @expenseCategoryRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove category'**
  String get expenseCategoryRemove;

  /// No description provided for @expenseCategoryRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename category'**
  String get expenseCategoryRenameTitle;

  /// No description provided for @expenseCategoryRenameHint.
  ///
  /// In en, this message translates to:
  /// **'Updates all expenses in \"{name}\".'**
  String expenseCategoryRenameHint(String name);

  /// No description provided for @expenseCategoryNameTaken.
  ///
  /// In en, this message translates to:
  /// **'That category name is already in use'**
  String get expenseCategoryNameTaken;

  /// No description provided for @expenseCategoryUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category updated'**
  String get expenseCategoryUpdatedSuccess;

  /// No description provided for @expenseCategoryRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove category'**
  String get expenseCategoryRemoveTitle;

  /// No description provided for @expenseCategoryRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'What should happen to {count} expense(s) in \"{name}\"?'**
  String expenseCategoryRemoveMessage(int count, String name);

  /// No description provided for @expenseCategoryMoveToOther.
  ///
  /// In en, this message translates to:
  /// **'Move all to Other'**
  String get expenseCategoryMoveToOther;

  /// No description provided for @expenseCategoryDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all expenses in this category'**
  String get expenseCategoryDeleteAll;

  /// No description provided for @expenseCategoryDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete expenses?'**
  String get expenseCategoryDeleteConfirmTitle;

  /// No description provided for @expenseCategoryDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes {count} expense(s). This cannot be undone.'**
  String expenseCategoryDeleteConfirmMessage(int count);

  /// No description provided for @expenseCategoryDeleteConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get expenseCategoryDeleteConfirmAction;

  /// No description provided for @expenseFilterAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get expenseFilterAllCategories;

  /// No description provided for @expenseFilterNoCategoryEntries.
  ///
  /// In en, this message translates to:
  /// **'No expenses for this category in the selected period'**
  String get expenseFilterNoCategoryEntries;

  /// No description provided for @budgetMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly budgets'**
  String get budgetMonthlyTitle;

  /// No description provided for @budgetSetAction.
  ///
  /// In en, this message translates to:
  /// **'Set budget'**
  String get budgetSetAction;

  /// No description provided for @budgetSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set monthly budget'**
  String get budgetSetTitle;

  /// No description provided for @budgetEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit monthly budget'**
  String get budgetEditTitle;

  /// No description provided for @budgetSetHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a category and set how much you plan to spend this month.'**
  String get budgetSetHint;

  /// No description provided for @budgetCustomCategory.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get budgetCustomCategory;

  /// No description provided for @budgetMonthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly limit'**
  String get budgetMonthlyLimit;

  /// No description provided for @budgetSave.
  ///
  /// In en, this message translates to:
  /// **'Save budget'**
  String get budgetSave;

  /// No description provided for @budgetEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Set a limit per category to see how much of your budget you\'ve used.'**
  String get budgetEmptyHint;

  /// No description provided for @budgetSetFirst.
  ///
  /// In en, this message translates to:
  /// **'Create first budget'**
  String get budgetSetFirst;

  /// No description provided for @budgetTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get budgetTotalSpent;

  /// No description provided for @budgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String budgetRemaining(String amount);

  /// No description provided for @budgetOverBy.
  ///
  /// In en, this message translates to:
  /// **'Over by {amount}'**
  String budgetOverBy(String amount);

  /// No description provided for @budgetDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove budget?'**
  String get budgetDeleteTitle;

  /// No description provided for @budgetDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove the budget for {category}?'**
  String budgetDeleteMessage(String category);

  /// No description provided for @budgetDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get budgetDeleteConfirm;

  /// No description provided for @budgetAlertNear.
  ///
  /// In en, this message translates to:
  /// **'{count} category near the limit'**
  String budgetAlertNear(int count);

  /// No description provided for @budgetAlertOver.
  ///
  /// In en, this message translates to:
  /// **'{count} category over budget'**
  String budgetAlertOver(int count);

  /// No description provided for @budgetAlertOverAndNear.
  ///
  /// In en, this message translates to:
  /// **'{over} over budget, {near} near limit'**
  String budgetAlertOverAndNear(int over, int near);

  /// No description provided for @categoryField.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryField;

  /// No description provided for @otherCategoryField.
  ///
  /// In en, this message translates to:
  /// **'Other category'**
  String get otherCategoryField;

  /// No description provided for @otherCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get otherCategoryHint;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get saveExpense;

  /// No description provided for @updateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update Expense'**
  String get updateExpense;

  /// No description provided for @expenseAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully'**
  String get expenseAddedSuccess;

  /// No description provided for @expenseUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Expense updated successfully'**
  String get expenseUpdatedSuccess;

  /// No description provided for @saveIncome.
  ///
  /// In en, this message translates to:
  /// **'Save Income'**
  String get saveIncome;

  /// No description provided for @updateIncome.
  ///
  /// In en, this message translates to:
  /// **'Update Income'**
  String get updateIncome;

  /// No description provided for @incomeAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Income added successfully'**
  String get incomeAddedSuccess;

  /// No description provided for @incomeUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Income updated successfully'**
  String get incomeUpdatedSuccess;

  /// No description provided for @errorEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get errorEnterTitle;

  /// No description provided for @errorEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get errorEnterValidAmount;

  /// No description provided for @errorEnterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get errorEnterCategoryName;

  /// No description provided for @errorSavedExceedsTarget.
  ///
  /// In en, this message translates to:
  /// **'Saved amount cannot exceed target'**
  String get errorSavedExceedsTarget;

  /// No description provided for @expenseCatFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get expenseCatFood;

  /// No description provided for @expenseCatRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get expenseCatRent;

  /// No description provided for @expenseCatTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get expenseCatTransport;

  /// No description provided for @expenseCatShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get expenseCatShopping;

  /// No description provided for @expenseCatBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get expenseCatBills;

  /// No description provided for @expenseCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get expenseCatOther;

  /// No description provided for @incomeCatWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get incomeCatWork;

  /// No description provided for @incomeCatFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get incomeCatFreelance;

  /// No description provided for @incomeCatBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get incomeCatBusiness;

  /// No description provided for @incomeCatInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get incomeCatInvestment;

  /// No description provided for @incomeCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get incomeCatOther;

  /// No description provided for @planCatSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get planCatSavings;

  /// No description provided for @planCatTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get planCatTravel;

  /// No description provided for @planCatPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get planCatPurchase;

  /// No description provided for @planCatEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get planCatEducation;

  /// No description provided for @planCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get planCatOther;

  /// No description provided for @planNewFab.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get planNewFab;

  /// No description provided for @planEditGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get planEditGoal;

  /// No description provided for @planAddPlan.
  ///
  /// In en, this message translates to:
  /// **'Add Plan'**
  String get planAddPlan;

  /// No description provided for @goalTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal title'**
  String get goalTitleLabel;

  /// No description provided for @goalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Emergency Fund'**
  String get goalTitleHint;

  /// No description provided for @targetAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get targetAmountLabel;

  /// No description provided for @amountSavedLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount saved'**
  String get amountSavedLabel;

  /// No description provided for @setDeadlineOptional.
  ///
  /// In en, this message translates to:
  /// **'Set deadline (optional)'**
  String get setDeadlineOptional;

  /// No description provided for @savePlan.
  ///
  /// In en, this message translates to:
  /// **'Save Plan'**
  String get savePlan;

  /// No description provided for @updateGoal.
  ///
  /// In en, this message translates to:
  /// **'Update Goal'**
  String get updateGoal;

  /// No description provided for @errorEnterGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a goal title'**
  String get errorEnterGoalTitle;

  /// No description provided for @errorEnterTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid target amount'**
  String get errorEnterTargetAmount;

  /// No description provided for @errorEnterAmountSaved.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount saved'**
  String get errorEnterAmountSaved;

  /// No description provided for @updateSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Update saved'**
  String get updateSavedTitle;

  /// No description provided for @targetWithAmount.
  ///
  /// In en, this message translates to:
  /// **'Target: {amount}'**
  String targetWithAmount(Object amount);

  /// No description provided for @saveAmountButton.
  ///
  /// In en, this message translates to:
  /// **'Save amount'**
  String get saveAmountButton;

  /// No description provided for @errorEnterValidSavedAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid saved amount'**
  String get errorEnterValidSavedAmount;

  /// No description provided for @balanceNetBalance.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get balanceNetBalance;

  /// No description provided for @balanceSavedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'{percent}% saved this month'**
  String balanceSavedThisMonth(int percent);

  /// No description provided for @balanceSavedPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% saved'**
  String balanceSavedPercent(int percent);

  /// No description provided for @balanceStatIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get balanceStatIncome;

  /// No description provided for @balanceStatExpense.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get balanceStatExpense;

  /// No description provided for @balanceRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get balanceRecentActivity;

  /// No description provided for @balanceAddToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to goal'**
  String get balanceAddToPlan;

  /// No description provided for @balanceAddToPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to savings goal'**
  String get balanceAddToPlanTitle;

  /// No description provided for @balanceAddToPlanHint.
  ///
  /// In en, this message translates to:
  /// **'Available from balance: {amount}'**
  String balanceAddToPlanHint(Object amount);

  /// No description provided for @balanceSelectPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose a goal'**
  String get balanceSelectPlan;

  /// No description provided for @balanceAmountToAllocate.
  ///
  /// In en, this message translates to:
  /// **'Amount to add'**
  String get balanceAmountToAllocate;

  /// No description provided for @balancePlanRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} left to reach target'**
  String balancePlanRemaining(Object amount);

  /// No description provided for @balanceAddToPlanSuccess.
  ///
  /// In en, this message translates to:
  /// **'Amount added to your savings goal'**
  String get balanceAddToPlanSuccess;

  /// No description provided for @balancePlanAllocationPaidFromHint.
  ///
  /// In en, this message translates to:
  /// **'Choose which source this allocation is paid from (shown on Balance, not unassigned).'**
  String get balancePlanAllocationPaidFromHint;

  /// No description provided for @planAllocationSelectPaidFrom.
  ///
  /// In en, this message translates to:
  /// **'Select paid from for this goal allocation'**
  String get planAllocationSelectPaidFrom;

  /// No description provided for @balancePlanAllocationExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings goal: {planTitle}'**
  String balancePlanAllocationExpenseTitle(String planTitle);

  /// No description provided for @balanceNoPlansForAllocation.
  ///
  /// In en, this message translates to:
  /// **'Create a savings goal in the Plans tab first.'**
  String get balanceNoPlansForAllocation;

  /// No description provided for @balanceAmountExceedsSurplus.
  ///
  /// In en, this message translates to:
  /// **'Amount exceeds your available balance'**
  String get balanceAmountExceedsSurplus;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @listEntryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String listEntryCount(int count);

  /// No description provided for @clearAllExpenses.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAllExpenses;

  /// No description provided for @clearAllIncomes.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAllIncomes;

  /// No description provided for @clearAllExpensesConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all expenses?'**
  String get clearAllExpensesConfirmTitle;

  /// No description provided for @clearAllIncomesConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all incomes?'**
  String get clearAllIncomesConfirmTitle;

  /// No description provided for @clearAllExpensesConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all {count} expenses. This cannot be undone.'**
  String clearAllExpensesConfirmMessage(int count);

  /// No description provided for @clearAllIncomesConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all {count} incomes. This cannot be undone.'**
  String clearAllIncomesConfirmMessage(int count);

  /// No description provided for @clearAllExpensesSuccess.
  ///
  /// In en, this message translates to:
  /// **'All expenses deleted'**
  String get clearAllExpensesSuccess;

  /// No description provided for @clearAllIncomesSuccess.
  ///
  /// In en, this message translates to:
  /// **'All incomes deleted'**
  String get clearAllIncomesSuccess;

  /// No description provided for @balanceIncomeVsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expenses'**
  String get balanceIncomeVsExpenses;

  /// No description provided for @balanceFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get balanceFilterAll;

  /// No description provided for @balanceFilterIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get balanceFilterIncome;

  /// No description provided for @balanceFilterExpense.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get balanceFilterExpense;

  /// No description provided for @balanceNoFilteredActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity matches this filter'**
  String get balanceNoFilteredActivity;

  /// No description provided for @activityIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get activityIncome;

  /// No description provided for @activityExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get activityExpense;

  /// No description provided for @plansActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get plansActive;

  /// No description provided for @plansDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get plansDone;

  /// No description provided for @plansRemaining.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get plansRemaining;

  /// No description provided for @plansSavingsGoalsSection.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get plansSavingsGoalsSection;

  /// No description provided for @plansGoalsOverview.
  ///
  /// In en, this message translates to:
  /// **'Goals overview'**
  String get plansGoalsOverview;

  /// No description provided for @plansSavedOfTarget.
  ///
  /// In en, this message translates to:
  /// **'of {total} saved'**
  String plansSavedOfTarget(Object total);

  /// No description provided for @plansDonePercentLabel.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get plansDonePercentLabel;

  /// No description provided for @plansGoalsCompletedSummary.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} goals completed'**
  String plansGoalsCompletedSummary(int completed, int total);

  /// No description provided for @plansMoneyLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String plansMoneyLeft(Object amount);

  /// No description provided for @ofTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String ofTargetAmount(Object amount);

  /// No description provided for @dueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueDateLabel(Object date);

  /// No description provided for @planGoalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Goal completed'**
  String get planGoalCompleted;

  /// No description provided for @planTapToEditGoal.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit goal'**
  String get planTapToEditGoal;

  /// No description provided for @plansEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your first goal'**
  String get plansEmptyTitle;

  /// No description provided for @plansEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a target, track what you save, and watch your progress grow.'**
  String get plansEmptySubtitle;

  /// No description provided for @plansCreateGoalButton.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get plansCreateGoalButton;

  /// No description provided for @demoSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get demoSalary;

  /// No description provided for @demoRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get demoRent;

  /// No description provided for @demoFreelanceProject.
  ///
  /// In en, this message translates to:
  /// **'Freelance Project'**
  String get demoFreelanceProject;

  /// No description provided for @demoGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get demoGroceries;

  /// No description provided for @demoGas.
  ///
  /// In en, this message translates to:
  /// **'Gas'**
  String get demoGas;

  /// No description provided for @demoElectricBill.
  ///
  /// In en, this message translates to:
  /// **'Electric Bill'**
  String get demoElectricBill;

  /// No description provided for @demoUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get demoUtilities;

  /// No description provided for @demoSideBusiness.
  ///
  /// In en, this message translates to:
  /// **'Side Business'**
  String get demoSideBusiness;

  /// No description provided for @demoEmergencyFund.
  ///
  /// In en, this message translates to:
  /// **'Emergency Fund'**
  String get demoEmergencyFund;

  /// No description provided for @demoSummerVacation.
  ///
  /// In en, this message translates to:
  /// **'Summer Vacation'**
  String get demoSummerVacation;

  /// No description provided for @demoNewLaptop.
  ///
  /// In en, this message translates to:
  /// **'New Laptop'**
  String get demoNewLaptop;

  /// No description provided for @storedAsBase.
  ///
  /// In en, this message translates to:
  /// **'Stored as {amount} base'**
  String storedAsBase(Object amount);

  /// No description provided for @smartImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart import'**
  String get smartImportTitle;

  /// No description provided for @smartImportShort.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get smartImportShort;

  /// No description provided for @smartImportPasteTab.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get smartImportPasteTab;

  /// No description provided for @smartImportQuickTab.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get smartImportQuickTab;

  /// No description provided for @smartImportSmsTab.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get smartImportSmsTab;

  /// No description provided for @smartImportQuickHint.
  ///
  /// In en, this message translates to:
  /// **'No SMS to paste? Enter the amount, pick expense or income, choose category and source — add in one tap.'**
  String get smartImportQuickHint;

  /// No description provided for @smartImportQuickTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction type'**
  String get smartImportQuickTypeLabel;

  /// No description provided for @smartImportQuickAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get smartImportQuickAmountLabel;

  /// No description provided for @smartImportQuickTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Coffee, rent, salary… (optional)'**
  String get smartImportQuickTitleHint;

  /// No description provided for @smartImportQuickAddNow.
  ///
  /// In en, this message translates to:
  /// **'Add now'**
  String get smartImportQuickAddNow;

  /// No description provided for @smartImportQuickReview.
  ///
  /// In en, this message translates to:
  /// **'Review in full form'**
  String get smartImportQuickReview;

  /// No description provided for @smartImportQuickAdded.
  ///
  /// In en, this message translates to:
  /// **'Transaction added.'**
  String get smartImportQuickAdded;

  /// No description provided for @smartImportPasteHint.
  ///
  /// In en, this message translates to:
  /// **'Paste one or more bank or wallet messages. Put a blank line between messages, or paste several SMS in a row. We detect amounts and income vs expense for each.'**
  String get smartImportPasteHint;

  /// No description provided for @smartImportPasteShareTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: In your SMS app, open a message → Share → Import to Pocketly. No copy-paste needed.'**
  String get smartImportPasteShareTip;

  /// No description provided for @smartImportSharedTextReady.
  ///
  /// In en, this message translates to:
  /// **'Shared message loaded. Review below and add.'**
  String get smartImportSharedTextReady;

  /// No description provided for @smartImportPasteFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Message text'**
  String get smartImportPasteFieldLabel;

  /// No description provided for @smartImportPasteFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Paste one or more messages (blank line between each)'**
  String get smartImportPasteFieldHint;

  /// No description provided for @smartImportPasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get smartImportPasteFromClipboard;

  /// No description provided for @smartImportParseMessage.
  ///
  /// In en, this message translates to:
  /// **'Parse message'**
  String get smartImportParseMessage;

  /// No description provided for @smartImportParseMessages.
  ///
  /// In en, this message translates to:
  /// **'Parse messages'**
  String get smartImportParseMessages;

  /// No description provided for @smartImportPasteFoundCount.
  ///
  /// In en, this message translates to:
  /// **'Found {count} messages'**
  String smartImportPasteFoundCount(int count);

  /// No description provided for @smartImportPasteAddedOneRemaining.
  ///
  /// In en, this message translates to:
  /// **'Added. {count} more ready to import.'**
  String smartImportPasteAddedOneRemaining(int count);

  /// No description provided for @smartImportPasteProcessing.
  ///
  /// In en, this message translates to:
  /// **'Reading message…'**
  String get smartImportPasteProcessing;

  /// No description provided for @smartImportPasteNoData.
  ///
  /// In en, this message translates to:
  /// **'Could not find an amount in this text. Try the full bank message.'**
  String get smartImportPasteNoData;

  /// No description provided for @smartImportPasteEmpty.
  ///
  /// In en, this message translates to:
  /// **'Paste a message first.'**
  String get smartImportPasteEmpty;

  /// No description provided for @smartImportPasteClipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty. Copy a bank or wallet message first.'**
  String get smartImportPasteClipboardEmpty;

  /// No description provided for @smartImportPasteClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get smartImportPasteClear;

  /// No description provided for @smartImportPasteAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added. Paste another message anytime.'**
  String get smartImportPasteAddedSuccess;

  /// No description provided for @smartImportPasteParseAnother.
  ///
  /// In en, this message translates to:
  /// **'Parse another'**
  String get smartImportPasteParseAnother;

  /// No description provided for @smartImportPasteMarkExpense.
  ///
  /// In en, this message translates to:
  /// **'Mark as expense'**
  String get smartImportPasteMarkExpense;

  /// No description provided for @smartImportPasteMarkIncome.
  ///
  /// In en, this message translates to:
  /// **'Mark as income'**
  String get smartImportPasteMarkIncome;

  /// No description provided for @smartImportDefaultBillTitle.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get smartImportDefaultBillTitle;

  /// No description provided for @smartImportExtractedData.
  ///
  /// In en, this message translates to:
  /// **'Extracted data'**
  String get smartImportExtractedData;

  /// No description provided for @smartImportDateField.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get smartImportDateField;

  /// No description provided for @smartImportTypeField.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get smartImportTypeField;

  /// No description provided for @smartImportAddToApp.
  ///
  /// In en, this message translates to:
  /// **'Add to app'**
  String get smartImportAddToApp;

  /// No description provided for @smartImportSmsNotSupported.
  ///
  /// In en, this message translates to:
  /// **'SMS import is available on Android only.'**
  String get smartImportSmsNotSupported;

  /// No description provided for @smartImportSmsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No financial SMS messages found. Grant SMS permission if prompted.'**
  String get smartImportSmsEmpty;

  /// No description provided for @smartImportSmsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read SMS messages.'**
  String get smartImportSmsFailed;

  /// No description provided for @smartImportReloadSms.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get smartImportReloadSms;

  /// No description provided for @smartImportSmsAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'Already added'**
  String get smartImportSmsAlreadyAdded;

  /// No description provided for @smartImportSmsAddAgain.
  ///
  /// In en, this message translates to:
  /// **'Add again'**
  String get smartImportSmsAddAgain;

  /// No description provided for @smartImportSmsClearAllAdded.
  ///
  /// In en, this message translates to:
  /// **'Clear all added'**
  String get smartImportSmsClearAllAdded;

  /// No description provided for @smartImportSmsClearAllAddedConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear imported history?'**
  String get smartImportSmsClearAllAddedConfirmTitle;

  /// No description provided for @smartImportSmsClearAllAddedConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'All SMS will show as not added. You can import them again. Your existing expenses and incomes are not deleted.'**
  String get smartImportSmsClearAllAddedConfirmMessage;

  /// No description provided for @smartImportSmsClearAllAddedDone.
  ///
  /// In en, this message translates to:
  /// **'Imported history cleared'**
  String get smartImportSmsClearAllAddedDone;

  /// No description provided for @smartImportSmsSkippedDuplicate.
  ///
  /// In en, this message translates to:
  /// **'{count} message(s) were already in the app.'**
  String smartImportSmsSkippedDuplicate(int count);

  /// No description provided for @smartImportSmsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more messages'**
  String get smartImportSmsLoadMore;

  /// No description provided for @smartImportSmsLoading.
  ///
  /// In en, this message translates to:
  /// **'Reading your SMS messages…'**
  String get smartImportSmsLoading;

  /// No description provided for @smartImportSmsLoadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more…'**
  String get smartImportSmsLoadingMore;

  /// No description provided for @smartImportUnknownSender.
  ///
  /// In en, this message translates to:
  /// **'Unknown sender'**
  String get smartImportUnknownSender;

  /// No description provided for @smartImportSmsTitleExpense.
  ///
  /// In en, this message translates to:
  /// **'Bank expense'**
  String get smartImportSmsTitleExpense;

  /// No description provided for @smartImportSmsTitleIncome.
  ///
  /// In en, this message translates to:
  /// **'Bank income'**
  String get smartImportSmsTitleIncome;

  /// No description provided for @smartImportTapToImport.
  ///
  /// In en, this message translates to:
  /// **'Tap to import'**
  String get smartImportTapToImport;

  /// No description provided for @smartImportAddAllExpenses.
  ///
  /// In en, this message translates to:
  /// **'Add all expenses ({count})'**
  String smartImportAddAllExpenses(int count);

  /// No description provided for @smartImportAddAllIncomes.
  ///
  /// In en, this message translates to:
  /// **'Add all incomes ({count})'**
  String smartImportAddAllIncomes(int count);

  /// No description provided for @smartImportAddSelected.
  ///
  /// In en, this message translates to:
  /// **'Add selected ({count})'**
  String smartImportAddSelected(int count);

  /// No description provided for @smartImportSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get smartImportSelectAll;

  /// No description provided for @smartImportClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get smartImportClearSelection;

  /// No description provided for @smartImportBulkCategorySheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Category for import'**
  String get smartImportBulkCategorySheetTitle;

  /// No description provided for @smartImportBulkCategorySheetHint.
  ///
  /// In en, this message translates to:
  /// **'Choose category and source here. SMS text is only used for titles, not for income source or paid-from.'**
  String get smartImportBulkCategorySheetHint;

  /// No description provided for @smartImportBulkExpensePaidFromHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a source for imported expenses (not read from SMS).'**
  String get smartImportBulkExpensePaidFromHint;

  /// No description provided for @smartImportBulkIncomeSourceHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a source for imported incomes (not read from SMS).'**
  String get smartImportBulkIncomeSourceHint;

  /// No description provided for @smartImportBulkSelectPaidFrom.
  ///
  /// In en, this message translates to:
  /// **'Select paid from'**
  String get smartImportBulkSelectPaidFrom;

  /// No description provided for @smartImportBulkSelectIncomeSource.
  ///
  /// In en, this message translates to:
  /// **'Select income source'**
  String get smartImportBulkSelectIncomeSource;

  /// No description provided for @smartImportBulkExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense category'**
  String get smartImportBulkExpenseCategory;

  /// No description provided for @smartImportBulkIncomeSource.
  ///
  /// In en, this message translates to:
  /// **'Income source'**
  String get smartImportBulkIncomeSource;

  /// No description provided for @smartImportBulkApplyAndImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get smartImportBulkApplyAndImport;

  /// No description provided for @smartImportBulkImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing messages…'**
  String get smartImportBulkImporting;

  /// No description provided for @smartImportBulkNothingToAdd.
  ///
  /// In en, this message translates to:
  /// **'No messages with a valid amount to import.'**
  String get smartImportBulkNothingToAdd;

  /// No description provided for @smartImportBulkResult.
  ///
  /// In en, this message translates to:
  /// **'Added {incomes} incomes and {expenses} expenses.'**
  String smartImportBulkResult(int incomes, int expenses);

  /// No description provided for @smartImportBulkPartialFail.
  ///
  /// In en, this message translates to:
  /// **'{failed} message(s) could not be imported.'**
  String smartImportBulkPartialFail(int failed);

  /// No description provided for @settingsAutoSmsImport.
  ///
  /// In en, this message translates to:
  /// **'Auto-import from SMS'**
  String get settingsAutoSmsImport;

  /// No description provided for @settingsAutoSmsImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When the app opens, new bank SMS are detected and added as income or expense using your chosen category and source.'**
  String get settingsAutoSmsImportSubtitle;

  /// No description provided for @settingsAutoSmsImportDefaults.
  ///
  /// In en, this message translates to:
  /// **'Auto-import categories'**
  String get settingsAutoSmsImportDefaults;

  /// No description provided for @settingsAutoSmsImportDefaultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Defaults for auto-import'**
  String get settingsAutoSmsImportDefaultsTitle;

  /// No description provided for @settingsAutoSmsImportDefaultsHint.
  ///
  /// In en, this message translates to:
  /// **'Used for every automatic import. SMS text is only used for titles.'**
  String get settingsAutoSmsImportDefaultsHint;

  /// No description provided for @settingsAutoSmsImportPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'SMS permission is required for auto-import.'**
  String get settingsAutoSmsImportPermissionDenied;

  /// No description provided for @settingsAutoSmsImportEnabled.
  ///
  /// In en, this message translates to:
  /// **'Auto-import is on. New financial SMS will be added when you open the app.'**
  String get settingsAutoSmsImportEnabled;

  /// No description provided for @autoSmsImportAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'Auto-imported {incomes} incomes and {expenses} expenses.'**
  String autoSmsImportAddedSnack(int incomes, int expenses);

  /// No description provided for @settingsAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get settingsAppLock;

  /// No description provided for @settingsAppLockBiometric.
  ///
  /// In en, this message translates to:
  /// **'Face ID / fingerprint'**
  String get settingsAppLockBiometric;

  /// No description provided for @settingsAppLockChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get settingsAppLockChangePin;

  /// No description provided for @appLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Pocketly'**
  String get appLockTitle;

  /// No description provided for @appLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to continue'**
  String get appLockSubtitle;

  /// No description provided for @appLockWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Try again.'**
  String get appLockWrongPin;

  /// No description provided for @appLockBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock your finances'**
  String get appLockBiometricReason;

  /// No description provided for @appLockEnterPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get appLockEnterPinTitle;

  /// No description provided for @appLockEnterPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm to continue'**
  String get appLockEnterPinSubtitle;

  /// No description provided for @appLockCreatePinTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a PIN'**
  String get appLockCreatePinTitle;

  /// No description provided for @appLockCreatePinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use 4 digits you will remember'**
  String get appLockCreatePinSubtitle;

  /// No description provided for @appLockConfirmPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get appLockConfirmPinTitle;

  /// No description provided for @appLockConfirmPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the same PIN again'**
  String get appLockConfirmPinSubtitle;

  /// No description provided for @appLockPinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get appLockPinMismatch;

  /// No description provided for @appLockEnabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'App lock is on'**
  String get appLockEnabledSuccess;

  /// No description provided for @appLockDisabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'App lock is off'**
  String get appLockDisabledSuccess;

  /// No description provided for @appLockEnableFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not enable app lock'**
  String get appLockEnableFailed;

  /// No description provided for @appLockBiometricPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics?'**
  String get appLockBiometricPromptTitle;

  /// No description provided for @appLockBiometricPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'Unlock faster with Face ID or fingerprint on this device.'**
  String get appLockBiometricPromptMessage;

  /// No description provided for @appLockBiometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometrics could not be enabled'**
  String get appLockBiometricFailed;

  /// No description provided for @appLockChangePinSuccess.
  ///
  /// In en, this message translates to:
  /// **'PIN updated'**
  String get appLockChangePinSuccess;

  /// No description provided for @appLockChangePinFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update PIN'**
  String get appLockChangePinFailed;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @monthlyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly report'**
  String get monthlyReportTitle;

  /// No description provided for @monthlyReportShort.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get monthlyReportShort;

  /// No description provided for @monthlyReportVsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Compared to last month'**
  String get monthlyReportVsLastMonth;

  /// No description provided for @monthlyReportBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget vs actual'**
  String get monthlyReportBudgetTitle;

  /// No description provided for @monthlyReportNoBudgets.
  ///
  /// In en, this message translates to:
  /// **'No budgets set for this month. Add limits on the Expenses tab to track spending here.'**
  String get monthlyReportNoBudgets;

  /// No description provided for @monthlyReportEntrySummary.
  ///
  /// In en, this message translates to:
  /// **'{incomeCount} income sources · {expenseCount} expense categories'**
  String monthlyReportEntrySummary(int incomeCount, int expenseCount);

  /// No description provided for @globalSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get globalSearchTitle;

  /// No description provided for @globalSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Title, category, source, amount…'**
  String get globalSearchHint;

  /// No description provided for @globalSearchAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get globalSearchAll;

  /// No description provided for @globalSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching entries'**
  String get globalSearchNoResults;

  /// No description provided for @globalSearchAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get globalSearchAllTime;

  /// No description provided for @globalSearchCurrentPeriod.
  ///
  /// In en, this message translates to:
  /// **'This period'**
  String get globalSearchCurrentPeriod;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
