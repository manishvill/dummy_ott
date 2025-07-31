import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateUsername extends ProfileEvent {
  final String username;

  const UpdateUsername(this.username);

  @override
  List<Object?> get props => [username];
}

class UpdateEmail extends ProfileEvent {
  final String email;

  const UpdateEmail(this.email);

  @override
  List<Object?> get props => [email];
}

class ToggleNotifications extends ProfileEvent {
  final bool enabled;

  const ToggleNotifications(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleDarkMode extends ProfileEvent {
  final bool enabled;

  const ToggleDarkMode(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ChangeLanguage extends ProfileEvent {
  final String language;

  const ChangeLanguage(this.language);

  @override
  List<Object?> get props => [language];
}

class ChangeVideoQuality extends ProfileEvent {
  final VideoQuality quality;

  const ChangeVideoQuality(this.quality);

  @override
  List<Object?> get props => [quality];
}

class UpdateSubscriptionPlan extends ProfileEvent {
  final SubscriptionPlan plan;

  const UpdateSubscriptionPlan(this.plan);

  @override
  List<Object?> get props => [plan];
}

class LogoutUser extends ProfileEvent {
  const LogoutUser();
}

class DeleteAccount extends ProfileEvent {
  const DeleteAccount();
}

enum VideoQuality { low, medium, high, auto }

enum SubscriptionPlan { free, basic, premium, family }
