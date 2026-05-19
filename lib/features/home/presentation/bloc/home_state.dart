part of 'home_bloc.dart';

enum HomeStatus {
  initial,
  loading,
  loaded,
  error,
  updatingUsername,
  usernameUpdated,
  errorUpdateUsername,
}

class HomeState extends Equatable {
  final HomeStatus status;
  final UserProfile? profile;
  final String error;

  const HomeState({
    this.status = HomeStatus.initial,
    this.profile,
    this.error = '',
  });

  bool get hasProfile => profile != null;

  bool get isInitialLoading =>
      status == HomeStatus.loading && !hasProfile;

  bool get isRefreshingProfile =>
      status == HomeStatus.loading && hasProfile;

  bool get isUpdatingUsername => status == HomeStatus.updatingUsername;

  HomeState copyWith({
    HomeStatus? status,
    UserProfile? profile,
    String? error,
    bool clearProfile = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      profile: clearProfile ? null : (profile ?? this.profile),
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, profile, error];
}
