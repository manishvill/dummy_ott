# LLM Training Summary and Quick Reference Guide

## Overview
This document serves as a comprehensive summary and quick reference for training an LLM to generate proper Flutter code following BLoC pattern and best practices.

## File Structure Quick Reference

### Essential Directory Structure
```
lib/
├── main.dart                    # App entry point with BlocProvider setup
├── blocs/                       # Business logic components
│   └── feature_name/           # Each feature gets its own folder
│       ├── feature_bloc.dart   # Main BLoC class
│       ├── feature_event.dart  # Event definitions
│       └── feature_state.dart  # State definitions
├── models/                      # Data models with Equatable
├── pages/                       # UI screens (StatelessWidget preferred)
├── widgets/                     # Reusable UI components
├── repository/                  # Data access layer (abstract + implementation)
├── services/                    # External services (API, storage, etc.)
└── utils/                       # Utilities, constants, helpers
```

## Code Generation Checklist

### ✅ Before Writing Any Code
1. **Identify the feature** - What functionality are you implementing?
2. **Determine data flow** - What data needs to be managed?
3. **Plan the architecture** - Which patterns apply?
4. **Check existing structure** - What files already exist?

### ✅ Model Creation Checklist
```dart
// ✅ Must have:
class ExampleModel extends Equatable {
  // ✅ All fields should be final
  final String id;
  final String name;
  
  // ✅ Required fields in constructor
  const ExampleModel({
    required this.id,
    required this.name,
  });
  
  // ✅ Equatable props implementation
  @override
  List<Object?> get props => [id, name];
  
  // ✅ copyWith method for immutable updates
  ExampleModel copyWith({String? id, String? name}) {
    return ExampleModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
  
  // ✅ JSON serialization if needed
  factory ExampleModel.fromJson(Map<String, dynamic> json) { /* */ }
  Map<String, dynamic> toJson() { /* */ }
}
```

### ✅ Repository Creation Checklist
```dart
// ✅ Abstract base class first
abstract class ExampleRepository {
  Future<List<ExampleModel>> getItems();
  Future<ExampleModel?> getItemById(String id);
  Future<void> saveItem(ExampleModel item);
}

// ✅ Concrete implementation
class ApiExampleRepository implements ExampleRepository {
  final ApiService _apiService;
  
  ApiExampleRepository(this._apiService);
  
  @override
  Future<List<ExampleModel>> getItems() async {
    try {
      // ✅ Proper error handling
      final response = await _apiService.get('/items');
      // ✅ Data transformation
      return response.data.map((json) => ExampleModel.fromJson(json)).toList();
    } catch (e) {
      // ✅ Custom exceptions
      throw ExampleRepositoryException('Failed to load items: $e');
    }
  }
}
```

### ✅ BLoC Implementation Checklist

#### Events (feature_event.dart)
```dart
// ✅ Base event class
abstract class ExampleEvent extends Equatable {
  const ExampleEvent();
  @override
  List<Object?> get props => [];
}

// ✅ Specific events with descriptive names
class LoadExampleData extends ExampleEvent {
  const LoadExampleData();
}

class UpdateExampleItem extends ExampleEvent {
  final String itemId;
  final Map<String, dynamic> updates;
  
  const UpdateExampleItem({required this.itemId, required this.updates});
  
  @override
  List<Object?> get props => [itemId, updates];
}
```

#### States (feature_state.dart)
```dart
// ✅ Base state class
abstract class ExampleState extends Equatable {
  const ExampleState();
  @override
  List<Object?> get props => [];
}

// ✅ Standard state types
class ExampleInitial extends ExampleState {
  const ExampleInitial();
}

class ExampleLoading extends ExampleState {
  const ExampleLoading();
}

class ExampleLoaded extends ExampleState {
  final List<ExampleModel> items;
  
  const ExampleLoaded({required this.items});
  
  @override
  List<Object?> get props => [items];
}

class ExampleError extends ExampleState {
  final String message;
  final bool canRetry;
  
  const ExampleError({required this.message, this.canRetry = true});
  
  @override
  List<Object?> get props => [message, canRetry];
}
```

#### BLoC (feature_bloc.dart)
```dart
class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  final ExampleRepository repository;
  
  ExampleBloc({required this.repository}) : super(const ExampleInitial()) {
    // ✅ Register event handlers
    on<LoadExampleData>(_onLoadExampleData);
    on<UpdateExampleItem>(_onUpdateExampleItem);
  }
  
  // ✅ Private event handlers with proper error handling
  Future<void> _onLoadExampleData(
    LoadExampleData event,
    Emitter<ExampleState> emit,
  ) async {
    try {
      emit(const ExampleLoading());
      final items = await repository.getItems();
      emit(ExampleLoaded(items: items));
    } catch (e) {
      emit(ExampleError(message: e.toString()));
    }
  }
}
```

