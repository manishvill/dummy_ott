# Flutter Project Structure Guide for LLM Training

## Overview
This document describes the standard Flutter project structure following BLoC pattern for an OTT (Over-The-Top) streaming application. Follow this structure when creating new files and folders.

## Root Directory Structure
```
project_name/
├── lib/                    # Main source code directory
├── android/               # Android-specific files
├── ios/                   # iOS-specific files  
├── web/                   # Web-specific files
├── macos/                 # macOS-specific files
├── windows/               # Windows-specific files
├── linux/                 # Linux-specific files
├── build/                 # Generated build files (auto-generated)
├── pubspec.yaml           # Project dependencies and metadata
├── pubspec.lock           # Locked dependency versions (auto-generated)
├── analysis_options.yaml  # Dart analysis rules
├── README.md              # Project documentation
└── firebase.json          # Firebase configuration (if using Firebase)
```

## Main Source Code Structure (lib/)
```
lib/
├── main.dart              # Application entry point
├── firebase_options.dart  # Firebase configuration (auto-generated)
├── blocs/                 # Business Logic Components
│   ├── feature_name/
│   │   ├── feature_bloc.dart
│   │   ├── feature_event.dart
│   │   └── feature_state.dart
│   └── ...
├── models/                # Data models
│   ├── model_name.dart
│   └── ...
├── pages/                 # UI screens/pages
│   ├── page_name.dart
│   └── ...
├── widgets/               # Reusable UI components
│   ├── widget_name.dart
│   └── ...
├── repository/            # Data access layer
│   ├── repository_name.dart
│   └── ...
├── services/              # External services (API, database, etc.)
│   ├── service_name.dart
│   └── ...
├── utils/                 # Utility functions and constants
│   ├── constants.dart
│   ├── helpers.dart
│   └── ...
└── theme/                 # App theme and styling
    ├── app_theme.dart
    ├── colors.dart
    └── ...
```

## File Naming Conventions

### General Rules
- Use **snake_case** for all file and folder names
- Use descriptive names that clearly indicate the file's purpose
- Include the component type in the filename (e.g., `_bloc.dart`, `_page.dart`)

### Specific Naming Patterns
- **Blocs**: `feature_name_bloc.dart`, `feature_name_event.dart`, `feature_name_state.dart`
- **Pages**: `feature_name_page.dart`
- **Models**: `entity_name_model.dart`
- **Repositories**: `entity_name_repository.dart`
- **Services**: `service_name_service.dart`
- **Widgets**: `widget_name_widget.dart` or `widget_name.dart`

## BLoC Folder Organization

### Each BLoC feature should have its own folder:
```
blocs/
├── home/
│   ├── home_bloc.dart
│   ├── home_event.dart
│   └── home_state.dart
├── details/
│   ├── details_bloc.dart
│   ├── details_event.dart
│   └── details_state.dart
├── category/
│   ├── category_bloc.dart
│   ├── category_event.dart
│   └── category_state.dart
└── profile/
    ├── profile_bloc.dart
    ├── profile_event.dart
    └── profile_state.dart
```

## Page Organization
- Each page represents a complete screen in the app
- Pages should be stateless widgets that interact with BLoCs
- Use descriptive names that match the feature they represent

```
pages/
├── home_page.dart          # Main screen with featured content
├── details_page.dart       # Content details screen
├── category_page.dart      # Category listing screen
├── profile_page.dart       # User profile screen
├── search_page.dart        # Search functionality screen
└── splash_page.dart        # App loading screen
```

## Model Organization
- Models represent data structures
- Use Equatable for value equality
- Include serialization methods when needed

```
models/
├── content_model.dart      # Video/movie content data
├── user_model.dart         # User profile data
├── category_model.dart     # Content category data
└── playlist_model.dart     # User playlist data
```

## Repository Organization
- Repositories handle data access and business logic
- Abstract complex data operations
- Provide clean interface for BLoCs

```
repository/
├── content_repository.dart      # Content data access
├── user_repository.dart         # User data access
├── dummy_content_repository.dart # Mock data for development
└── api_repository.dart          # API communication
```

## Key Directory Rules

1. **Never mix UI and business logic** - Keep pages separate from blocs
2. **Group related files** - Keep bloc files together in their own folder
3. **Use consistent naming** - Follow the naming conventions strictly
4. **Separate concerns** - Models, repositories, and UI should be in separate folders
5. **Keep main.dart clean** - Only app initialization and routing setup

## When to Create New Directories

### Create new folders when:
- Adding a new major feature (new bloc folder)
- Adding multiple related utilities (utils subfolder)
- Adding theme-related files (theme folder)
- Adding multiple services (services subfolder)

### Don't create folders for:
- Single files that fit existing categories
- Temporary or test files
- Files that don't follow the established patterns

## Import Path Examples
```dart
// Importing from the same feature
import 'home_event.dart';
import 'home_state.dart';

// Importing from other features
import '../models/content_model.dart';
import '../repository/content_repository.dart';
import '../pages/details_page.dart';

// Importing external packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
```

This structure ensures maintainability, scalability, and follows Flutter/Dart best practices while implementing the BLoC pattern correctly.
