# Common Patterns & Anti-Patterns - Quick Reference

## ✅ DO - Good Patterns From Your Codebase

### BLoC Event Pattern (Following your home_event.dart)
```dart
// ✅ Good - Simple events
class LoadHomeContent extends HomeEvent {
  const LoadHomeContent();
}

// ✅ Good - Events with parameters
class NavigateToCategory extends HomeEvent {
  final String category;
  const NavigateToCategory(this.category);
  
  @override
  List<Object?> get props => [category];
}
```

### BLoC State Pattern (Following your home_state.dart)
```dart
// ✅ Good - Clear state hierarchy
abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<ContentModel> featuredContent;
  final List<ContentModel> comedyContent;
  
  const HomeLoaded({
    required this.featuredContent,
    required this.comedyContent,
  });
  
  @override
  List<Object?> get props => [featuredContent, comedyContent];
}
```

### Repository Usage (Following your pattern)
```dart
// ✅ Good - Repository injection
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final DummyContentRepository repository;

  HomeBloc({required this.repository}) : super(const HomeInitial()) {
    on<LoadHomeContent>(_onLoadHomeContent);
  }

  Future<void> _onLoadHomeContent(
    LoadHomeContent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(const HomeLoading());
      final featuredContent = await repository.getFeaturedContent();
      emit(HomeLoaded(featuredContent: featuredContent));
    } catch (error) {
      emit(HomeError(message: error.toString()));
    }
  }
}
```

### UI Pattern (Following your home_page.dart)
```dart
// ✅ Good - BlocBuilder usage
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeContent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeLoaded) {
            return _buildContent(state);
          } else if (state is HomeError) {
            return _buildError(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

## ❌ DON'T - Anti-Patterns to Avoid

### Wrong Event Structure
```dart
// ❌ Bad - Not extending Equatable
class LoadData {
  const LoadData();
}

// ❌ Bad - Missing props override for parameters
class UpdateItem extends MyEvent {
  final String id;
  const UpdateItem(this.id);
  // Missing @override List<Object?> get props => [id];
}
```

### Wrong State Structure
```dart
// ❌ Bad - Mutable state
class MyLoaded extends MyState {
  List<String> items; // Should be final
  MyLoaded(this.items);
}

// ❌ Bad - Not using Equatable
class MyState {
  final List<String> items;
  MyState(this.items);
  // Missing Equatable extension and props
}
```

### Wrong BLoC Implementation
```dart
// ❌ Bad - Direct state emission without error handling
Future<void> _onLoadData(LoadData event, Emitter<MyState> emit) async {
  emit(const MyLoading());
  final data = await repository.getData(); // What if this fails?
  emit(MyLoaded(data: data));
}

// ❌ Bad - UI logic in BLoC
Future<void> _onNavigate(Navigate event, Emitter<MyState> emit) async {
  Navigator.pushNamed(context, '/details'); // Don't do navigation in BLoC
}
```

### Wrong UI Implementation
```dart
// ❌ Bad - Direct repository calls in UI
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: repository.getData(), // Use BLoC instead
      builder: (context, snapshot) {
        // ...
      },
    );
  }
}

// ❌ Bad - setState with BLoC
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  List<String> items = [];
  
  void loadData() async {
    final data = await repository.getData();
    setState(() { // Don't use setState with BLoC
      items = data;
    });
  }
}
```

## Quick Decision Tree

### When creating a new event:
1. **Does it have parameters?** → Add props override
2. **Is it a simple action?** → Use verb + noun naming (LoadContent, RefreshData)
3. **Is it navigation?** → Handle in UI, not BLoC

### When creating a new state:
1. **Does it hold data?** → Add to props override
2. **Is it an error?** → Include error message
3. **Is it loading?** → Use simple const constructor

### When creating a new BLoC method:
1. **Is it async?** → Use try-catch
2. **Does it emit loading?** → Emit loading state first
3. **Can it fail?** → Emit error state on catch

### When creating a new page:
1. **Does it need data?** → Use BlocBuilder
2. **Should it load on init?** → Add event in initState
3. **Can user refresh?** → Add RefreshIndicator

## File Naming Patterns From Your Codebase

```
✅ Correct naming (following your pattern):
- home_bloc.dart, home_event.dart, home_state.dart
- content_model.dart
- home_page.dart, details_page.dart
- dummy_content_repository.dart

❌ Wrong naming:
- HomeBloc.dart (wrong case)
- home-bloc.dart (wrong separator)
- homebloc.dart (missing separation)
```

## Import Patterns From Your Code

```dart
// ✅ Good - Follow your import order
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/home/home_event.dart';
import '../blocs/home/home_state.dart';
import '../models/content_model.dart';

// ❌ Bad - Wrong import order or missing imports
import '../models/content_model.dart';
import 'package:flutter/material.dart'; // Should be first
```

Follow these patterns to maintain consistency with your existing OTT app codebase.
