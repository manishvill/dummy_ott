import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  const LoadCategories();
}

class LoadAllCategoryContent extends CategoryEvent {
  const LoadAllCategoryContent();
}

class FilterByCategory extends CategoryEvent {
  final String category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class ClearCategoryFilter extends CategoryEvent {
  const ClearCategoryFilter();
}

class SearchInCategory extends CategoryEvent {
  final String query;

  const SearchInCategory(this.query);

  @override
  List<Object?> get props => [query];
}

class SortCategoryContent extends CategoryEvent {
  final CategorySortType sortType;

  const SortCategoryContent(this.sortType);

  @override
  List<Object?> get props => [sortType];
}

enum CategorySortType {
  alphabetical,
  rating,
  newest,
  featured,
}
