import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imrpo/core/config/app_router.dart';
import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/locale_preferences.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/services/sms_imported_registry.dart';
import 'package:imrpo/core/theme/app_theme.dart';
import 'package:imrpo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:imrpo/features/auth/presentation/pages/login_screen.dart';
import 'package:imrpo/features/balance_tab/presentation/bloc/balance_tab_bloc.dart';
import 'package:imrpo/features/expenses_tab/presentation/bloc/expenses_tab_bloc.dart';
import 'package:imrpo/features/home/presentation/pages/home_screen.dart';
import 'package:imrpo/features/incomes_tab/presentation/bloc/incomes_tab_bloc.dart';
import 'package:imrpo/features/home/presentation/bloc/home_bloc.dart';
import 'package:imrpo/features/plans_tab/presentation/bloc/plans_tab_bloc.dart';
import 'package:imrpo/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xtilikvogevzshsliwzp.supabase.co',
    anonKey: 'sb_publishable_hhAelFYJErvvdq9_HAkHgw_bwLBSG1K',
  );
  setupServiceLocator();
  await getIt<CurrencyPreferences>().load();
  await getIt<LocalePreferences>().load();
  await getIt<SmsImportedRegistry>().load();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<HomeBloc>()),
        BlocProvider(create: (_) => getIt<IncomesTabBloc>()),
        BlocProvider(create: (_) => getIt<BalanceTabBloc>()),
        BlocProvider(create: (_) => getIt<ExpensesTabBloc>()),
        BlocProvider(create: (_) => getIt<PlansTabBloc>()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: getIt<LocalePreferences>(),
      builder: (context, _) {
        final locale = getIt<LocalePreferences>().locale;

        return MaterialApp(
          locale: locale,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          theme: AppTheme.light,
          debugShowCheckedModeBanner: false,
          initialRoute: getIt<SupabaseClient>().auth.currentUser != null
              ? AppRoutes.home
              : AppRoutes.login,
          onGenerateRoute: AppRouter.generateRoute,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return Directionality(
              textDirection: locale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child!,
            );
          },
          home: getIt<SupabaseClient>().auth.currentUser != null
              ? HomeScreen()
              : LoginScreen(),
        );
      },
    );
  }
}
