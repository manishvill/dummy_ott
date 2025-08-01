# Complete Example Implementation Guide for LLM Training

## Full Feature Implementation Example

This guide demonstrates implementing a complete "Favorites" feature following all established patterns and best practices.

### 1. Model Implementation

#### favorites_model.dart
```dart
import 'package:equatable/equatable.dart';

class FavoritesModel extends Equatable {
  final String userId;
  final List<String> contentIds;
  final DateTime lastUpdated;

  const FavoritesModel({
    required this.userId,
    required this.contentIds,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [userId, contentIds, lastUpdated];

  FavoritesModel copyWith({
    String? userId,
    List<String>? contentIds,
    DateTime? lastUpdated,
  }) {
    return FavoritesModel(
      userId: userId ?? this.userId,
      contentIds: contentIds ?? List.from(this.contentIds),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Add content to favorites
  FavoritesModel addContent(String contentId) {
    if (contentIds.contains(contentId)) return this;
    
    return copyWith(
      contentIds: [...contentIds, contentId],
      lastUpdated: DateTime.now(),
    );
  }

  // Remove content from favorites
  FavoritesModel removeContent(String contentId) {
    if (!contentIds.contains(contentId)) return this;
    
    final updatedIds = contentIds.where((id) => id != contentId).toList();
    return copyWith(
      contentIds: updatedIds,
      lastUpdated: DateTime.now(),
    );
  }

  // Check if content is favorited
  bool isFavorite(String contentId) => contentIds.contains(contentId);

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'contentIds': contentIds,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory FavoritesModel.fromJson(Map<String, dynamic> json) {
    return FavoritesModel(
      userId: json['userId'] as String,
      contentIds: List<String>.from(json['contentIds'] as List),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  // Empty favorites for new users
  factory FavoritesModel.empty(String userId) {
    return FavoritesModel(
      userId: userId,
      contentIds: const [],
      lastUpdated: DateTime.now(),
    );
  }
}
```

### 2. Repository Implementation

#### favorites_repository.dart
```dart
import '../models/favorites_model.dart';

abstract class FavoritesRepository {
  Future<FavoritesModel> getUserFavorites(String userId);
  Future<void> saveFavorites(FavoritesModel favorites);
  Future<void> addToFavorites(String userId, String contentId);
  Future<void> removeFromFavorites(String userId, String contentId);
  Future<bool> isFavorite(String userId, String contentId);
}

class LocalFavoritesRepository implements FavoritesRepository {
  final LocalStorageService _storageService;
  final Map<String, FavoritesModel> _cache = {};

  LocalFavoritesRepository(this._storageService);

  @override
  Future<FavoritesModel> getUserFavorites(String userId) async {
    try {
      // Check cache first
      if (_cache.containsKey(userId)) {
        return _cache[userId]!;
      }

      // Load from storage
      final data = await _storageService.getString('favorites_$userId');
      
      if (data != null) {
        final favorites = FavoritesModel.fromJson(jsonDecode(data));
        _cache[userId] = favorites;
        return favorites;
      }

      // Create empty favorites for new user
      final emptyFavorites = FavoritesModel.empty(userId);
      _cache[userId] = emptyFavorites;
      return emptyFavorites;
    } catch (e) {
      throw FavoritesRepositoryException(
        'Failed to load favorites: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveFavorites(FavoritesModel favorites) async {
    try {
      final jsonData = jsonEncode(favorites.toJson());
      await _storageService.setString('favorites_${favorites.userId}', jsonData);
      _cache[favorites.userId] = favorites;
    } catch (e) {
      throw FavoritesRepositoryException(
        'Failed to save favorites: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> addToFavorites(String userId, String contentId) async {
    try {
      final currentFavorites = await getUserFavorites(userId);
      final updatedFavorites = currentFavorites.addContent(contentId);
      await saveFavorites(updatedFavorites);
    } catch (e) {
      throw FavoritesRepositoryException(
        'Failed to add to favorites: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> removeFromFavorites(String userId, String contentId) async {
    try {
      final currentFavorites = await getUserFavorites(userId);
      final updatedFavorites = currentFavorites.removeContent(contentId);
      await saveFavorites(updatedFavorites);
    } catch (e) {
      throw FavoritesRepositoryException(
        'Failed to remove from favorites: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> isFavorite(String userId, String contentId) async {
    try {
      final favorites = await getUserFavorites(userId);
      return favorites.isFavorite(contentId);
    } catch (e) {
      return false; // Default to false on error
    }
  }
}

class FavoritesRepositoryException implements Exception {
  final String message;
  final Exception? originalException;

  const FavoritesRepositoryException(
    this.message, {
    this.originalException,
  });

  @override
  String toString() => 'FavoritesRepositoryException: $message';
}
```

