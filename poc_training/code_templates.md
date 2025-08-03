# Flutter BLoC Code Templates

Use these exact templates when generating new features. DO NOT deviate from these patterns.

## New Feature Generation Rules

1. ALWAYS create these 4 files in this order:
   - lib/blocs/feature_name/feature_name_event.dart
   - lib/blocs/feature_name/feature_name_state.dart  
   - lib/blocs/feature_name/feature_name_bloc.dart
   - lib/pages/feature_name_page.dart

2. ALWAYS replace "feature_name" and "FeatureName" with actual feature name

## Template 1: Event File
```dart
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

class UpdateFeatureNameItem extends FeatureNameEvent {
  final String itemId;
  const UpdateFeatureNameItem(this.itemId);
  @override
  List<Object?> get props => [itemId];
}
```

## Template 2: State File  
```dart
import 'package:equatable/equatable.dart';
import '../../models/content_model.dart';

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
  final List<ContentModel> data;
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

## Template 3: BLoC File
```dart
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
      final data = await repository.getFeaturedContent();
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
    try {
      // Add your update logic here
    } catch (error) {
      emit(FeatureNameError(message: error.toString()));
    }
  }
}
```

## Template 4: Page File
```dart
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
        title: const Text(
          'Feature Name',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black87,
        elevation: 0,
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

## Template 5: Movie Listing Design Pattern

**REQUIREMENT**: All movie/content listings MUST use the standardized horizontal scrolling card design with category headers and "See All" navigation.

### Standard Category Section Template:
```dart
Widget _build{CategoryName}Section(String category, List<ContentModel> categoryContent) {
  if (categoryContent.isEmpty) return const SizedBox.shrink();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$category Movies',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryPage(
                      selectedCategory: category,
                    ),
                  ),
                );
                _loadFeaturedContent();
              },
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categoryContent.length,
          itemBuilder: (context, index) {
            final item = categoryContent[index];
            return GestureDetector(
              onTap: () => _navigateToDetails(item),
              child: Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Image.network(
                          item.imageUrl,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              width: 150,
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.movie,
                                color: Colors.white54,
                                size: 48,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.rating.toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}
```

**DESIGN RULES**:
- Method name: `_build{CategoryName}Section` (e.g., `_buildComedySection`, `_buildActionSection`)
- Parameters: `String category, List<ContentModel> categoryContent`
- Height: Exactly `220` pixels for the ListView
- Item width: Exactly `150` pixels
- Image dimensions: `150x150` pixels
- Include star rating display with amber star icon
- Include shadow on image container with `Colors.black.withValues(alpha: 0.3)`
- Include "See All" navigation link in red color
- Handle empty content with `SizedBox.shrink()`
- Use horizontal scrolling ListView
- Include proper error handling for network images

## Integration Rules

ALWAYS add to main.dart MultiBlocProvider:
```dart
BlocProvider(
  create: (context) => FeatureNameBloc(
    repository: DummyContentRepository(),
  ),
),
```

ALWAYS add route if using named navigation:
```dart
'/feature_name': (context) => const FeatureNamePage(),
```

## Generation Checklist

When creating new feature, verify:
- [ ] Created blocs/feature_name/ directory
- [ ] All 4 files created with correct names
- [ ] All classes extend Equatable  
- [ ] All async methods have try-catch
- [ ] All states handled in UI
- [ ] Added to MultiBlocProvider in main.dart
- [ ] Movie listings use `_build{CategoryName}Section` design pattern
- [ ] Navigation includes "See All" links to category pages
- [ ] Error handling includes fallback icons for failed image loads
