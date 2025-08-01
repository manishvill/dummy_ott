# Flutter BLoC Pattern Coding Guidelines for LLM Training

## Overview
This document provides comprehensive guidelines for writing Flutter code following the BLoC (Business Logic Component) pattern. Follow these examples and conventions when generating code.

## BLoC Pattern Structure

### 1. Event Classes (feature_event.dart)
Events represent user actions or external triggers that cause state changes.

```dart
import 'package:equatable/equatable.dart';

// Base event class - always use Equatable
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

// Load initial data event
class LoadHomeContent extends HomeEvent {
  const LoadHomeContent();
}

// Refresh data event
class RefreshHomeContent extends HomeEvent {
  const RefreshHomeContent();
}

// Navigation events with parameters
class NavigateToDetails extends HomeEvent {
  final String contentId;

  const NavigateToDetails({required this.contentId});

  @override
  List<Object?> get props => [contentId];
}

// Filter/search events
class FilterContentByCategory extends HomeEvent {
  final String category;

  const FilterContentByCategory({required this.category});

  @override
  List<Object?> get props => [category];
}
```

### 2. State Classes (feature_state.dart)
States represent the current condition of the application data.

```dart
import 'package:equatable/equatable.dart';
import '../../models/content_model.dart';

// Base state class - always use Equatable
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

// Initial state
class HomeInitial extends HomeState {
  const HomeInitial();
}

// Loading state
class HomeLoading extends HomeState {
  const HomeLoading();
}

// Success state with data
class HomeLoaded extends HomeState {
  final List<ContentModel> featuredContent;
  final List<ContentModel> comedyContent;
  final List<ContentModel> thrillerContent;
  final List<ContentModel> romanceContent;
  final List<String> categories;

  const HomeLoaded({
    required this.featuredContent,
    required this.comedyContent,
    required this.thrillerContent,
    required this.romanceContent,
    required this.categories,
  });

  @override
  List<Object?> get props => [
        featuredContent,
        comedyContent,
        thrillerContent,
        romanceContent,
        categories,
      ];
}

// Error state
class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Partial update states for specific sections
class HomeContentUpdated extends HomeState {
  final List<ContentModel> updatedContent;
  final String section; // 'featured', 'comedy', etc.

  const HomeContentUpdated({
    required this.updatedContent,
    required this.section,
  });

  @override
  List<Object?> get props => [updatedContent, section];
}
```

### 3. BLoC Class (feature_bloc.dart)
The BLoC handles business logic and state transitions.

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/dummy_content_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final DummyContentRepository repository;

  HomeBloc({required this.repository}) : super(const HomeInitial()) {
    // Register event handlers
    on<LoadHomeContent>(_onLoadHomeContent);
    on<RefreshHomeContent>(_onRefreshHomeContent);
    on<NavigateToDetails>(_onNavigateToDetails);
    on<FilterContentByCategory>(_onFilterContentByCategory);
  }

  // Event handler for loading initial content
  Future<void> _onLoadHomeContent(
    LoadHomeContent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(const HomeLoading());

      // Fetch data from repository
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
    } catch (error) {
      emit(HomeError(message: 'Failed to load content: ${error.toString()}'));
    }
  }

  // Event handler for refresh
  Future<void> _onRefreshHomeContent(
    RefreshHomeContent event,
    Emitter<HomeState> emit,
  ) async {
    // Don't show loading for refresh, keep current state
    try {
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
    } catch (error) {
      emit(HomeError(message: 'Failed to refresh content: ${error.toString()}'));
    }
  }

  // Navigation handler (might trigger navigation in UI)
  void _onNavigateToDetails(
    NavigateToDetails event,
    Emitter<HomeState> emit,
  ) {
    // This could emit a navigation state or be handled in the UI layer
    // For now, we'll keep the current state
  }

  // Filter content handler
  Future<void> _onFilterContentByCategory(
    FilterContentByCategory event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(const HomeLoading());
      
      final filteredContent = await repository.getContentByCategory(event.category);
      
      emit(HomeContentUpdated(
        updatedContent: filteredContent,
        section: event.category.toLowerCase(),
      ));
    } catch (error) {
      emit(HomeError(message: 'Failed to filter content: ${error.toString()}'));
    }
  }
}
```

## Model Classes

### Data Model Example (model_name_model.dart)
```dart
import 'package:equatable/equatable.dart';

class ContentModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final bool isFeatured;
  final double rating;
  final DateTime releaseDate;
  final int duration; // in minutes
  final List<String> genres;

  const ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.isFeatured = false,
    this.rating = 0.0,
    required this.releaseDate,
    this.duration = 0,
    this.genres = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        category,
        isFeatured,
        rating,
        releaseDate,
        duration,
        genres,
      ];

  // Copy with method for immutable updates
  ContentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    bool? isFeatured,
    double? rating,
    DateTime? releaseDate,
    int? duration,
    List<String>? genres,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isFeatured: isFeatured ?? this.isFeatured,
      rating: rating ?? this.rating,
      releaseDate: releaseDate ?? this.releaseDate,
      duration: duration ?? this.duration,
      genres: genres ?? this.genres,
    );
  }

  // JSON serialization (if needed for API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'isFeatured': isFeatured,
      'rating': rating,
      'releaseDate': releaseDate.toIso8601String(),
      'duration': duration,
      'genres': genres,
    };
  }

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      isFeatured: json['isFeatured'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
      duration: json['duration'] as int? ?? 0,
      genres: List<String>.from(json['genres'] as List? ?? []),
    );
  }
}
```

## Repository Classes

### Repository Pattern Example (feature_repository.dart)
```dart
import '../models/content_model.dart';

abstract class ContentRepository {
  Future<List<ContentModel>> getFeaturedContent();
  Future<List<ContentModel>> getContentByCategory(String category);
  Future<List<String>> getCategories();
  Future<ContentModel?> getContentById(String id);
  Future<List<ContentModel>> searchContent(String query);
}

class DummyContentRepository implements ContentRepository {
  // Mock data for development
  static const List<ContentModel> _mockContent = [
    ContentModel(
      id: '1',
      title: 'Action Movie 1',
      description: 'An exciting action movie',
      imageUrl: 'https://example.com/image1.jpg',
      category: 'Action',
      isFeatured: true,
      rating: 4.5,
      releaseDate: '2023-01-01',
      duration: 120,
      genres: ['Action', 'Adventure'],
    ),
    // Add more mock data...
  ];

  @override
  Future<List<ContentModel>> getFeaturedContent() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _mockContent.where((content) => content.isFeatured).toList();
  }

  @override
  Future<List<ContentModel>> getContentByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _mockContent.where((content) => content.category == category).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return _mockContent.map((content) => content.category).toSet().toList();
  }

  @override
  Future<ContentModel?> getContentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    try {
      return _mockContent.firstWhere((content) => content.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ContentModel>> searchContent(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final lowercaseQuery = query.toLowerCase();
    return _mockContent.where((content) =>
        content.title.toLowerCase().contains(lowercaseQuery) ||
        content.description.toLowerCase().contains(lowercaseQuery) ||
        content.category.toLowerCase().contains(lowercaseQuery)).toList();
  }
}
```

## Naming Conventions

### Class Names
- **BLoC**: `FeatureNameBloc` (e.g., `HomeBloc`, `ProfileBloc`)
- **Events**: `VerbNounEvent` (e.g., `LoadHomeContent`, `RefreshUserProfile`)
- **States**: `FeatureNameState` (e.g., `HomeLoading`, `ProfileLoaded`)
- **Models**: `EntityNameModel` (e.g., `ContentModel`, `UserModel`)
- **Repositories**: `EntityNameRepository` (e.g., `ContentRepository`)

### Variable Names
- Use **camelCase** for variables and method names
- Use descriptive names that indicate purpose
- For collections, use plural nouns (e.g., `contentList`, `categories`)

### Method Names
- Use verbs that describe the action (e.g., `loadContent`, `refreshData`)
- Private methods start with underscore (e.g., `_onLoadContent`)
- Event handlers follow pattern `_onEventName`

### File Organization Rules
1. Import statements in this order:
   - Dart core libraries
   - Flutter libraries
   - Third-party packages
   - Local imports (relative imports)

2. Class structure order:
   - Constructor
   - Public methods
   - Private methods
   - Override methods

3. Always use `const` constructors where possible
4. Always extend `Equatable` for events, states, and models
5. Always use `required` for mandatory parameters
6. Provide default values for optional parameters

This structure ensures clean, maintainable, and testable code following Flutter and BLoC best practices.
