# Flutter Error Handling and Testing Guidelines for LLM Training

## Error Handling Patterns

### Repository Level Error Handling
```dart
// Custom exception classes
class ContentRepositoryException implements Exception {
  final String message;
  final String? code;
  final Exception? originalException;

  const ContentRepositoryException(
    this.message, {
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'ContentRepositoryException: $message';
}

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException(this.message, {this.statusCode});

  @override
  String toString() => 'NetworkException: $message (${statusCode ?? 'Unknown'})';
}

// Repository with proper error handling
class ApiContentRepository implements ContentRepository {
  final ApiService _apiService;

  ApiContentRepository(this._apiService);

  @override
  Future<List<ContentModel>> getContent() async {
    try {
      final response = await _apiService.get('/content');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ContentModel.fromJson(json)).toList();
      } else {
        throw NetworkException(
          'Failed to fetch content',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const NetworkException('No internet connection');
    } on TimeoutException {
      throw const NetworkException('Request timeout');
    } on FormatException catch (e) {
      throw ContentRepositoryException(
        'Invalid data format',
        originalException: e,
      );
    } catch (e) {
      throw ContentRepositoryException(
        'Unexpected error occurred',
        originalException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<ContentModel?> getContentById(String id) async {
    try {
      final response = await _apiService.get('/content/$id');
      
      if (response.statusCode == 404) {
        return null; // Content not found
      }
      
      if (response.statusCode == 200) {
        return ContentModel.fromJson(response.data);
      }
      
      throw NetworkException(
        'Failed to fetch content details',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is NetworkException || e is ContentRepositoryException) {
        rethrow;
      }
      throw ContentRepositoryException(
        'Failed to load content details',
        originalException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
```

### BLoC Level Error Handling
```dart
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ContentRepository repository;

  HomeBloc({required this.repository}) : super(const HomeInitial()) {
    on<LoadHomeContent>(_onLoadHomeContent);
    on<RefreshHomeContent>(_onRefreshHomeContent);
  }

  Future<void> _onLoadHomeContent(
    LoadHomeContent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(const HomeLoading());

      final featuredContent = await repository.getFeaturedContent();
      final categories = await repository.getCategories();
      
      // Get content for each category
      final Map<String, List<ContentModel>> categoryContent = {};
      for (final category in categories) {
        try {
          categoryContent[category] = await repository.getContentByCategory(category);
        } catch (e) {
          // Log error but continue with other categories
          print('Failed to load $category content: $e');
          categoryContent[category] = [];
        }
      }

      emit(HomeLoaded(
        featuredContent: featuredContent,
        categoryContent: categoryContent,
        categories: categories,
      ));
    } on NetworkException catch (e) {
      emit(HomeError(
        message: 'Network error: ${e.message}',
        type: ErrorType.network,
        canRetry: true,
      ));
    } on ContentRepositoryException catch (e) {
      emit(HomeError(
        message: 'Failed to load content: ${e.message}',
        type: ErrorType.repository,
        canRetry: true,
      ));
    } catch (e) {
      emit(HomeError(
        message: 'An unexpected error occurred',
        type: ErrorType.unknown,
        canRetry: true,
      ));
    }
  }

  Future<void> _onRefreshHomeContent(
    RefreshHomeContent event,
    Emitter<HomeState> emit,
  ) async {
    // For refresh, don't show loading state, just update data
    try {
      final featuredContent = await repository.getFeaturedContent();
      final categories = await repository.getCategories();
      
      final Map<String, List<ContentModel>> categoryContent = {};
      for (final category in categories) {
        categoryContent[category] = await repository.getContentByCategory(category);
      }

      emit(HomeLoaded(
        featuredContent: featuredContent,
        categoryContent: categoryContent,
        categories: categories,
      ));
    } catch (e) {
      // For refresh errors, keep existing data if available
      if (state is HomeLoaded) {
        // Keep current state but show snackbar or toast
        emit(HomeRefreshError(
          currentState: state as HomeLoaded,
          errorMessage: 'Failed to refresh content',
        ));
      } else {
        // No existing data, show error state
        add(const LoadHomeContent());
      }
    }
  }
}

// Enhanced error state
enum ErrorType { network, repository, validation, unknown }

class HomeError extends HomeState {
  final String message;
  final ErrorType type;
  final bool canRetry;
  final String? technicalDetails;

  const HomeError({
    required this.message,
    required this.type,
    this.canRetry = true,
    this.technicalDetails,
  });

  @override
  List<Object?> get props => [message, type, canRetry, technicalDetails];
}

class HomeRefreshError extends HomeState {
  final HomeLoaded currentState;
  final String errorMessage;

  const HomeRefreshError({
    required this.currentState,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [currentState, errorMessage];
}
```