### ✅ UI Implementation Checklist

#### Pages
```dart
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: BlocBuilder<ExampleBloc, ExampleState>(
        builder: (context, state) {
          // ✅ Handle all state types
          if (state is ExampleLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExampleLoaded) {
            return _buildContent(state.items);
          } else if (state is ExampleError) {
            return _buildError(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
  
  // ✅ Extract methods for complex widgets
  Widget _buildContent(List<ExampleModel> items) { /* */ }
  Widget _buildError(String message) { /* */ }
}
```

## Common Patterns and Anti-Patterns

### ✅ DO - Good Patterns
```dart
// ✅ Use const constructors
const Text('Hello');
const SizedBox(height: 16);

// ✅ Use proper naming
class HomeBloc extends Bloc<HomeEvent, HomeState> {}
class LoadHomeContent extends HomeEvent {}
class HomeLoaded extends HomeState {}

// ✅ Use Equatable for value comparison
class User extends Equatable {
  final String id;
  final String name;
  
  @override
  List<Object?> get props => [id, name];
}

// ✅ Use copyWith for immutable updates
final updatedUser = user.copyWith(name: 'New Name');

// ✅ Proper error handling
try {
  final data = await repository.getData();
  emit(LoadedState(data: data));
} catch (e) {
  emit(ErrorState(message: e.toString()));
}

// ✅ Use BlocBuilder for UI updates
BlocBuilder<ExampleBloc, ExampleState>(
  builder: (context, state) {
    // Handle state changes
  },
)
```

### ❌ DON'T - Anti-Patterns
```dart
// ❌ Don't use mutable data
class User {
  String name; // Should be final
  User(this.name);
}

// ❌ Don't mix UI and business logic
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ❌ Don't make API calls directly in widgets
    final data = await apiService.getData();
    return Text(data.toString());
  }
}

// ❌ Don't ignore error handling
Future<void> loadData() async {
  final data = await repository.getData(); // What if this fails?
  emit(LoadedState(data: data));
}

// ❌ Don't use setState in BLoC pattern
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Item> items = [];
  
  void loadItems() async {
    final newItems = await repository.getItems();
    setState(() { // ❌ Use BLoC instead
      items = newItems;
    });
  }
}
```

## Quick Code Templates

### New Feature Template
```bash
# 1. Create directory structure
lib/blocs/feature_name/
├── feature_name_bloc.dart
├── feature_name_event.dart
└── feature_name_state.dart

# 2. Create model if needed
lib/models/feature_name_model.dart

# 3. Create repository
lib/repository/feature_name_repository.dart

# 4. Create page
lib/pages/feature_name_page.dart
```

### Standard Import Order
```dart
// 1. Dart core libraries
import 'dart:async';
import 'dart:convert';

// 2. Flutter libraries  
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 4. Internal imports (relative paths)
import '../models/example_model.dart';
import '../repository/example_repository.dart';
import 'example_event.dart';
import 'example_state.dart';
```

## Decision Tree for Code Generation

### When generating new code, ask:

1. **What type of component am I creating?**
   - Model → Use Equatable, final fields, copyWith
   - Repository → Abstract base + concrete implementation
   - BLoC → Event/State/BLoC trilogy
   - UI → StatelessWidget with BlocBuilder
   - Widget → Reusable StatelessWidget

2. **What data does this handle?**
   - Simple data → Model class
   - API data → Repository + Model
   - User interactions → Events
   - App state → States
   - UI state → BlocBuilder/BlocListener

3. **What dependencies exist?**
   - Repository needs models
   - BLoC needs repository and events/states
   - Pages need BLoC
   - Widgets need models for data display

4. **What error cases exist?**
   - Network failures → NetworkException
   - Data parsing → FormatException  
   - Business logic → Custom exceptions
   - UI errors → Error states + error widgets

## Key Principles Summary

1. **Separation of Concerns**: UI, business logic, and data access are separate
2. **Immutability**: Use final fields and copyWith methods
3. **Predictability**: State changes only through events
4. **Testability**: Each component can be tested independently
5. **Performance**: Use const constructors and efficient widgets
6. **Error Handling**: Every async operation has error handling
7. **Consistency**: Follow naming conventions and patterns
8. **Maintainability**: Clear structure and readable code

Use this guide as a checklist when generating Flutter code to ensure consistency and best practices.
