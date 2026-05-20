import 'dart:async';
import 'dart:io';

import 'package:imrpo/core/helpers/network_error_classifier.dart';
import 'package:imrpo/core/l10n/l10n_error_tokens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

sealed class Failure {
  final String error;

  Failure({required this.error});
}

class AuthError extends Failure {
  AuthError({required super.error});
}

class NetworkError extends Failure {
  NetworkError({required super.error});
}

class ServerError extends Failure {
  ServerError({required super.error});
}

class UnknownError extends Failure {
  UnknownError({required super.error});
}

class ErrorHelper {
  static Failure handle(Object e) {
    if (e is AuthException) {
      if (messageIndicatesNoInternet(e.message)) {
        return NetworkError(error: l10nNoInternetToken);
      }
      return AuthError(error: e.message);
    }

    if (e is SocketException) {
      return NetworkError(error: l10nNoInternetToken);
    }

    if (e is TimeoutException) {
      return NetworkError(error: l10nNoInternetToken);
    }

    if (e is HandshakeException || e is TlsException) {
      return NetworkError(error: l10nNoInternetToken);
    }

    if (e is PostgrestException) {
      if (messageIndicatesNoInternet(e.message)) {
        return NetworkError(error: l10nNoInternetToken);
      }
      return ServerError(error: e.message);
    }

    final asString = e.toString();
    if (messageIndicatesNoInternet(asString)) {
      return NetworkError(error: l10nNoInternetToken);
    }

    return UnknownError(error: asString);
  }
}