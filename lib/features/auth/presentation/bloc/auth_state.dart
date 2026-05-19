part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loadingLogin,
  loadingSignup,
  loadingForgetPassword,
  successLogin,
  successSignup,
  successForgetPassword,
  successVerifySetNewPass,
  errorLogin,
  errorSignup,
  errorForgetPassword,
  errorVerifySetNewPass,
  loadingVerifySetNewPass,
  loadingLogout,
  loadingDeleteAccount,
  loggedOut,
  accountDeleted,
  errorLogout,
  errorDeleteAccount,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({this.status = AuthStatus.initial, this.errorMessage});

   AuthState copyWith({AuthStatus? status, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, errorMessage ?? ''];
}