### UI Level Error Handling
```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTT Stream')),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          // Handle side effects
          if (state is HomeRefreshError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () {
                    context.read<HomeBloc>().add(const RefreshHomeContent());
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return const _LoadingView();
          } else if (state is HomeLoaded) {
            return _ContentView(state: state);
          } else if (state is HomeError) {
            return _ErrorView(error: state);
          } else if (state is HomeRefreshError) {
            return _ContentView(state: state.currentState);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final HomeError error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(error.type),
              size: 64,
              color: _getErrorColor(error.type),
            ),
            const SizedBox(height: 16),
            Text(
              _getErrorTitle(error.type),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _getErrorColor(error.type),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (error.technicalDetails != null) ...[
              const SizedBox(height: 8),
              ExpansionTile(
                title: const Text('Technical Details'),
                children: [
                  Text(
                    error.technicalDetails!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            if (error.canRetry) ...[
              ElevatedButton(
                onPressed: () {
                  context.read<HomeBloc>().add(const LoadHomeContent());
                },
                child: const Text('Try Again'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  // Navigate to settings or help
                },
                child: const Text('Get Help'),
              ),
            ] else ...[
              TextButton(
                onPressed: () {
                  // Navigate to support or contact
                },
                child: const Text('Contact Support'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.repository:
        return Icons.storage;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.unknown:
        return Icons.error_outline;
    }
  }

  Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.repository:
        return Colors.blue;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.unknown:
        return Colors.red;
    }
  }

  String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Connection Problem';
      case ErrorType.repository:
        return 'Data Error';
      case ErrorType.validation:
        return 'Invalid Input';
      case ErrorType.unknown:
        return 'Something Went Wrong';
    }
  }
}
```

## Testing Guidelines

### Unit Testing - Repository
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ApiService])
import 'content_repository_test.mocks.dart';

void main() {
  group('ApiContentRepository', () {
    late MockApiService mockApiService;
    late ApiContentRepository repository;

    setUp(() {
      mockApiService = MockApiService();
      repository = ApiContentRepository(mockApiService);
    });

    group('getContent', () {
      test('returns list of content when API call is successful', () async {
        // Arrange
        final mockResponse = ApiResponse(
          statusCode: 200,
          data: [
            {
              'id': '1',
              'title': 'Test Movie',
              'description': 'A test movie',
              'imageUrl': 'https://example.com/image.jpg',
              'category': 'Action',
              'isFeatured': true,
              'rating': 4.5,
            }
          ],
        );
        when(mockApiService.get('/content')).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.getContent();

        // Assert
        expect(result, isA<List<ContentModel>>());
        expect(result.length, 1);
        expect(result.first.title, 'Test Movie');
        verify(mockApiService.get('/content')).called(1);
      });

      test('throws NetworkException when API returns error status', () async {
        // Arrange
        final mockResponse = ApiResponse(statusCode: 500, data: null);
        when(mockApiService.get('/content')).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => repository.getContent(),
          throwsA(isA<NetworkException>()),
        );
      });

      test('throws ContentRepositoryException when data format is invalid', () async {
        // Arrange
        final mockResponse = ApiResponse(
          statusCode: 200,
          data: 'invalid_data', // Should be a list
        );
        when(mockApiService.get('/content')).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => repository.getContent(),
          throwsA(isA<ContentRepositoryException>()),
        );
      });
    });

    group('getContentById', () {
      test('returns content when found', () async {
        // Arrange
        final mockResponse = ApiResponse(
          statusCode: 200,
          data: {
            'id': '1',
            'title': 'Test Movie',
            'description': 'A test movie',
            'imageUrl': 'https://example.com/image.jpg',
            'category': 'Action',
            'isFeatured': true,
            'rating': 4.5,
          },
        );
        when(mockApiService.get('/content/1')).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.getContentById('1');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, '1');
        expect(result.title, 'Test Movie');
      });

      test('returns null when content not found', () async {
        // Arrange
        final mockResponse = ApiResponse(statusCode: 404, data: null);
        when(mockApiService.get('/content/1')).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.getContentById('1');

        // Assert
        expect(result, isNull);
      });
    });
  });
}
```

### BLoC Testing
```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([ContentRepository])
import 'home_bloc_test.mocks.dart';

