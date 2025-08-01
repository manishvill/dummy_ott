# Flutter BLoC Forbidden Patterns

NEVER do these things. These are ANTI-PATTERNS that will break the codebase.

## ❌ FORBIDDEN - File Structure Violations

NEVER create files like this:
```
❌ HomeBloc.dart (wrong case)
❌ home-bloc.dart (wrong separator) 
❌ homebloc.dart (no separation)
❌ lib/home_bloc.dart (wrong location)
❌ lib/bloc/home.dart (wrong structure)
```

ALWAYS use:
```
✅ lib/blocs/home/home_bloc.dart
✅ lib/blocs/home/home_event.dart
✅ lib/blocs/home/home_state.dart
```

## ❌ FORBIDDEN - Event Violations

NEVER create events like this:
```dart
❌ class LoadData { const LoadData(); } // Missing Equatable

❌ class UpdateItem extends MyEvent {
  final String id;
  const UpdateItem(this.id);
  // Missing props override
}

❌ class MyEvent extends Equatable {
  MyEvent(); // Missing const
}
```

## ❌ FORBIDDEN - State Violations

NEVER create states like this:
```dart
❌ class MyLoaded extends MyState {
  List<String> items; // Not final
  MyLoaded(this.items);
}

❌ class MyState {
  final List<String> items;
  MyState(this.items);
  // Missing Equatable
}

❌ class MyLoaded extends MyState {
  final List<String> items;
  const MyLoaded({required this.items});
  // Missing props override
}
```

## ❌ FORBIDDEN - BLoC Violations  

NEVER write BLoC methods like this:
```dart
❌ Future<void> loadData(Emitter<MyState> emit) async {
  emit(const MyLoading());
  final data = await repository.getData(); // No error handling
  emit(MyLoaded(data: data));
}

❌ Future<void> _onNavigate(Navigate event, Emitter<MyState> emit) async {
  Navigator.pushNamed(context, '/details'); // Navigation in BLoC
}

❌ class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(const MyInitial()) {
    // Missing repository injection
  }
}
```

## ❌ FORBIDDEN - UI Violations

NEVER write UI like this:
```dart
❌ class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: repository.getData(), // Direct repository call
      builder: (context, snapshot) => Text('${snapshot.data}'),
    );
  }
}

❌ class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  List<String> items = [];
  
  void loadData() async {
    final data = await repository.getData();
    setState(() { items = data; }); // setState with BLoC
  }
}

❌ BlocBuilder<MyBloc, MyState>(
  builder: (context, state) {
    return Text('Loading...'); // Not handling all states
  },
)
```

## ❌ FORBIDDEN - Import Violations

NEVER import like this:
```dart
❌ import '../models/content_model.dart';
import 'package:flutter/material.dart'; // Wrong order

❌ import 'home_bloc.dart'; // Missing relative path

❌ import 'package:dummy_ott_app/blocs/home/home_bloc.dart'; // Absolute import
```

## ❌ FORBIDDEN - Naming Violations

NEVER name things like this:
```dart
❌ class homeBloc extends Bloc // Wrong case
❌ class Home_Bloc extends Bloc // Wrong separator
❌ class loadHomeContent extends HomeEvent // Wrong case
❌ class home_loaded extends HomeState // Wrong case
❌ void onLoadHomeContent() // Missing underscore for private
❌ void LoadHomeContent() // Wrong case for method
```

## ❌ FORBIDDEN - Model Violations

NEVER create models like this:
```dart
❌ class ContentModel {
  String title; // Not final, not extending Equatable
  ContentModel(this.title);
}

❌ class ContentModel extends Equatable {
  final String title;
  ContentModel({required this.title});
  // Missing props override
}

❌ class ContentModel extends Equatable {
  final String title;
  const ContentModel({required this.title});
  @override
  List<Object?> get props => []; // Empty props
}
```

## ⚠️ WARNING SIGNS

If you see any of these patterns, STOP and fix immediately:

1. **setState() in same file as BlocBuilder** - Use BLoC pattern only
2. **Repository calls in UI widgets** - Use BLoC to access repository  
3. **Navigation in BLoC methods** - Handle navigation in UI layer
4. **Missing try-catch in async BLoC methods** - Always handle errors
5. **Missing Equatable extension** - All events/states/models need Equatable
6. **Missing const constructors** - Use const wherever possible
7. **Mutable fields in models** - All fields must be final
8. **Missing props override** - Required for Equatable comparison

## ✅ CORRECT PATTERNS TO FOLLOW

Use ONLY these patterns from your existing codebase:

1. **File Structure**: Follow lib/blocs/home/ pattern exactly
2. **Event Pattern**: Copy from home_event.dart structure  
3. **State Pattern**: Copy from home_state.dart structure
4. **BLoC Pattern**: Copy from home_bloc.dart structure
5. **UI Pattern**: Copy from home_page.dart structure
6. **Model Pattern**: Copy from content_model.dart structure

When in doubt, reference the existing working code in your OTT app.