### 3. BLoC Implementation

#### favorites_event.dart
```dart
import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserFavorites extends FavoritesEvent {
  final String userId;

  const LoadUserFavorites({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AddToFavorites extends FavoritesEvent {
  final String userId;
  final String contentId;

  const AddToFavorites({
    required this.userId,
    required this.contentId,
  });

  @override
  List<Object?> get props => [userId, contentId];
}

class RemoveFromFavorites extends FavoritesEvent {
  final String userId;
  final String contentId;

  const RemoveFromFavorites({
    required this.userId,
    required this.contentId,
  });

  @override
  List<Object?> get props => [userId, contentId];
}

class ToggleFavorite extends FavoritesEvent {
  final String userId;
  final String contentId;

  const ToggleFavorite({
    required this.userId,
    required this.contentId,
  });

  @override
  List<Object?> get props => [userId, contentId];
}

class RefreshFavorites extends FavoritesEvent {
  final String userId;

  const RefreshFavorites({required this.userId});

  @override
  List<Object?> get props => [userId];
}
```

#### favorites_state.dart
```dart
import 'package:equatable/equatable.dart';
import '../../models/favorites_model.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final FavoritesModel favorites;

  const FavoritesLoaded({required this.favorites});

  @override
  List<Object?> get props => [favorites];

  FavoritesLoaded copyWith({
    FavoritesModel? favorites,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
    );
  }
}

class FavoritesError extends FavoritesState {
  final String message;
  final bool canRetry;

  const FavoritesError({
    required this.message,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, canRetry];
}

class FavoritesUpdating extends FavoritesState {
  final FavoritesModel currentFavorites;
  final String contentId;
  final bool isAdding;

  const FavoritesUpdating({
    required this.currentFavorites,
    required this.contentId,
    required this.isAdding,
  });

  @override
  List<Object?> get props => [currentFavorites, contentId, isAdding];
}
```