void main() {
  group('HomeBloc', () {
    late MockContentRepository mockRepository;
    late HomeBloc homeBloc;

    setUp(() {
      mockRepository = MockContentRepository();
      homeBloc = HomeBloc(repository: mockRepository);
    });

    tearDown(() {
      homeBloc.close();
    });

    test('initial state is HomeInitial', () {
      expect(homeBloc.state, equals(const HomeInitial()));
    });

    group('LoadHomeContent', () {
      final mockFeaturedContent = [
        const ContentModel(
          id: '1',
          title: 'Featured Movie',
          description: 'A featured movie',
          imageUrl: 'https://example.com/image.jpg',
          category: 'Action',
          isFeatured: true,
        ),
      ];

      final mockCategories = ['Action', 'Comedy', 'Drama'];

      blocTest<HomeBloc, HomeState>(
        'emits [HomeLoading, HomeLoaded] when LoadHomeContent is successful',
        build: () {
          when(mockRepository.getFeaturedContent())
              .thenAnswer((_) async => mockFeaturedContent);
          when(mockRepository.getCategories())
              .thenAnswer((_) async => mockCategories);
          when(mockRepository.getContentByCategory(any))
              .thenAnswer((_) async => []);
          return homeBloc;
        },
        act: (bloc) => bloc.add(const LoadHomeContent()),
        expect: () => [
          const HomeLoading(),
          HomeLoaded(
            featuredContent: mockFeaturedContent,
            categoryContent: {
              'Action': [],
              'Comedy': [],
              'Drama': [],
            },
            categories: mockCategories,
          ),
        ],
        verify: (_) {
          verify(mockRepository.getFeaturedContent()).called(1);
          verify(mockRepository.getCategories()).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'emits [HomeLoading, HomeError] when LoadHomeContent fails',
        build: () {
          when(mockRepository.getFeaturedContent())
              .thenThrow(const NetworkException('Connection failed'));
          return homeBloc;
        },
        act: (bloc) => bloc.add(const LoadHomeContent()),
        expect: () => [
          const HomeLoading(),
          const HomeError(
            message: 'Network error: Connection failed',
            type: ErrorType.network,
            canRetry: true,
          ),
        ],
      );
    });

    group('RefreshHomeContent', () {
      blocTest<HomeBloc, HomeState>(
        'emits [HomeLoaded] when refresh is successful with existing data',
        build: () {
          when(mockRepository.getFeaturedContent())
              .thenAnswer((_) async => []);
          when(mockRepository.getCategories())
              .thenAnswer((_) async => []);
          return homeBloc;
        },
        seed: () => const HomeLoaded(
          featuredContent: [],
          categoryContent: {},
          categories: [],
        ),
        act: (bloc) => bloc.add(const RefreshHomeContent()),
        expect: () => [
          const HomeLoaded(
            featuredContent: [],
            categoryContent: {},
            categories: [],
          ),
        ],
      );
    });
  });
}
```

### Widget Testing
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([HomeBloc])
import 'home_page_test.mocks.dart';

void main() {
  group('HomePage', () {
    late MockHomeBloc mockHomeBloc;

    setUp(() {
      mockHomeBloc = MockHomeBloc();
    });

    tearDown(() {
      mockHomeBloc.close();
    });

    testWidgets('displays loading indicator when state is HomeLoading', (tester) async {
      // Arrange
      when(mockHomeBloc.state).thenReturn(const HomeLoading());
      when(mockHomeBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<HomeBloc>.value(
            value: mockHomeBloc,
            child: const HomePage(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays content when state is HomeLoaded', (tester) async {
      // Arrange
      const loadedState = HomeLoaded(
        featuredContent: [],
        categoryContent: {},
        categories: [],
      );
      when(mockHomeBloc.state).thenReturn(loadedState);
      when(mockHomeBloc.stream).thenAnswer((_) => Stream.value(loadedState));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<HomeBloc>.value(
            value: mockHomeBloc,
            child: const HomePage(),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('Browse Categories'), findsOneWidget);
    });

    testWidgets('displays error message when state is HomeError', (tester) async {
      // Arrange
      const errorState = HomeError(
        message: 'Failed to load content',
        type: ErrorType.network,
      );
      when(mockHomeBloc.state).thenReturn(errorState);
      when(mockHomeBloc.stream).thenAnswer((_) => Stream.value(errorState));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<HomeBloc>.value(
            value: mockHomeBloc,
            child: const HomePage(),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('Connection Problem'), findsOneWidget);
      expect(find.text('Failed to load content'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('triggers LoadHomeContent when retry button is pressed', (tester) async {
      // Arrange
      const errorState = HomeError(
        message: 'Failed to load content',
        type: ErrorType.network,
      );
      when(mockHomeBloc.state).thenReturn(errorState);
      when(mockHomeBloc.stream).thenAnswer((_) => Stream.value(errorState));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<HomeBloc>.value(
            value: mockHomeBloc,
            child: const HomePage(),
          ),
        ),
      );
      await tester.pump();

      // Act
      await tester.tap(find.text('Try Again'));

      // Assert
      verify(mockHomeBloc.add(const LoadHomeContent())).called(1);
    });
  });
}
```

### Integration Testing
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dummy_ott_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Home Page Integration Tests', () {
    testWidgets('displays content and allows navigation to details', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for content to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify featured content is displayed
      expect(find.text('Browse Categories'), findsOneWidget);

      // Find and tap on a content item
      final contentCard = find.byType(GestureDetector).first;
      await tester.tap(contentCard);
      await tester.pumpAndSettle();

      // Verify navigation to details page
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('handles network errors gracefully', (tester) async {
      // This would require mocking network responses in integration tests
      // or testing with a test server that can simulate errors
    });
  });
}
```

These testing patterns ensure comprehensive coverage of error scenarios and proper validation of BLoC state transitions and UI behavior.
