import 'package:imrpo/core/l10n/l10n_error_tokens.dart';
import 'package:imrpo/l10n/app_localizations.dart';

String localizeExpenseCategory(AppLocalizations l10n, String stored) {
  switch (stored) {
    case 'Food':
      return l10n.expenseCatFood;
    case 'Rent':
      return l10n.expenseCatRent;
    case 'Transport':
      return l10n.expenseCatTransport;
    case 'Shopping':
      return l10n.expenseCatShopping;
    case 'Bills':
      return l10n.expenseCatBills;
    case 'Other':
      return l10n.expenseCatOther;
    default:
      return stored;
  }
}

String localizeIncomeCategory(AppLocalizations l10n, String stored) {
  switch (stored) {
    case 'Work':
      return l10n.incomeCatWork;
    case 'Freelance':
      return l10n.incomeCatFreelance;
    case 'Business':
      return l10n.incomeCatBusiness;
    case 'Investment':
      return l10n.incomeCatInvestment;
    case 'Other':
      return l10n.incomeCatOther;
    case 'Salary':
      return l10n.demoSalary;
    case 'Rents':
      return l10n.incomeSourceRents;
    case 'Visa Card':
      return l10n.incomeSourceVisaCard;
    case 'Cash':
      return l10n.incomeSourceCash;
    default:
      return stored;
  }
}

String localizePlanCategory(AppLocalizations l10n, String stored) {
  switch (stored) {
    case 'Savings':
      return l10n.planCatSavings;
    case 'Travel':
      return l10n.planCatTravel;
    case 'Purchase':
      return l10n.planCatPurchase;
    case 'Education':
      return l10n.planCatEducation;
    case 'Other':
      return l10n.planCatOther;
    default:
      return stored;
  }
}

String localizeDemoTitle(AppLocalizations l10n, String title) {
  switch (title) {
    case 'Salary':
      return l10n.demoSalary;
    case 'Rent':
      return l10n.demoRent;
    case 'Freelance Project':
      return l10n.demoFreelanceProject;
    case 'Groceries':
      return l10n.demoGroceries;
    case 'Gas':
      return l10n.demoGas;
    case 'Electric Bill':
      return l10n.demoElectricBill;
    case 'Utilities':
      return l10n.demoUtilities;
    case 'Side Business':
      return l10n.demoSideBusiness;
    case 'Emergency Fund':
      return l10n.demoEmergencyFund;
    case 'Summer Vacation':
      return l10n.demoSummerVacation;
    case 'New Laptop':
      return l10n.demoNewLaptop;
    default:
      return title;
  }
}

String localizeApiError(AppLocalizations l10n, String? message) {
  if (message == null || message.isEmpty) {
    return l10n.errorGeneric;
  }
  if (message == l10nNoInternetToken) {
    return l10n.noInternetConnection;
  }
  if (message == l10nDeleteNotFoundToken) {
    return l10n.errorDeleteFailed;
  }
  if (message == l10nDeleteAccountFailedToken) {
    return l10n.errorDeleteAccountFailed;
  }
  if (message == l10nDeleteAccountRpcRequiredToken) {
    return l10n.errorDeleteAccountRpcRequired;
  }
  return message;
}
