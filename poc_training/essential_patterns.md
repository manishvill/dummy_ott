# Flutter BLoC Rules

You are an expert Flutter developer specializing in BLoC pattern. Follow these rules strictly when generating code.

## Project Structure Rules

ALWAYS follow this exact structure:
```
lib/
├── main.dart
├── firebase_options.dart
├── blocs/feature_name/
│   ├── feature_name_bloc.dart
│   ├── feature_name_event.dart
│   └── feature_name_state.dart
├── models/
│   └── model_name_model.dart
├── pages/
│   └── feature_name_page.dart
└── repository/
    └── feature_name_repository.dart
```

NEVER create files outside this structure.
ALWAYS use snake_case for file names.
ALWAYS group BLoC files in feature folders.

## BLoC Pattern Rules

### Event Rules
ALWAYS extend Equatable:
```dart
abstract class FeatureEvent extends Equatable {
  const FeatureEvent();
  @override
  List<Object?> get props => [];
}
```

ALWAYS use const constructors:
```dart
class LoadFeatureData extends FeatureEvent {
  const LoadFeatureData();
}
```

ALWAYS override props for events with parameters:
```dart
class UpdateItem extends FeatureEvent {
  final String itemId;
  const UpdateItem(this.itemId);
  @override
  List<Object?> get props => [itemId];
}
```

### State Rules
ALWAYS extend Equatable:
```dart
abstract class FeatureState extends Equatable {
  const FeatureState();
  @override
  List<Object?> get props => [];
}
```

ALWAYS include these standard states:
- FeatureInitial
- FeatureLoading  
- FeatureLoaded
- FeatureError

ALWAYS override props for states with data:
```dart
class FeatureLoaded extends FeatureState {
  final List<ContentModel> items;
  const FeatureLoaded({required this.items});
  @override
  List<Object?> get props => [items];
}
```

### BLoC Rules
ALWAYS inject repository in constructor:
```dart
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final Repository repository;
  FeatureBloc({required this.repository}) : super(const FeatureInitial()) {
    on<LoadFeatureData>(_onLoadFeatureData);
  }
}
```

ALWAYS wrap async operations in try-catch:
```dart
Future<void> _onLoadFeatureData(
  LoadFeatureData event,
  Emitter<FeatureState> emit,
) async {
  try {
    emit(const FeatureLoading());
    final data = await repository.getData();
    emit(FeatureLoaded(items: data));
  } catch (error) {
    emit(FeatureError(message: error.toString()));
  }
}
```

ALWAYS use private methods for event handlers (prefix with _on).

## Model Rules

ALWAYS extend Equatable:
```dart
class ContentModel extends Equatable {
  final String id;
  final String title;
  const ContentModel({required this.id, required this.title});
  @override
  List<Object?> get props => [id, title];
}
```

ALWAYS use final fields.
ALWAYS provide copyWith method for updates.
NEVER use mutable properties.

## UI Rules

ALWAYS use StatefulWidget for pages that load data:
```dart
class FeaturePage extends StatefulWidget {
  const FeaturePage({super.key});
  @override
  State<FeaturePage> createState() => _FeaturePageState();
}
```

ALWAYS trigger data loading in initState:
```dart
@override
void initState() {
  super.initState();
  context.read<FeatureBloc>().add(const LoadFeatureData());
}
```

ALWAYS use BlocBuilder for state management:
```dart
BlocBuilder<FeatureBloc, FeatureState>(
  builder: (context, state) {
    if (state is FeatureLoading) return CircularProgressIndicator();
    if (state is FeatureLoaded) return _buildContent(state);
    if (state is FeatureError) return _buildError(state.message);
    return SizedBox.shrink();
  },
)
```

ALWAYS handle all state types (Initial, Loading, Loaded, Error).
NEVER call repository directly from UI.
NEVER use setState with BLoC pattern.

## Import Rules

ALWAYS use this exact import order:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/feature/feature_bloc.dart';
import '../blocs/feature/feature_event.dart';
import '../blocs/feature/feature_state.dart';
import '../models/content_model.dart';
```

Flutter packages first, then relative imports.

## Naming Rules

Files: feature_name_bloc.dart, feature_name_page.dart
Classes: FeatureNameBloc, FeatureNamePage  
Events: LoadFeatureNameData, UpdateFeatureNameItem
States: FeatureNameLoading, FeatureNameLoaded
Methods: _onLoadFeatureNameData

NEVER use camelCase for files.
ALWAYS use PascalCase for classes.
ALWAYS prefix private methods with underscore.
