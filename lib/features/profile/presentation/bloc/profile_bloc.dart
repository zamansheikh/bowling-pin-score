import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/save_game_result.dart';
import 'profile_event.dart';
import 'profile_state.dart';

@Injectable()
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile getUserProfile;
  final UpdateUserProfile updateUserProfile;
  final SaveGameResult saveGameResult;

  ProfileBloc({
    required this.getUserProfile,
    required this.updateUserProfile,
    required this.saveGameResult,
  }) : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<GameResultSaved>(_onGameResultSaved);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getUserProfile();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;

      final updatedProfile = currentProfile.copyWith(
        name: event.name,
        avatarPath: event.avatarPath,
        lastActiveAt: DateTime.now(),
      );

      final result = await updateUserProfile(updatedProfile);
      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (profile) => emit(ProfileLoaded(profile)),
      );
    }
  }

  Future<void> _onGameResultSaved(
    GameResultSaved event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await saveGameResult(
      finalScore: event.finalScore,
      strikes: event.strikes,
      spares: event.spares,
      totalPins: event.totalPins,
      isPerfectGame: event.isPerfectGame,
    );

    result.fold((failure) => emit(ProfileError(failure.message)), (_) {
      // Reload profile to get updated statistics
      add(ProfileLoadRequested());
    });
  }
}
