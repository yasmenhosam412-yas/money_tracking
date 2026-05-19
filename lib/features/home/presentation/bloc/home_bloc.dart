import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imrpo/features/home/domain/entities/user_profile.dart';
import 'package:imrpo/features/home/domain/usecases/get_user_profile_usecase.dart';
import 'package:imrpo/features/home/domain/usecases/update_username_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUserProfileUsecase getUserProfileUsecase;
  final UpdateUsernameUsecase updateUsernameUsecase;

  HomeBloc({
    required this.getUserProfileUsecase,
    required this.updateUsernameUsecase,
  }) : super(const HomeState()) {
    on<LoadUserProfileEvent>(_onLoadProfile);
    on<ClearUserProfileEvent>(_onClearProfile);
    on<UpdateUsernameEvent>(_onUpdateUsername);
  }

  void _onClearProfile(ClearUserProfileEvent event, Emitter<HomeState> emit) {
    emit(const HomeState());
  }

  Future<void> _onLoadProfile(
    LoadUserProfileEvent event,
    Emitter<HomeState> emit,
  ) async {
    final keepProfile = state.hasProfile;

    emit(
      state.copyWith(
        status: HomeStatus.loading,
        error: '',
        clearProfile: !keepProfile,
      ),
    );

    final result = await getUserProfileUsecase();

    result.fold(
      (failure) {
        if (keepProfile) {
          emit(
            state.copyWith(
              status: HomeStatus.loaded,
              error: failure.error,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: HomeStatus.error,
              error: failure.error,
            ),
          );
        }
      },
      (profile) => emit(
        state.copyWith(
          status: HomeStatus.loaded,
          profile: profile,
          error: '',
        ),
      ),
    );
  }

  Future<void> _onUpdateUsername(
    UpdateUsernameEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.updatingUsername, error: ''));

    final result = await updateUsernameUsecase(event.username.trim());

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (_) => throw StateError('unreachable'));
      emit(
        state.copyWith(
          status: HomeStatus.errorUpdateUsername,
          error: failure.error,
        ),
      );
      return;
    }

    final profileResult = await getUserProfileUsecase();
    if (emit.isDone) return;

    profileResult.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.errorUpdateUsername,
          error: failure.error,
        ),
      ),
      (profile) => emit(
        state.copyWith(
          status: HomeStatus.loaded,
          profile: profile,
          error: '',
        ),
      ),
    );
  }
}
