import 'package:flutter/material.dart';
import 'package:imrpo/l10n/app_localizations.dart';
import 'package:imrpo/features/auth/presentation/pages/forget_password_screen.dart';
import 'package:imrpo/features/auth/presentation/pages/login_screen.dart';
import 'package:imrpo/features/auth/presentation/pages/set_new_passwod_screen.dart';
import 'package:imrpo/features/auth/presentation/pages/signup_screen.dart';
import 'package:imrpo/features/home/presentation/pages/calculator_screen.dart';
import 'package:imrpo/features/home/presentation/pages/home_screen.dart';
import 'package:imrpo/features/monthly_report/presentation/pages/monthly_report_screen.dart';
import 'package:imrpo/features/search/presentation/pages/global_search_screen.dart';
import 'package:imrpo/features/bill_reminders/presentation/pages/bill_reminders_screen.dart';
import 'package:imrpo/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:imrpo/features/smart_import/presentation/pages/smart_import_screen.dart';
import 'package:imrpo/features/csv_import/presentation/pages/csv_import_screen.dart';
import 'package:imrpo/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:imrpo/features/zakat/presentation/pages/zakat_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/features/bill_reminders/presentation/bloc/bill_reminders_bloc.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static const String home = '/home';
  static const String search = '/search';
  static const String smartImport = '/smart-import';
  static const String csvImport = '/csv-import';
  static const String calculator = '/calculator';
  static const String monthlyReport = '/monthly-report';
  static const String billReminders = '/bill-reminders';
  static const String notifications = '/notifications';
  static const String zakat = '/zakat';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgetPassword = '/forget-password';
  static const String verifyOtp = '/verify-otp';
}

class AppRouter {
  static MaterialPageRoute generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.search:
        return MaterialPageRoute(builder: (_) => const GlobalSearchScreen());
      case AppRoutes.smartImport:
        return MaterialPageRoute(
          settings: const RouteSettings(name: AppRoutes.smartImport),
          builder: (_) => const SmartImportScreen(),
        );
      case AppRoutes.csvImport:
        return MaterialPageRoute(
          settings: const RouteSettings(name: AppRoutes.csvImport),
          builder: (_) => const CsvImportScreen(),
        );
      case AppRoutes.calculator:
        return MaterialPageRoute(builder: (_) => const CalculatorScreen());
      case AppRoutes.monthlyReport:
        return MaterialPageRoute(builder: (_) => const MonthlyReportScreen());
      case AppRoutes.billReminders:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<BillRemindersBloc>()..add(const LoadBillRemindersEvent()),
            child: const BillRemindersScreen(),
          ),
        );
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case AppRoutes.zakat:
        return MaterialPageRoute(builder: (_) => const ZakatScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => SignupScreen());
      case AppRoutes.forgetPassword:
        return MaterialPageRoute(builder: (_) => ForgetPasswordScreen());
      case AppRoutes.verifyOtp:
        final email = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => SetNewPasswodScreen(email: email),
        );
      default:
        return MaterialPageRoute(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              body: Center(
                child: Text(l10n.noRouteForName(settings.name ?? '')),
              ),
            );
          },
        );
    }
  }
}
