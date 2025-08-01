# Code Generation Templates - POC Reference

## Quick Templates Based on Your Codebase

### 1. New Feature Implementation Steps

#### Step 1: Create BLoC Files
```bash
# Create directory: lib/blocs/feature_name/
# Files needed:
- feature_name_bloc.dart
- feature_name_event.dart  
- feature_name_state.dart
```

#### Step 2: Event Template
```dart
// lib/blocs/feature_name/feature_name_event.dart
import 'package:equatable/equatable.dart';

abstract class FeatureNameEvent extends Equatable {
  const FeatureNameEvent();
  @override
  List<Object?> get props => [];
}

class LoadFeatureNameData extends FeatureNameEvent {
  const LoadFeatureNameData();
}

class RefreshFeatureNameData extends FeatureNameEvent {
  const RefreshFeatureNameData();
}

// Add parameter events as needed
class UpdateFeatureNameItem extends FeatureNameEvent {
  final String itemId;
  const UpdateFeatureNameItem(this.itemId);
  @override
  List<Object?> get props => [itemId];
}
```

#### Step 3: State Template
```dart
// lib/blocs/feature_name/feature_name_state.dart
import 'package:equatable/equatable.dart';
import '../../models/content_model.dart'; // Use existing models

abstract class FeatureNameState extends Equatable {
  const FeatureNameState();
  @override
  List<Object?> get props => [];
}

class FeatureNameInitial extends FeatureNameState {
  const FeatureNameInitial();
}

class FeatureNameLoading extends FeatureNameState {
  const FeatureNameLoading();
}

class FeatureNameLoaded extends FeatureNameState {
  final List<ContentModel> data; // Reuse existing ContentModel
  
  const FeatureNameLoaded({required this.data});
  
  @override
  List<Object?> get props => [data];
}

class FeatureNameError extends FeatureNameState {
  final String message;
  
  const FeatureNameError({required this.message});
  
  @override
  List<Object?> get props => [message];
}
```

#### Step 4: BLoC Template
```dart
// lib/blocs/feature_name/feature_name_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/dummy_content_repository.dart';
import 'feature_name_event.dart';
import 'feature_name_state.dart';

class FeatureNameBloc extends Bloc<FeatureNameEvent, FeatureNameState> {
  final DummyContentRepository repository;

  FeatureNameBloc({required this.repository}) : super(const FeatureNameInitial()) {
    on<LoadFeatureNameData>(_onLoadFeatureNameData);
    on<RefreshFeatureNameData>(_onRefreshFeatureNameData);
    on<UpdateFeatureNameItem>(_onUpdateFeatureNameItem);
  }

  Future<void> _onLoadFeatureNameData(
    LoadFeatureNameData event,
    Emitter<FeatureNameState> emit,
  ) async {
    try {
      emit(const FeatureNameLoading());
      
      // Use existing repository methods
      final data = await repository.getFeaturedContent(); // or appropriate method
      
      emit(FeatureNameLoaded(data: data));
    } catch (error) {
      emit(FeatureNameError(message: error.toString()));
    }
  }

  Future<void> _onRefreshFeatureNameData(
    RefreshFeatureNameData event,
    Emitter<FeatureNameState> emit,
  ) async {
    try {
      final data = await repository.getFeaturedContent();
      emit(FeatureNameLoaded(data: data));
    } catch (error) {
      emit(FeatureNameError(message: error.toString()));
    }
  }

  Future<void> _onUpdateFeatureNameItem(
    UpdateFeatureNameItem event,
    Emitter<FeatureNameState> emit,
  ) async {
    // Handle specific updates
    try {
      // Implementation based on your needs
    } catch (error) {
      emit(FeatureNameError(message: error.toString()));
    }
  }
}
```

#### Step 5: Page Template
```dart
// lib/pages/feature_name_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/feature_name/feature_name_bloc.dart';
import '../blocs/feature_name/feature_name_event.dart';
import '../blocs/feature_name/feature_name_state.dart';
import '../models/content_model.dart';

class FeatureNamePage extends StatefulWidget {
  const FeatureNamePage({super.key});

  @override
  State<FeatureNamePage> createState() => _FeatureNamePageState();
}

class _FeatureNamePageState extends State<FeatureNamePage> {
  @override
  void initState() {
    super.initState();
    context.read<FeatureNameBloc>().add(const LoadFeatureNameData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Name'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: BlocBuilder<FeatureNameBloc, FeatureNameState>(
        builder: (context, state) {
          if (state is FeatureNameLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FeatureNameLoaded) {
            return _buildContent(state.data);
          } else if (state is FeatureNameError) {
            return _buildError(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(List<ContentModel> data) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FeatureNameBloc>().add(const RefreshFeatureNameData());
      },
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: Image.network(
                item.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
              title: Text(item.title),
              subtitle: Text(item.description),
              trailing: Text(item.category),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/details',
                  arguments: {'contentId': item.id},
                );
              },
            ),
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
          Text(
            'Error: $message',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<FeatureNameBloc>().add(const LoadFeatureNameData());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

## Integration in main.dart

```dart
// Add to your existing MultiBlocProvider in main.dart
BlocProvider(
  create: (context) => FeatureNameBloc(
    repository: DummyContentRepository(), // Use existing repository
  ),
),
```

## Navigation Setup

```dart
// Add to your routes (if using named routes)
'/feature_name': (context) => const FeatureNamePage(),
```

## Quick Checklist for New Features

✅ **File Structure**
- [ ] Created `lib/blocs/feature_name/` directory
- [ ] Added event, state, bloc files
- [ ] Created page file

✅ **Implementation**
- [ ] Events extend Equatable
- [ ] States extend Equatable  
- [ ] BLoC uses existing repository
- [ ] Error handling in all async methods
- [ ] UI uses BlocBuilder

✅ **Integration**
- [ ] Added BlocProvider to main.dart
- [ ] Added navigation route
- [ ] Tested loading, success, and error states

This template reuses your existing `ContentModel` and `DummyContentRepository`, ensuring consistency with your current codebase.
