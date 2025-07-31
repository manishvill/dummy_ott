import 'package:equatable/equatable.dart';
import '../../models/content_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<ContentModel> featuredContent;
  final List<ContentModel> comedyContent;
  final List<ContentModel> thrillerContent;
  final List<ContentModel> romanceContent;
  final List<Category> categories;

  const HomeLoaded({
    required this.featuredContent,
    required this.comedyContent,
    required this.thrillerContent,
    required this.romanceContent,
    required this.categories,
  });

  HomeLoaded copyWith({
    List<ContentModel>? featuredContent,
    List<ContentModel>? comedyContent,
    List<ContentModel>? thrillerContent,
    List<ContentModel>? romanceContent,
    List<Category>? categories,
  }) {
    return HomeLoaded(
      featuredContent: featuredContent ?? this.featuredContent,
      comedyContent: comedyContent ?? this.comedyContent,
      thrillerContent: thrillerContent ?? this.thrillerContent,
      romanceContent: romanceContent ?? this.romanceContent,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [
        featuredContent,
        comedyContent,
        thrillerContent,
        romanceContent,
        categories,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
