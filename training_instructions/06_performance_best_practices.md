# Flutter Performance and Best Practices for LLM Training

## Performance Optimization Guidelines

### Widget Performance

#### 1. Use const Constructors
```dart
// ✅ Good - Use const for static widgets
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to OTT Stream'),
            SizedBox(height: 16),
            Icon(Icons.play_circle_outline, size: 64),
          ],
        ),
      ),
    );
  }
}

// ❌ Bad - Missing const constructors
class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to OTT Stream'),
            SizedBox(height: 16),
            Icon(Icons.play_circle_outline, size: 64),
          ],
        ),
      ),
    );
  }
}
```

#### 2. Extract Widgets Effectively
```dart
// ✅ Good - Extract widgets that are reused or complex
class ContentGrid extends StatelessWidget {
  final List<ContentModel> content;

  const ContentGrid({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
      ),
      itemCount: content.length,
      itemBuilder: (context, index) => ContentCard(content: content[index]),
    );
  }
}

class ContentCard extends StatelessWidget {
  final ContentModel content;

  const ContentCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              content.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: _buildLoadingIndicator,
              errorBuilder: _buildErrorWidget,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              content.title,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / 
              loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const Center(
      child: Icon(Icons.error, color: Colors.grey),
    );
  }
}
```

#### 3. Optimize List Performance
```dart
// ✅ Good - Use keys for list items with dynamic data
class ContentList extends StatelessWidget {
  final List<ContentModel> content;

  const ContentList({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: content.length,
      itemBuilder: (context, index) {
        final item = content[index];
        return ContentListItem(
          key: ValueKey(item.id), // Important for list performance
          content: item,
          onTap: () => _navigateToDetails(context, item.id),
        );
      },
    );
  }

  void _navigateToDetails(BuildContext context, String contentId) {
    Navigator.pushNamed(
      context,
      '/details',
      arguments: {'contentId': contentId},
    );
  }
}

// ✅ Good - Use AutomaticKeepAliveClientMixin for expensive widgets
class VideoPlayer extends StatefulWidget {
  final String videoUrl;

  const VideoPlayer({super.key, required this.videoUrl});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;

  @override
  bool get wantKeepAlive => true; // Keep widget alive when scrolled out of view

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for AutomaticKeepAliveClientMixin
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayerWidget(_controller),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Memory Management

#### 1. Proper Resource Disposal
```dart
class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const ImageCarousel({super.key, required this.imageUrls});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _startAutoPlay();
  }

  @override
  void dispose() {
    // Dispose controllers and cancel timers
    _pageController.dispose();
    _animationController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_pageController.page?.round() ?? 0) + 1;
        if (nextPage < widget.imageUrls.length) {
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return Image.network(
            widget.imageUrls[index],
            fit: BoxFit.cover,
            cacheWidth: 800, // Optimize image memory usage
            cacheHeight: 400,
          );
        },
      ),
    );
  }
}
```

#### 2. Image Optimization
```dart
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      // Optimize memory usage by specifying cache dimensions
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error, color: Colors.grey),
        );
      },
    );
  }
}
```

### State Management Best Practices

#### 1. Efficient BLoC Usage
```dart
// ✅ Good - Use BlocBuilder for specific UI updates
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Only rebuild this section when featured content changes
        BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) {
            if (previous is HomeLoaded && current is HomeLoaded) {
              return previous.featuredContent != current.featuredContent;
            }
            return true;
          },
          builder: (context, state) {
            if (state is HomeLoaded) {
              return FeaturedSection(content: state.featuredContent);
            }
            return const SizedBox.shrink();
          },
        ),
        
        // Separate builder for categories
        BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) {
            if (previous is HomeLoaded && current is HomeLoaded) {
              return previous.categories != current.categories;
            }
            return true;
          },
          builder: (context, state) {
            if (state is HomeLoaded) {
              return CategoriesSection(categories: state.categories);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

// ✅ Good - Use BlocSelector for very specific data
class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<UserBloc, UserState, String>(
      selector: (state) {
        if (state is UserLoaded) {
          return state.user.name;
        }
        return 'Guest';
      },
      builder: (context, userName) {
        return Text('Welcome, $userName');
      },
    );
  }
}
```

#### 2. Lazy Loading Implementation
```dart
class ContentRepository {
  final List<ContentModel> _cache = [];
  int _currentPage = 0;
  static const int _pageSize = 20;
  bool _hasMore = true;

