import 'package:get_it/get_it.dart';
import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/home_date_filter.dart';
import 'package:imrpo/core/services/locale_preferences.dart';
import 'package:imrpo/features/auth/data/datasources/auth_datasource.dart';
import 'package:imrpo/features/auth/data/datasources/auth_datasource_impl.dart';
import 'package:imrpo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:imrpo/features/auth/domain/repositories/auth_repository.dart';
import 'package:imrpo/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:imrpo/features/auth/domain/usecases/forget_password_usecase.dart';
import 'package:imrpo/features/auth/domain/usecases/login_usecase.dart';
import 'package:imrpo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:imrpo/features/auth/domain/usecases/signup_usecase.dart';
import 'package:imrpo/features/auth/domain/usecases/verify_set_new_pass_usecase.dart';
import 'package:imrpo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:imrpo/features/balance_tab/data/repositories/balance_repository_impl.dart';
import 'package:imrpo/features/balance_tab/domain/repositories/balance_repository.dart';
import 'package:imrpo/features/balance_tab/domain/usecases/get_balance_usecase.dart';
import 'package:imrpo/features/balance_tab/presentation/bloc/balance_tab_bloc.dart';
import 'package:imrpo/features/expenses_tab/data/datasources/expenses_datasource.dart';
import 'package:imrpo/features/expenses_tab/data/datasources/expenses_datasource_impl.dart';
import 'package:imrpo/features/expenses_tab/data/repositories/expense_repositroy_impl.dart';
import 'package:imrpo/features/expenses_tab/domain/repositories/expense_repository.dart';
import 'package:imrpo/features/expenses_tab/domain/usecases/add_expense_usecase.dart';
import 'package:imrpo/features/expenses_tab/domain/usecases/delete_expense_usecase.dart';
import 'package:imrpo/features/expenses_tab/domain/usecases/get_all_expenses_usecase.dart';
import 'package:imrpo/features/expenses_tab/domain/usecases/update_expense_usecase.dart';
import 'package:imrpo/features/expenses_tab/presentation/bloc/expenses_tab_bloc.dart';
import 'package:imrpo/features/incomes_tab/data/datasources/income_datasource.dart';
import 'package:imrpo/features/incomes_tab/data/datasources/income_datasource_impl.dart';
import 'package:imrpo/features/incomes_tab/data/repositories/income_repository_impl.dart';
import 'package:imrpo/features/incomes_tab/domain/repositories/income_repository.dart';
import 'package:imrpo/features/incomes_tab/domain/usecases/add_income_usecase.dart';
import 'package:imrpo/features/incomes_tab/domain/usecases/delete_income_usecase.dart';
import 'package:imrpo/features/incomes_tab/domain/usecases/get_all_incomes_usecase.dart';
import 'package:imrpo/features/incomes_tab/domain/usecases/update_income_usecase.dart';
import 'package:imrpo/features/incomes_tab/presentation/bloc/incomes_tab_bloc.dart';
import 'package:imrpo/features/plans_tab/data/datasources/plans_datasource.dart';
import 'package:imrpo/features/plans_tab/data/datasources/plans_datasource_impl.dart';
import 'package:imrpo/features/plans_tab/data/repositories/plan_repository_impl.dart';
import 'package:imrpo/features/plans_tab/domain/repositories/plan_repository.dart';
import 'package:imrpo/features/plans_tab/domain/usecases/add_plan_usecase.dart';
import 'package:imrpo/features/plans_tab/domain/usecases/delete_plan_usecase.dart';
import 'package:imrpo/features/plans_tab/domain/usecases/get_all_plans_usecase.dart';
import 'package:imrpo/features/plans_tab/domain/usecases/update_plan_saved_usecase.dart';
import 'package:imrpo/features/plans_tab/domain/usecases/update_plan_usecase.dart';
import 'package:imrpo/features/home/data/datasources/home_datasource.dart';
import 'package:imrpo/features/home/data/datasources/home_datasource_impl.dart';
import 'package:imrpo/features/home/data/repositories/home_repository_impl.dart';
import 'package:imrpo/features/home/domain/repositories/home_repository.dart';
import 'package:imrpo/features/home/domain/usecases/get_user_profile_usecase.dart';
import 'package:imrpo/features/home/domain/usecases/update_username_usecase.dart';
import 'package:imrpo/features/home/presentation/bloc/home_bloc.dart';
import 'package:imrpo/features/plans_tab/presentation/bloc/plans_tab_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  /// Supabase Client
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  getIt.registerLazySingleton<CurrencyPreferences>(() => CurrencyPreferences());

  getIt.registerLazySingleton<LocalePreferences>(() => LocalePreferences());

  getIt.registerLazySingleton<HomeDateFilter>(() => HomeDateFilter());

  /// Datasource
  getIt.registerLazySingleton<AuthDatasource>(
    () => AuthDatasourceImpl(supabaseClient: getIt<SupabaseClient>()),
  );

  /// Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authDatasource: getIt<AuthDatasource>()),
  );

  /// Usecases
  getIt.registerLazySingleton<LoginUsecase>(
    () => LoginUsecase(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SignupUsecase>(
    () => SignupUsecase(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<ForgetPasswordUsecase>(
    () => ForgetPasswordUsecase(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<VerifySetNewPassUsecase>(
    () => VerifySetNewPassUsecase(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton(
    () => LogoutUsecase(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton(
    () => DeleteAccountUsecase(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUsecase: getIt<LoginUsecase>(),
      signupUsecase: getIt<SignupUsecase>(),
      forgetPasswordUsecase: getIt<ForgetPasswordUsecase>(),
      verifySetNewPassUsecase: getIt<VerifySetNewPassUsecase>(),
      logoutUsecase: getIt<LogoutUsecase>(),
      deleteAccountUsecase: getIt<DeleteAccountUsecase>(),
    ),
  );

  //---------------------INCOMES-------------------------------------

  getIt.registerLazySingleton<IncomeDatasource>(
    () => IncomeDatasourceImpl(supabaseClient: getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<IncomeRepository>(
    () => IncomeRepositoryImpl(incomeDatasource: getIt<IncomeDatasource>()),
  );

  getIt.registerLazySingleton(
    () => AddIncomeUsecase(incomeRepository: getIt<IncomeRepository>()),
  );

  getIt.registerLazySingleton(
    () => DeleteIncomeUsecase(incomeRepository: getIt<IncomeRepository>()),
  );

  getIt.registerLazySingleton(
    () => UpdateIncomeUsecase(incomeRepository: getIt<IncomeRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetAllIncomesUsecase(incomeRepository: getIt<IncomeRepository>()),
  );

  getIt.registerFactory<IncomesTabBloc>(
    () => IncomesTabBloc(
      addIncomeUsecase: getIt<AddIncomeUsecase>(),
      updateIncomeUsecase: getIt<UpdateIncomeUsecase>(),
      deleteIncomeUsecase: getIt<DeleteIncomeUsecase>(),
      getAllIncomesUsecase: getIt<GetAllIncomesUsecase>(),
    ),
  );

  /// ------------------------------expenses-------------------------
  getIt.registerLazySingleton<ExpensesDatasource>(
    () => ExpensesDatasourceImpl(supabaseClient: getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<ExpenseRepository>(
    () =>
        ExpenseRepositroyImpl(expensesDatasource: getIt<ExpensesDatasource>()),
  );

  getIt.registerLazySingleton(
    () => AddExpenseUsecase(expenseRepository: getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteExpenseUsecase(expenseRepository: getIt<ExpenseRepository>()),
  );

  getIt.registerLazySingleton(
    () => UpdateExpenseUsecase(expenseRepository: getIt<ExpenseRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetAllExpensesUsecase(expenseRepository: getIt<ExpenseRepository>()),
  );

  getIt.registerFactory<ExpensesTabBloc>(
    () => ExpensesTabBloc(
      addExpenseUsecase: getIt<AddExpenseUsecase>(),
      updateExpenseUsecase: getIt<UpdateExpenseUsecase>(),
      deleteExpenseUsecase: getIt<DeleteExpenseUsecase>(),
      getAllExpensesUsecase: getIt<GetAllExpensesUsecase>(),
    ),
  );

  //--------------------------BALANCE--------------------------

  getIt.registerLazySingleton<BalanceRepository>(
    () => BalanceRepositoryImpl(
      incomeRepository: getIt<IncomeRepository>(),
      expenseRepository: getIt<ExpenseRepository>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetBalanceUsecase(balanceRepository: getIt<BalanceRepository>()),
  );

  getIt.registerFactory<BalanceTabBloc>(
    () => BalanceTabBloc(getBalanceUsecase: getIt<GetBalanceUsecase>()),
  );
  //--------------------------PLANS--------------------------

  getIt.registerLazySingleton<PlansDatasource>(
    () => PlansDatasourceImpl(supabaseClient: getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<PlanRepository>(
    () => PlanRepositoryImpl(plansDatasource: getIt<PlansDatasource>()),
  );

  getIt.registerLazySingleton(
    () => AddPlanUsecase(planRepository: getIt<PlanRepository>()),
  );

  getIt.registerLazySingleton(
    () => UpdatePlanUsecase(planRepository: getIt<PlanRepository>()),
  );

  getIt.registerLazySingleton(
    () => UpdatePlanSavedUsecase(planRepository: getIt<PlanRepository>()),
  );

  getIt.registerLazySingleton(
    () => DeletePlanUsecase(planRepository: getIt<PlanRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetAllPlansUsecase(planRepository: getIt<PlanRepository>()),
  );

  getIt.registerFactory<PlansTabBloc>(
    () => PlansTabBloc(
      getAllPlansUsecase: getIt<GetAllPlansUsecase>(),
      addPlanUsecase: getIt<AddPlanUsecase>(),
      updatePlanUsecase: getIt<UpdatePlanUsecase>(),
      updatePlanSavedUsecase: getIt<UpdatePlanSavedUsecase>(),
      deletePlanUsecase: getIt<DeletePlanUsecase>(),
    ),
  );

  //--------------------------HOME--------------------------

  getIt.registerLazySingleton<HomeDatasource>(
    () => HomeDatasourceImpl(supabaseClient: getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(homeDatasource: getIt<HomeDatasource>()),
  );

  getIt.registerLazySingleton(
    () => GetUserProfileUsecase(homeRepository: getIt<HomeRepository>()),
  );

  getIt.registerLazySingleton(
    () => UpdateUsernameUsecase(homeRepository: getIt<HomeRepository>()),
  );

  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      getUserProfileUsecase: getIt<GetUserProfileUsecase>(),
      updateUsernameUsecase: getIt<UpdateUsernameUsecase>(),
    ),
  );
}
