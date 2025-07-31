import 'package:equatable/equatable.dart';
import '../../models/content_model.dart';
import 'category_event.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  final List<ContentModel> content;
  final List<ContentModel> filteredContent;
  final List<Category> categories;
  final String? selectedCategory;
  final String searchQuery;
  final CategorySortType sortType;

  const CategoryLoaded({
    required this.content,
    required this.filteredContent,
    required this.categories,
    this.selectedCategory,
    this.searchQuery = '',
    this.sortType = CategorySortType.alphabetical,
  });

  CategoryLoaded copyWith({
    List<ContentModel>? content,
    List<ContentModel>? filteredContent,
    List<Category>? categories,
    String? selectedCategory,
    String? searchQuery,
    CategorySortType? sortType,
  }) {
    return CategoryLoaded(
      content: content ?? this.content,
      filteredContent: filteredContent ?? this.filteredContent,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      sortType: sortType ?? this.sortType,
    );
  }

  @override
  List<Object?> get props => [
        content,
        filteredContent,
        categories,
        selectedCategory,
        searchQuery,
        sortType,
      ];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryFiltered extends CategoryState {
  final String category;
  final List<ContentModel> content;

  const CategoryFiltered({
    required this.category,
    required this.content,
  });

  @override
  List<Object?> get props => [category, content];
}

class CategorySearchResults extends CategoryState {
  final String query;
  final List<ContentModel> results;

  const CategorySearchResults({
    required this.query,
    required this.results,
  });

  @override
  List<Object?> get props => [query, results];
}
