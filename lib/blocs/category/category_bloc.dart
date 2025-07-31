import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/dummy_content_repository.dart';
import '../../models/content_model.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final DummyContentRepository repository;

  CategoryBloc({required this.repository}) : super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadAllCategoryContent>(_onLoadAllCategoryContent);
    on<FilterByCategory>(_onFilterByCategory);
    on<ClearCategoryFilter>(_onClearCategoryFilter);
    on<SearchInCategory>(_onSearchInCategory);
    on<SortCategoryContent>(_onSortCategoryContent);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryLoading());

      final categories = await repository.getCategories();
      final allContent = await repository.getAllContent();

      emit(CategoryLoaded(
        content: allContent,
        filteredContent: allContent,
        categories: categories,
      ));
    } catch (e) {
      emit(CategoryError('Failed to load categories: $e'));
    }
  }

  Future<void> _onLoadAllCategoryContent(
    LoadAllCategoryContent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryLoading());

      final allContent = await repository.getAllContent();
      final categories = await repository.getCategories();

      emit(CategoryLoaded(
        content: allContent,
        filteredContent: allContent,
        categories: categories,
      ));
    } catch (e) {
      emit(CategoryError('Failed to load content: $e'));
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final categoryContent =
          await repository.getContentByCategory(event.category);
      final categories = await repository.getCategories();
      final allContent = await repository.getAllContent();

      emit(CategoryLoaded(
        content: allContent,
        filteredContent: categoryContent,
        categories: categories,
        selectedCategory: event.category,
      ));
    } catch (e) {
      emit(CategoryError('Failed to filter by category: $e'));
    }
  }

  Future<void> _onClearCategoryFilter(
    ClearCategoryFilter event,
    Emitter<CategoryState> emit,
  ) async {
    if (state is CategoryLoaded) {
      final currentState = state as CategoryLoaded;
      emit(currentState.copyWith(
        filteredContent: currentState.content,
        selectedCategory: null,
        searchQuery: '',
      ));
    }
  }

  Future<void> _onSearchInCategory(
    SearchInCategory event,
    Emitter<CategoryState> emit,
  ) async {
    if (state is CategoryLoaded) {
      final currentState = state as CategoryLoaded;

      if (event.query.isEmpty) {
        emit(currentState.copyWith(
          filteredContent: currentState.selectedCategory != null
              ? currentState.content
                  .where((content) =>
                      content.category == currentState.selectedCategory)
                  .toList()
              : currentState.content,
          searchQuery: '',
        ));
        return;
      }

      List<ContentModel> searchResults;

      if (currentState.selectedCategory != null) {
        // Search within selected category
        searchResults = currentState.content
            .where((content) =>
                content.category == currentState.selectedCategory &&
                (content.title
                        .toLowerCase()
                        .contains(event.query.toLowerCase()) ||
                    content.description
                        .toLowerCase()
                        .contains(event.query.toLowerCase())))
            .toList();
      } else {
        // Search in all content
        searchResults = currentState.content
            .where((content) =>
                content.title
                    .toLowerCase()
                    .contains(event.query.toLowerCase()) ||
                content.description
                    .toLowerCase()
                    .contains(event.query.toLowerCase()))
            .toList();
      }

      emit(currentState.copyWith(
        filteredContent: searchResults,
        searchQuery: event.query,
      ));
    }
  }

  Future<void> _onSortCategoryContent(
    SortCategoryContent event,
    Emitter<CategoryState> emit,
  ) async {
    if (state is CategoryLoaded) {
      final currentState = state as CategoryLoaded;

      List<ContentModel> sortedContent =
          List.from(currentState.filteredContent);

      switch (event.sortType) {
        case CategorySortType.alphabetical:
          sortedContent.sort((a, b) => a.title.compareTo(b.title));
          break;
        case CategorySortType.rating:
          sortedContent.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case CategorySortType.newest:
          // For demo purposes, sort by ID (assuming higher ID = newer)
          sortedContent.sort((a, b) => b.id.compareTo(a.id));
          break;
        case CategorySortType.featured:
          sortedContent.sort((a, b) {
            if (a.isFeatured && !b.isFeatured) return -1;
            if (!a.isFeatured && b.isFeatured) return 1;
            return b.rating.compareTo(a.rating);
          });
          break;
      }

      emit(currentState.copyWith(
        filteredContent: sortedContent,
        sortType: event.sortType,
      ));
    }
  }
}
