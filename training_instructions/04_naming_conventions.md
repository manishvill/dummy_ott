# Flutter Naming Conventions and Code Standards for LLM Training

## Overview
This document establishes comprehensive naming conventions and code standards for Flutter development following Dart language guidelines and BLoC pattern best practices.

## File and Directory Naming

### General Rules
- Use **snake_case** for all files and directories
- Keep names descriptive but concise
- Include component type in filename for clarity

### Specific Naming Patterns

#### Dart Files
```
// BLoC Pattern Files
home_bloc.dart
home_event.dart
home_state.dart

// UI Files
home_page.dart
details_page.dart
content_card_widget.dart
custom_app_bar.dart

// Model Files
content_model.dart
user_model.dart
playlist_model.dart

// Repository Files
content_repository.dart
dummy_content_repository.dart
api_content_repository.dart

// Service Files
auth_service.dart
api_service.dart
storage_service.dart

// Utility Files
constants.dart
helpers.dart
validators.dart
extensions.dart
```

#### Directory Structure
```
lib/
├── blocs/              # BLoC components
│   ├── home/          # Feature-specific blocs
│   ├── details/
│   └── auth/
├── models/            # Data models
├── pages/             # UI screens
├── widgets/           # Reusable UI components
├── repository/        # Data access layer
├── services/          # External services
├── utils/             # Utilities and helpers
└── theme/             # App theming
```

## Class Naming Conventions

### BLoC Pattern Classes
```dart
// BLoC Class - FeatureBloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {}
class AuthBloc extends Bloc<AuthEvent, AuthState> {}
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {}

// Event Classes - VerbNounEvent or FeatureActionEvent
abstract class HomeEvent extends Equatable {}
class LoadHomeContent extends HomeEvent {}
class RefreshHomeContent extends HomeEvent {}
class FilterContentByCategory extends HomeEvent {}
class NavigateToDetails extends HomeEvent {}

// State Classes - FeatureStateDescription
abstract class HomeState extends Equatable {}
class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {}
class HomeError extends HomeState {}
class HomeContentFiltered extends HomeState {}
```

### Model Classes
```dart
// Use descriptive entity names with Model suffix
class ContentModel extends Equatable {}
class UserModel extends Equatable {}
class PlaylistModel extends Equatable {}
class CategoryModel extends Equatable {}
class VideoModel extends Equatable {}
```

### Repository Classes
```dart
// Abstract base class
abstract class ContentRepository {}

// Concrete implementations
class ApiContentRepository implements ContentRepository {}
class DummyContentRepository implements ContentRepository {}
class CachedContentRepository implements ContentRepository {}
```

### Service Classes
```dart
class AuthService {}
class ApiService {}
class StorageService {}
class NotificationService {}
class AnalyticsService {}
```

### UI Classes
```dart
// Pages - FeaturePage
class HomePage extends StatelessWidget {}
class DetailsPage extends StatefulWidget {}
class ProfilePage extends StatelessWidget {}
class CategoryPage extends StatelessWidget {}

// Widgets - DescriptiveWidget
class ContentCard extends StatelessWidget {}
class CustomAppBar extends StatelessWidget {}
class LoadingIndicator extends StatelessWidget {}
class ErrorDisplay extends StatelessWidget {}
```

## Variable and Method Naming

### Variable Names
```dart
// Use camelCase for variables
String contentTitle;
List<ContentModel> featuredMovies;
Map<String, dynamic> userPreferences;
bool isLoading;
int totalEpisodes;
double averageRating;

// Collections - use plural nouns
List<String> categories;
List<ContentModel> recommendedShows;
Map<String, String> genreMapping;

// Boolean variables - use is/has/can/should prefix
bool isVisible;
bool hasPermission;
bool canPlayVideo;
bool shouldShowAds;

// Constants - use lowerCamelCase or UPPER_SNAKE_CASE for compile-time constants
const String apiBaseUrl = 'https://api.example.com';
const int maxRetryAttempts = 3;
static const Duration timeoutDuration = Duration(seconds: 30);

// For global constants, use UPPER_SNAKE_CASE
const String API_BASE_URL = 'https://api.example.com';
const int MAX_RETRY_ATTEMPTS = 3;
```

### Method Names
```dart
// Use verbs that describe the action
void loadContent();
Future<void> refreshData();
void navigateToDetails(String id);
bool validateInput(String input);
String formatDuration(int minutes);

// Private methods - prefix with underscore
void _onLoadContent();
Widget _buildContentSection();
Future<void> _fetchFromApi();
void _handleError(String error);

// Event handlers - use _onEventName pattern
void _onLoadHomeContent(LoadHomeContent event, Emitter<HomeState> emit);
void _onRefreshContent(RefreshContent event, Emitter<HomeState> emit);

// Widget building methods
Widget _buildBody(BuildContext context);
Widget _buildLoadingState();
Widget _buildErrorState(String message);
Widget _buildContentList(List<ContentModel> content);

// Getter methods
List<ContentModel> get filteredContent => _content.where(...).toList();
bool get hasContent => _content.isNotEmpty;
String get formattedDuration => '${duration ~/ 60}h ${duration % 60}m';
```