#### favorites_bloc.dart
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/favorites_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository repository;

  FavoritesBloc({required this.repository}) : super(const FavoritesInitial()) {
    on<LoadUserFavorites>(_onLoadUserFavorites);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
    on<RefreshFavorites>(_onRefreshFavorites);
  }

  Future<void> _onLoadUserFavorites(
    LoadUserFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      emit(const FavoritesLoading());
      
      final favorites = await repository.getUserFavorites(event.userId);
      
      emit(FavoritesLoaded(favorites: favorites));
    } catch (e) {
      emit(FavoritesError(
        message: 'Failed to load favorites: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAddToFavorites(
    AddToFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is FavoritesLoaded) {
      try {
        // Show optimistic update
        emit(FavoritesUpdating(
          currentFavorites: currentState.favorites,
          contentId: event.contentId,
          isAdding: true,
        ));

        await repository.addToFavorites(event.userId, event.contentId);
        
        // Reload favorites to get updated state
        final updatedFavorites = await repository.getUserFavorites(event.userId);
        
        emit(FavoritesLoaded(favorites: updatedFavorites));
      } catch (e) {
        // Revert to previous state on error
        emit(currentState);
        emit(FavoritesError(
          message: 'Failed to add to favorites: ${e.toString()}',
        ));
        
        // Return to loaded state after showing error
        emit(currentState);
      }
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is FavoritesLoaded) {
      try {
        // Show optimistic update
        emit(FavoritesUpdating(
          currentFavorites: currentState.favorites,
          contentId: event.contentId,
          isAdding: false,
        ));

        await repository.removeFromFavorites(event.userId, event.contentId);
        
        // Reload favorites to get updated state
        final updatedFavorites = await repository.getUserFavorites(event.userId);
        
        emit(FavoritesLoaded(favorites: updatedFavorites));
      } catch (e) {
        // Revert to previous state on error
        emit(currentState);
        emit(FavoritesError(
          message: 'Failed to remove from favorites: ${e.toString()}',
        ));
        
        // Return to loaded state after showing error
        emit(currentState);
      }
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is FavoritesLoaded) {
      final isFavorite = currentState.favorites.isFavorite(event.contentId);
      
      if (isFavorite) {
        add(RemoveFromFavorites(
          userId: event.userId,
          contentId: event.contentId,
        ));
      } else {
        add(AddToFavorites(
          userId: event.userId,
          contentId: event.contentId,
        ));
      }
    }
  }

  Future<void> _onRefreshFavorites(
    RefreshFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final favorites = await repository.getUserFavorites(event.userId);
      emit(FavoritesLoaded(favorites: favorites));
    } catch (e) {
      emit(FavoritesError(
        message: 'Failed to refresh favorites: ${e.toString()}',
      ));
    }
  }
}
```

### 4. UI Implementation

#### favorites_page.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/favorites/favorites_bloc.dart';
import '../blocs/favorites/favorites_event.dart';
import '../blocs/favorites/favorites_state.dart';
import '../blocs/content/content_bloc.dart';
import '../blocs/content/content_event.dart';
import '../blocs/content/content_state.dart';
import '../widgets/content_card.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';

class FavoritesPage extends StatefulWidget {
  final String userId;

  const FavoritesPage({super.key, required this.userId});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(LoadUserFavorites(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FavoritesBloc>().add(
                RefreshFavorites(userId: widget.userId),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<FavoritesBloc, FavoritesState>(
        listener: (context, state) {
          if (state is FavoritesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: state.canRetry
                    ? SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: () {
                          context.read<FavoritesBloc>().add(
                            LoadUserFavorites(userId: widget.userId),
                          );
                        },
                      )
                    : null,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const LoadingIndicator(message: 'Loading favorites...');
          } else if (state is FavoritesLoaded) {
            return _buildFavoritesList(state);
          } else if (state is FavoritesUpdating) {
            return _buildFavoritesList(
              FavoritesLoaded(favorites: state.currentFavorites),
              isUpdating: true,
            );
          } else if (state is FavoritesError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: state.canRetry
                  ? () {
                      context.read<FavoritesBloc>().add(
                        LoadUserFavorites(userId: widget.userId),
                      );
                    }
                  : null,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFavoritesList(FavoritesLoaded state, {bool isUpdating = false}) {
    if (state.favorites.contentIds.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FavoritesBloc>().add(
          RefreshFavorites(userId: widget.userId),
        );
      },
      child: Stack(
        children: [
          _buildContentGrid(state.favorites.contentIds),
          if (isUpdating)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                child: const LinearProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentGrid(List<String> contentIds) {
    return BlocBuilder<ContentBloc, ContentState>(
      builder: (context, contentState) {
        if (contentState is ContentLoaded) {
          final favoriteContent = contentState.allContent
              .where((content) => contentIds.contains(content.id))
              .toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: favoriteContent.length,
            itemBuilder: (context, index) {
              final content = favoriteContent[index];
              return ContentCard(
                content: content,
                showFavoriteButton: true,
                onFavoriteToggle: () {
                  context.read<FavoritesBloc>().add(
                    ToggleFavorite(
                      userId: widget.userId,
                      contentId: content.id,
                    ),
                  );
                },
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/details',
                    arguments: {'contentId': content.id},
                  );
                },
              );
            },
          );
        }

        return const LoadingIndicator(message: 'Loading content...');
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Favorites Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding content to your favorites by tapping the heart icon',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('Browse Content'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### favorite_button_widget.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/favorites/favorites_bloc.dart';
import '../blocs/favorites/favorites_event.dart';
import '../blocs/favorites/favorites_state.dart';

class FavoriteButton extends StatelessWidget {
  final String contentId;
  final String userId;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const FavoriteButton({
    super.key,
    required this.contentId,
    required this.userId,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        bool isFavorite = false;
        bool isUpdating = false;

        if (state is FavoritesLoaded) {
          isFavorite = state.favorites.isFavorite(contentId);
        } else if (state is FavoritesUpdating) {
          isFavorite = state.currentFavorites.isFavorite(contentId);
          isUpdating = state.contentId == contentId;
        }

        return GestureDetector(
          onTap: isUpdating
              ? null
              : () {
                  context.read<FavoritesBloc>().add(
                    ToggleFavorite(
                      userId: userId,
                      contentId: contentId,
                    ),
                  );
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: isUpdating
                ? SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        activeColor ?? Colors.red,
                      ),
                    ),
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isFavorite),
                      size: size,
                      color: isFavorite
                          ? (activeColor ?? Colors.red)
                          : (inactiveColor ?? Colors.white),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
```

### 5. Integration Example

#### main.dart integration
```dart
class OTTApp extends StatelessWidget {
  const OTTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ContentBloc(
            repository: context.read<ContentRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => FavoritesBloc(
            repository: context.read<FavoritesRepository>(),
          ),
        ),
        // Other BLoCs...
      ],
      child: MaterialApp(
        title: 'OTT Stream',
        theme: AppTheme.lightTheme,
        routes: {
          '/': (context) => const HomePage(),
          '/favorites': (context) {
            final userId = getCurrentUserId(); // Get from auth service
            return FavoritesPage(userId: userId);
          },
          '/details': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return DetailsPage(contentId: args['contentId']);
          },
        },
      ),
    );
  }
}
```

This complete example demonstrates proper implementation following all established patterns: BLoC architecture, proper error handling, UI best practices, state management, and performance considerations.
