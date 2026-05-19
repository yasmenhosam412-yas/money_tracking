part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadUserProfileEvent extends HomeEvent {
  const LoadUserProfileEvent();
}

class ClearUserProfileEvent extends HomeEvent {
  const ClearUserProfileEvent();
}

class UpdateUsernameEvent extends HomeEvent {
  final String username;

  const UpdateUsernameEvent(this.username);

  @override
  List<Object> get props => [username];
}