### Constructor and Parameter Naming
```dart
class ContentModel {
  // Required parameters first, optional parameters last
  const ContentModel({
    required this.id,
    required this.title,
    required this.description,
    this.rating = 0.0,
    this.isFeatured = false,
    super.key, // For widgets
  });
}

// Named constructors use descriptive names
class ContentModel {
  const ContentModel.featured({
    required this.id,
    required this.title,
    required this.description,
    this.rating = 0.0,
  }) : isFeatured = true;

  const ContentModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        description = json['description'];
}
```

## Code Organization Standards

### Import Organization
```dart
// 1. Dart core libraries
import 'dart:async';
import 'dart:convert';

// 2. Flutter libraries
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages (alphabetical order)
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 4. Internal imports (relative paths)
import '../models/content_model.dart';
import '../repository/content_repository.dart';
import 'home_event.dart';
import 'home_state.dart';
```

### Class Structure Order
```dart
class ExampleWidget extends StatelessWidget {
  // 1. Static constants
  static const String title = 'Example';
  
  // 2. Instance variables
  final String data;
  final VoidCallback? onTap;
  
  // 3. Constructor
  const ExampleWidget({
    super.key,
    required this.data,
    this.onTap,
  });

  // 4. Build method (for widgets)
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // 5. Public methods
  void publicMethod() {}

  // 6. Private methods
  void _privateMethod() {}

  // 7. Override methods
  @override
  String toString() => 'ExampleWidget(data: $data)';
}
```

### Documentation Standards
```dart
/// A model representing video content in the OTT application.
/// 
/// This class contains all the necessary information about a piece of content
/// including metadata, ratings, and categorization.
class ContentModel extends Equatable {
  /// Unique identifier for the content
  final String id;
  
  /// Display title of the content
  final String title;
  
  /// Detailed description of the content
  final String description;
  
  /// Creates a new [ContentModel] instance.
  /// 
  /// The [id], [title], and [description] parameters are required.
  /// The [rating] defaults to 0.0 and [isFeatured] defaults to false.
  const ContentModel({
    required this.id,
    required this.title,
    required this.description,
    this.rating = 0.0,
    this.isFeatured = false,
  });

  /// Creates a copy of this content model with the given fields replaced.
  ContentModel copyWith({
    String? id,
    String? title,
    String? description,
    double? rating,
    bool? isFeatured,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
```

## Code Quality Standards

### Use of const and final
```dart
// Use const for compile-time constants
const String appName = 'OTT Stream';
const EdgeInsets defaultPadding = EdgeInsets.all(16.0);

// Use final for runtime constants
final DateTime now = DateTime.now();
final String formattedDate = DateFormat.yMd().format(now);

// Use const constructors when possible
const SizedBox(height: 16);
const Text('Hello World');
const Icon(Icons.star);
```

### Error Handling Patterns
```dart
// Repository error handling
Future<List<ContentModel>> getContent() async {
  try {
    final response = await _apiService.fetchContent();
    return response.map((json) => ContentModel.fromJson(json)).toList();
  } on NetworkException catch (e) {
    throw ContentRepositoryException('Network error: ${e.message}');
  } on FormatException catch (e) {
    throw ContentRepositoryException('Data format error: ${e.message}');
  } catch (e) {
    throw ContentRepositoryException('Unexpected error: ${e.toString()}');
  }
}

// BLoC error handling
Future<void> _onLoadContent(
  LoadContent event,
  Emitter<ContentState> emit,
) async {
  try {
    emit(const ContentLoading());
    final content = await repository.getContent();
    emit(ContentLoaded(content: content));
  } catch (error) {
    emit(ContentError(message: error.toString()));
  }
}
```

### Validation Patterns
```dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
```

### Extension Usage
```dart
extension StringExtensions on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
}

extension ContextExtensions on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void pushNamed(String routeName, {Object? arguments}) {
    Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }
}
```

## Performance Best Practices

### Widget Performance
```dart
// Use const constructors
const Text('Static text');
const SizedBox(height: 16);

// Extract widgets to methods for reusability
Widget _buildTitle(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );
}

// Use keys for list items
ListView.builder(
  itemBuilder: (context, index) {
    return ContentCard(
      key: ValueKey(items[index].id),
      content: items[index],
    );
  },
);
```

### Memory Management
```dart
class _VideoPlayerState extends State<VideoPlayer> 
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
```

Following these conventions ensures code consistency, readability, and maintainability across the entire Flutter project.
