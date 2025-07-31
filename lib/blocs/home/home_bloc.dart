import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/dummy_content_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final DummyContentRepository repository;

  HomeBloc({required this.repository}) : super(const HomeInitial()) {
    on<LoadHomeContent>(_onLoadHomeContent);
    on<RefreshHomeContent>(_onRefreshHomeContent);
    on<NavigateToCategory>(_onNavigateToCategory);
    on<NavigateToDetails>(_onNavigateToDetails);
  }

  Future<void> _onLoadHomeContent(
    LoadHomeContent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(const HomeLoading());

      final featuredContent = await repository.getFeaturedContent();
      final comedyContent = await repository.getContentByCategory('Comedy');
      final thrillerContent = await repository.getContentByCategory('Thriller');
      final romanceContent = await repository.getContentByCategory('Romance');
      final categories = await repository.getCategories();

      emit(HomeLoaded(
        featuredContent: featuredContent,
        comedyContent: comedyContent,
        thrillerContent: thrillerContent,
        romanceContent: romanceContent,
        categories: categories,
      ));
    } catch (e) {
      emit(HomeError('Failed to load home content: $e'));
    }
  }

  Future<void> _onRefreshHomeContent(
    RefreshHomeContent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Don't emit loading state for refresh to avoid flickering
      final featuredContent = await repository.getFeaturedContent();
      final comedyContent = await repository.getContentByCategory('Comedy');
      final thrillerContent = await repository.getContentByCategory('Thriller');
      final romanceContent = await repository.getContentByCategory('Romance');
      final categories = await repository.getCategories();

      emit(HomeLoaded(
        featuredContent: featuredContent,
        comedyContent: comedyContent,
        thrillerContent: thrillerContent,
        romanceContent: romanceContent,
        categories: categories,
      ));
    } catch (e) {
      emit(HomeError('Failed to refresh home content: $e'));
    }
  }

  Future<void> _onNavigateToCategory(
    NavigateToCategory event,
    Emitter<HomeState> emit,
  ) async {
    // This event can be used for analytics or pre-loading category data
    // For now, we just maintain the current state
  }

  Future<void> _onNavigateToDetails(
    NavigateToDetails event,
    Emitter<HomeState> emit,
  ) async {
    // This event can be used for analytics or pre-loading details data
    // For now, we just maintain the current state
  }
}