  Future<List<ContentModel>> loadMoreContent() async {
    if (!_hasMore) return [];

    try {
      final response = await _apiService.getContent(
        page: _currentPage,
        limit: _pageSize,
      );

      final newContent = response.data
          .map<ContentModel>((json) => ContentModel.fromJson(json))
          .toList();

      _cache.addAll(newContent);
      _currentPage++;
      _hasMore = newContent.length == _pageSize;

      return newContent;
    } catch (e) {
      throw ContentRepositoryException('Failed to load more content: $e');
    }
  }

  List<ContentModel> get cachedContent => List.unmodifiable(_cache);
  bool get hasMoreContent => _hasMore;
}

// Usage in BLoC
class ContentListBloc extends Bloc<ContentListEvent, ContentListState> {
  final ContentRepository repository;

  ContentListBloc({required this.repository}) : super(const ContentListInitial()) {
    on<LoadInitialContent>(_onLoadInitialContent);
    on<LoadMoreContent>(_onLoadMoreContent);
  }

  Future<void> _onLoadMoreContent(
    LoadMoreContent event,
    Emitter<ContentListState> emit,
  ) async {
    if (state is ContentListLoaded && !repository.hasMoreContent) {
      return; // No more content to load
    }

    try {
      final currentState = state;
      if (currentState is ContentListLoaded) {
        emit(currentState.copyWith(isLoadingMore: true));
      }

      final newContent = await repository.loadMoreContent();
      
      if (currentState is ContentListLoaded) {
        emit(ContentListLoaded(
          content: repository.cachedContent,
          hasMore: repository.hasMoreContent,
          isLoadingMore: false,
        ));
      }
    } catch (e) {
      if (state is ContentListLoaded) {
        emit((state as ContentListLoaded).copyWith(
          isLoadingMore: false,
          error: e.toString(),
        ));
      }
    }
  }
}
```

### UI Performance Best Practices

#### 1. Efficient Scrolling
```dart
class InfiniteScrollList extends StatefulWidget {
  const InfiniteScrollList({super.key});

  @override
  State<InfiniteScrollList> createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<InfiniteScrollList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more content when 80% scrolled
      context.read<ContentListBloc>().add(const LoadMoreContent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContentListBloc, ContentListState>(
      builder: (context, state) {
        if (state is ContentListLoaded) {
          return ListView.builder(
            controller: _scrollController,
            itemCount: state.content.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.content.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              return ContentCard(
                key: ValueKey(state.content[index].id),
                content: state.content[index],
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
```

#### 2. Debounced Search
```dart
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  Timer? _debounceTimer;
  final ContentRepository repository;

  SearchBloc({required this.repository}) : super(const SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchQuerySubmitted>(_onSearchQuerySubmitted);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) {
    _debounceTimer?.cancel();
    
    if (event.query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(SearchLoading(query: event.query));

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      add(SearchQuerySubmitted(query: event.query));
    });
  }

  Future<void> _onSearchQuerySubmitted(
    SearchQuerySubmitted event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final results = await repository.searchContent(event.query);
      emit(SearchLoaded(
        query: event.query,
        results: results,
      ));
    } catch (e) {
      emit(SearchError(
        query: event.query,
        message: e.toString(),
      ));
    }
  }
}
```

### Code Quality Best Practices

#### 1. Immutable Data Structures
```dart
// ✅ Good - Immutable model with copyWith
class ContentModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> genres;
  final bool isFavorite;

  const ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.genres,
    this.isFavorite = false,
  });

  ContentModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? genres,
    bool? isFavorite,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      genres: genres ?? List.from(this.genres), // Create new list
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, title, description, genres, isFavorite];
}
```

#### 2. Null Safety Best Practices
```dart
// ✅ Good - Proper null safety usage
class UserService {
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  String get userName => _currentUser?.name ?? 'Guest';

  Future<void> login(String email, String password) async {
    final response = await _authService.login(email, password);
    
    if (response.isSuccess && response.user != null) {
      _currentUser = response.user;
    } else {
      throw AuthException(response.errorMessage ?? 'Login failed');
    }
  }

  void logout() {
    _currentUser = null;
  }
}

// ✅ Good - Safe widget building
class UserProfileWidget extends StatelessWidget {
  final User? user;

  const UserProfileWidget({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final currentUser = user;
    
    if (currentUser == null) {
      return const Text('No user data available');
    }

    return Column(
      children: [
        Text(currentUser.name),
        Text(currentUser.email),
        if (currentUser.profileImageUrl?.isNotEmpty == true)
          Image.network(currentUser.profileImageUrl!),
      ],
    );
  }
}
```

These performance optimization guidelines ensure your Flutter application runs smoothly and efficiently while maintaining code quality and best practices.
