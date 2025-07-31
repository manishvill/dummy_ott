import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateUsername>(_onUpdateUsername);
    on<UpdateEmail>(_onUpdateEmail);
    on<ToggleNotifications>(_onToggleNotifications);
    on<ToggleDarkMode>(_onToggleDarkMode);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ChangeVideoQuality>(_onChangeVideoQuality);
    on<UpdateSubscriptionPlan>(_onUpdateSubscriptionPlan);
    on<LogoutUser>(_onLogoutUser);
    on<DeleteAccount>(_onDeleteAccount);
  }

  // Mock user profile data
  static final UserProfile _mockProfile = UserProfile(
    username: 'John Doe',
    email: 'john.doe@example.com',
    avatarUrl: 'https://picsum.photos/seed/profile/200/200',
    notificationsEnabled: true,
    darkModeEnabled: true,
    language: 'English',
    videoQuality: VideoQuality.auto,
    subscriptionPlan: SubscriptionPlan.premium,
    joinDate: DateTime(2023, 1, 15),
    watchlist: ['1', '4', '7', '11', '15'],
    watchedMovies: 127,
    watchedHours: 203,
  );

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      emit(ProfileLoaded(_mockProfile));
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> _onUpdateUsername(
    UpdateUsername event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;

      emit(ProfileUpdating(
        profile: currentProfile,
        message: 'Updating username...',
      ));

      await Future.delayed(const Duration(milliseconds: 500));

      final updatedProfile = currentProfile.copyWith(username: event.username);

      emit(ProfileUpdated(
        profile: updatedProfile,
        message: 'Username updated successfully!',
      ));

      await Future.delayed(const Duration(milliseconds: 100));
      emit(ProfileLoaded(updatedProfile));
    }
  }

  Future<void> _onUpdateEmail(
    UpdateEmail event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;

      emit(ProfileUpdating(
        profile: currentProfile,
        message: 'Updating email...',
      ));

      await Future.delayed(const Duration(milliseconds: 500));

      final updatedProfile = currentProfile.copyWith(email: event.email);

      emit(ProfileUpdated(
        profile: updatedProfile,
        message: 'Email updated successfully!',
      ));

      await Future.delayed(const Duration(milliseconds: 100));
      emit(ProfileLoaded(updatedProfile));
    }
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;
      final updatedProfile = currentProfile.copyWith(
        notificationsEnabled: event.enabled,
      );

      emit(ProfileUpdated(
        profile: updatedProfile,
        message:
            event.enabled ? 'Notifications enabled' : 'Notifications disabled',
      ));

      await Future.delayed(const Duration(milliseconds: 100));
      emit(ProfileLoaded(updatedProfile));
    }
  }

  Future<void> _onToggleDarkMode(
    ToggleDarkMode event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;
      final updatedProfile = currentProfile.copyWith(
        darkModeEnabled: event.enabled,
      );

      emit(ProfileUpdated(
        profile: updatedProfile,
        message: event.enabled ? 'Dark mode enabled' : 'Light mode enabled',
      ));

      await Future.delayed(const Duration(milliseconds: 100));
      emit(ProfileLoaded(updatedProfile));
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;
      final updatedProfile = currentProfile.copyWith(language: event.language);

      emit(ProfileUpdated(
        profile: updatedProfile,
        message: 'Language changed to ${event.language}',
      ));

      await Future.delayed(const Duration(milliseconds: 100));
      emit(ProfileLoaded(updatedProfile));
    }
  }

  Future<void> _onChangeVideoQuality(
    ChangeVideoQuality event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;
      final updatedProfile =
          currentProfile.copyWith(videoQuality: event.quality);

      emit(ProfileUpdated(
        profile: updatedProfile,
        message: 'Video quality changed to ${_getQualityString(event.quality)}',
      ));

      await Future.delayed(const Duration(milliseconds: 100));
      emit(ProfileLoaded(updatedProfile));
    }
  }

  Future<void> _onUpdateSubscriptionPlan(
    UpdateSubscriptionPlan event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;

      emit(ProfileUpdating(
        profile: currentProfile,
        message: 'Updating subscription...',
      ));

      await Future.delayed(const Duration(milliseconds: 1000));

      final updatedProfile = currentProfile.copyWith(
        subscriptionPlan: event.plan,
      );

      emit(ProfileUpdated(
        profile: updatedProfile,
        message: 'Subscription updated to ${_getPlanString(event.plan)}!',
      ));

      await Future.delayed(const Duration(milliseconds: 100));
      emit(ProfileLoaded(updatedProfile));
    }
  }

  Future<void> _onLogoutUser(
    LogoutUser event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating(
      profile: _mockProfile,
      message: 'Logging out...',
    ));

    await Future.delayed(const Duration(milliseconds: 500));
    emit(const ProfileLoggedOut());
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;

      emit(ProfileUpdating(
        profile: currentProfile,
        message: 'Deleting account...',
      ));

      await Future.delayed(const Duration(milliseconds: 1000));
      emit(const ProfileDeleted());
    }
  }

  String _getQualityString(VideoQuality quality) {
    switch (quality) {
      case VideoQuality.low:
        return 'Low';
      case VideoQuality.medium:
        return 'Medium';
      case VideoQuality.high:
        return 'High';
      case VideoQuality.auto:
        return 'Auto';
    }
  }

  String _getPlanString(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.basic:
        return 'Basic';
      case SubscriptionPlan.premium:
        return 'Premium';
      case SubscriptionPlan.family:
        return 'Family';
    }
  }
}
