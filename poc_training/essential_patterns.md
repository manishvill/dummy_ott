# Essential Flutter BLoC Patterns - POC Training Guide

## Project Structure Reference
Based on your OTT app codebase structure:

```
lib/
├── main.dart                   # App entry point
├── firebase_options.dart       # Firebase config
├── blocs/                      # BLoC pattern implementation
│   ├── home/
│   │   ├── home_bloc.dart
│   │   ├── home_event.dart
│   │   └── home_state.dart
│   ├── details/
│   ├── category/
│   └── profile/
├── models/
│   └── content_model.dart      # Data models
├── pages/
│   ├── home_page.dart          # UI screens
│   ├── details_page.dart
│   ├── category_page.dart
│   └── profile_page.dart
└── repository/
    └── dummy_content_repository.dart
```

## Core BLoC Pattern Implementation

### 1. Event Pattern (Reference: `home_event.dart`)
```dart
import 'package:equatable/equatable.dart';

abstract class FeatureEvent extends Equatable {
  const FeatureEvent();

  @override
  List<Object?> get props => [];
}

// Simple events without parameters
class LoadFeatureData extends FeatureEvent {
  const LoadFeatureData();
}

class RefreshFeatureData extends FeatureEvent {
  const RefreshFeatureData();
}

// Events with parameters
class NavigateToItem extends FeatureEvent {
  final String itemId;

  const NavigateToItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class FilterByCategory extends FeatureEvent {
  final String category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}
```

### 2. State Pattern (Reference: `home_state.dart`)
```dart
import 'package:equatable/equatable.dart';
import '../../models/content_model.dart';

abstract class FeatureState extends Equatable {
  const FeatureState();

  @override
  List<Object?> get props => [];
}

class FeatureInitial extends FeatureState {
  const FeatureInitial();
}

class FeatureLoading extends FeatureState {
  const FeatureLoading();
}

class FeatureLoaded extends FeatureState {
  final List<ContentModel> items;
  final List<String> categories;
  
  const FeatureLoaded({
    required this.items,
    required this.categories,
  });

  @override
  List<Object?> get props => [items, categories];
}

class FeatureError extends FeatureState {
  final String message;

  const FeatureError({required this.message});

  @override
  List<Object?> get props => [message];
}
```

### 3. BLoC Pattern (Reference: `home_bloc.dart`)
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/dummy_content_repository.dart';
import 'feature_event.dart';
import 'feature_state.dart';

class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final DummyContentRepository repository;

  FeatureBloc({required this.repository}) : super(const FeatureInitial()) {
    on<LoadFeatureData>(_onLoadFeatureData);
    on<RefreshFeatureData>(_onRefreshFeatureData);
    on<FilterByCategory>(_onFilterByCategory);
  }

  Future<void> _onLoadFeatureData(
    LoadFeatureData event,
    Emitter<FeatureState> emit,
  ) async {
    try {
      emit(const FeatureLoading());
      
      final items = await repository.getFeaturedContent();
      final categories = await repository.getCategories();
      
      emit(FeatureLoaded(
        items: items,
        categories: categories,
      ));
    } catch (error) {
      emit(FeatureError(message: error.toString()));
    }
  }

  Future<void> _onRefreshFeatureData(
    RefreshFeatureData event,
    Emitter<FeatureState> emit,
  ) async {
    try {
      final items = await repository.getFeaturedContent();
      final categories = await repository.getCategories();
      
      emit(FeatureLoaded(
        items: items,
        categories: categories,
      ));
    } catch (error) {
      emit(FeatureError(message: error.toString()));
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<FeatureState> emit,
  ) async {
    try {
      emit(const FeatureLoading());
      
      final filteredItems = await repository.getContentByCategory(event.category);
      final categories = await repository.getCategories();
      
      emit(FeatureLoaded(
        items: filteredItems,
        categories: categories,
      ));
    } catch (error) {
      emit(FeatureError(message: error.toString()));
    }
  }
}
```

## Model Pattern (Reference: `content_model.dart`)
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

  const ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.isFeatured = false,
    this.rating = 0.0,
  });

  @override
  List<Object?> get props => [
    id, title, description, imageUrl, category, isFeatured, rating,
  ];

  ContentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    bool? isFeatured,
    double? rating,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isFeatured: isFeatured ?? this.isFeatured,
      rating: rating ?? this.rating,
    );
  }
}
```

## UI Pattern (Reference: `home_page.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/feature/feature_bloc.dart';
import '../blocs/feature/feature_event.dart';
import '../blocs/feature/feature_state.dart';

class FeaturePage extends StatefulWidget {
  const FeaturePage({super.key});

  @override
  State<FeaturePage> createState() => _FeaturePageState();
}

class _FeaturePageState extends State<FeaturePage> {
  @override
  void initState() {
    super.initState();
    context.read<FeatureBloc>().add(const LoadFeatureData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Name'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: BlocBuilder<FeatureBloc, FeatureState>(
        builder: (context, state) {
          if (state is FeatureLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FeatureLoaded) {
            return _buildContent(state);
          } else if (state is FeatureError) {
            return _buildError(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(FeatureLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FeatureBloc>().add(const RefreshFeatureData());
      },
      child: ListView.builder(
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return ListTile(
            title: Text(item.title),
            subtitle: Text(item.description),
            onTap: () {
              // Navigate to details
              Navigator.pushNamed(
                context,
                '/details',
                arguments: {'contentId': item.id},
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $message'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<FeatureBloc>().add(const LoadFeatureData());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

## Key Rules for POC

1. **File Structure**: Follow the established `blocs/feature_name/` pattern
2. **Naming**: Use descriptive names ending with Event/State/Bloc/Page/Model
3. **Equatable**: Always extend Equatable for events, states, and models
4. **Error Handling**: Include try-catch in all async BLoC methods
5. **UI Separation**: Use BlocBuilder to separate UI from business logic
6. **Repository Injection**: Pass repository through BLoC constructor
