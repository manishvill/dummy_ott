import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeContent extends HomeEvent {
  const LoadHomeContent();
}

class RefreshHomeContent extends HomeEvent {
  const RefreshHomeContent();
}

class NavigateToCategory extends HomeEvent {
  final String category;

  const NavigateToCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class NavigateToDetails extends HomeEvent {
  final String contentId;

  const NavigateToDetails(this.contentId);

  @override
  List<Object?> get props => [contentId];
}
