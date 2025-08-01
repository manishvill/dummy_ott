# Dummy Data Generation Rules

You are generating dummy data for Flutter BLoC applications. Follow these strict rules for creating realistic test data.

## Model Dummy Data Rules

ALWAYS add static dummy data to models for testing purposes.

### ContentModel Dummy Data Pattern
```dart
class ContentModel extends Equatable {
  // ...existing code...

  // ALWAYS add static dummy data for testing
  static const List<ContentModel> dummyContent = [
    ContentModel(
      id: '1',
      title: 'Action Movie Title',
      description: 'Exciting action-packed description with details about plot, characters, and what makes it engaging to watch.',
      imageUrl: 'https://picsum.photos/seed/action1/400/600',
      category: 'Action',
      isFeatured: true,
      rating: 8.5,
    ),
    ContentModel(
      id: '2',
      title: 'Drama Series Title',
      description: 'Compelling drama description that explains the emotional journey and character development.',
      imageUrl: 'https://picsum.photos/seed/drama1/400/600',
      category: 'Drama',
      isFeatured: false,
      rating: 9.2,
    ),
    // ALWAYS add 15-20 dummy items minimum
  ];

  // ALWAYS add featured content subset
  static List<ContentModel> get dummyFeaturedContent =>
      dummyContent.where((content) => content.isFeatured).toList();

  // ALWAYS add category filtering
  static List<ContentModel> dummyContentByCategory(String category) =>
      dummyContent.where((content) => content.category == category).toList();
}
```

### Category Model Dummy Data Pattern
```dart
class Category extends Equatable {
  // ...existing code...

  // ALWAYS add static categories
  static const List<Category> dummyCategories = [
    Category(id: '1', name: 'Action'),
    Category(id: '2', name: 'Drama'),
    Category(id: '3', name: 'Comedy'),
    Category(id: '4', name: 'Thriller'),
    Category(id: '5', name: 'Sci-Fi'),
    Category(id: '6', name: 'Romance'),
    Category(id: '7', name: 'Horror'),
    Category(id: '8', name: 'Documentary'),
  ];

  static List<String> get dummyCategoryNames =>
      dummyCategories.map((cat) => cat.name).toList();
}
```

## Repository Dummy Data Rules

ALWAYS create comprehensive dummy data in repository with realistic delays.

### Repository Structure Pattern
```dart
class DummyFeatureRepository {
  // ALWAYS use static final for mutable collections
  static final List<ModelName> _dummyData = [
    // Copy from Model.dummyContent
    ...ModelName.dummyContent,
  ];

  // ALWAYS add realistic delays
  Future<List<ModelName>> getData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_dummyData);
  }

  Future<List<ModelName>> getFeaturedData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyData.where((item) => item.isFeatured).toList();
  }

  Future<List<ModelName>> getDataByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _dummyData.where((item) => item.category == category).toList();
  }

  Future<ModelName?> getDataById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _dummyData.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _dummyData.map((item) => item.category).toSet().toList();
  }

  // ALWAYS add search functionality
  Future<List<ModelName>> searchData(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final lowercaseQuery = query.toLowerCase();
    return _dummyData.where((item) =>
        item.title.toLowerCase().contains(lowercaseQuery) ||
        item.description.toLowerCase().contains(lowercaseQuery) ||
        item.category.toLowerCase().contains(lowercaseQuery)).toList();
  }
}
```

## Dummy Data Content Rules

### ALWAYS use realistic content:

#### Titles
- Action: "Fast & Furious", "Iron Guardian", "Mission: Impossible Redux"
- Drama: "The Last Letter", "Emotional Journey", "Life Stories"
- Comedy: "Laugh Out Loud", "Comedy Central", "Funny Business"
- Thriller: "Dark Secrets", "Suspense Master", "Edge of Tomorrow"
- Sci-Fi: "Space Odyssey", "Future World", "Alien Encounter"
- Romance: "Love Actually", "Heart to Heart", "Romantic Getaway"

#### Descriptions
ALWAYS write 2-3 sentence descriptions:
- First sentence: What happens in the story
- Second sentence: What makes it special/exciting
- Third sentence: Why someone should watch it

#### Image URLs
ALWAYS use Picsum with seeds for consistent images:
```dart
'https://picsum.photos/seed/action1/400/600'
'https://picsum.photos/seed/drama2/400/600'
'https://picsum.photos/seed/comedy3/400/600'
```

#### Ratings
- Use realistic ratings between 6.0-9.5
- Featured content should have ratings 8.0+
- Distribute ratings realistically (most 7.0-8.5)

#### Categories
ALWAYS include these categories:
- Action, Drama, Comedy, Thriller, Sci-Fi, Romance, Horror, Documentary

#### Featured Content
- ALWAYS mark 20-30% of content as featured
- Featured content should be highest rated
- Spread featured across different categories

## Data Volume Rules

### Minimum Data Requirements:
- **ContentModel**: 20+ items minimum
- **Categories**: 6-8 categories minimum  
- **Per Category**: 3-5 items minimum
- **Featured**: 5-8 featured items minimum

### Data Distribution:
- Action: 25% of content
- Drama: 20% of content  
- Comedy: 15% of content
- Thriller: 15% of content
- Sci-Fi: 10% of content
- Romance: 10% of content
- Other: 5% of content

## Delay Rules

ALWAYS add realistic delays to simulate network calls:
- **getData()**: 500ms delay
- **getFeaturedData()**: 300ms delay
- **getDataByCategory()**: 400ms delay
- **getDataById()**: 200ms delay
- **getCategories()**: 150ms delay
- **searchData()**: 600ms delay

## Error Simulation Rules

OPTIONALLY add error simulation for testing:
```dart
Future<List<ModelName>> getDataWithErrorSimulation() async {
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Simulate 10% error rate
  if (Random().nextInt(10) == 0) {
    throw Exception('Network error: Unable to fetch data');
  }
  
  return List.from(_dummyData);
}
```

NEVER generate empty or minimal dummy data. ALWAYS create rich, realistic test data that represents a real application's content.
