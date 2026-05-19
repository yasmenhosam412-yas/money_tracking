import 'package:flutter/material.dart';
import 'package:imrpo/l10n/app_localizations.dart';
import 'package:imrpo/features/auth/presentation/pages/forget_password_screen.dart';
import 'package:imrpo/features/auth/presentation/pages/login_screen.dart';
import 'package:imrpo/features/auth/presentation/pages/set_new_passwod_screen.dart';
import 'package:imrpo/features/auth/presentation/pages/signup_screen.dart';
import 'package:imrpo/features/home/presentation/pages/home_screen.dart';

class AppRoutes {
  static const String home = '/home';
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
