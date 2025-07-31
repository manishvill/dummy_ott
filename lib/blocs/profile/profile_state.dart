import 'package:equatable/equatable.dart';
import 'profile_event.dart';

class UserProfile extends Equatable {
  final String username;
  final String email;
  final String avatarUrl;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String language;
  final VideoQuality videoQuality;
  final SubscriptionPlan subscriptionPlan;
  final DateTime joinDate;
  final List<String> watchlist;
  final int watchedMovies;
  final int watchedHours;

  const UserProfile({
    required this.username,
    required this.email,
    required this.avatarUrl,
    this.notificationsEnabled = true,
    this.darkModeEnabled = true,
    this.language = 'English',
    this.videoQuality = VideoQuality.auto,
    this.subscriptionPlan = SubscriptionPlan.free,
    required this.joinDate,
    this.watchlist = const [],
    this.watchedMovies = 0,
    this.watchedHours = 0,
  });

  UserProfile copyWith({
    String? username,
    String? email,
    String? avatarUrl,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? language,
    VideoQuality? videoQuality,
    SubscriptionPlan? subscriptionPlan,
    DateTime? joinDate,
    List<String>? watchlist,
    int? watchedMovies,
    int? watchedHours,
  }) {
    return UserProfile(
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      language: language ?? this.language,
      videoQuality: videoQuality ?? this.videoQuality,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      joinDate: joinDate ?? this.joinDate,
      watchlist: watchlist ?? this.watchlist,
      watchedMovies: watchedMovies ?? this.watchedMovies,
      watchedHours: watchedHours ?? this.watchedHours,
    );
  }

  @override
  List<Object?> get props => [
        username,
        email,
        avatarUrl,
        notificationsEnabled,
        darkModeEnabled,
        language,
        videoQuality,
        subscriptionPlan,
        joinDate,
        watchlist,
        watchedMovies,
        watchedHours,
      ];
}

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdating extends ProfileState {
  final UserProfile profile;
  final String message;

  const ProfileUpdating({
    required this.profile,
    required this.message,
  });

  @override
  List<Object?> get props => [profile, message];
}

class ProfileUpdated extends ProfileState {
  final UserProfile profile;
  final String message;

  const ProfileUpdated({
    required this.profile,
    required this.message,
  });

  @override
  List<Object?> get props => [profile, message];
}

class ProfileLoggedOut extends ProfileState {
  const ProfileLoggedOut();
}

class ProfileDeleted extends ProfileState {
  const ProfileDeleted();
}
