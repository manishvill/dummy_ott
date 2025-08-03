import '../models/content_model.dart';

class DummyContentRepository {
  static const List<Category> _categories = [
    Category(id: '1', name: 'Action'),
    Category(id: '2', name: 'Drama'),
    Category(id: '3', name: 'Comedy'),
    Category(id: '4', name: 'Thriller'),
    Category(id: '5', name: 'Sci-Fi'),
    Category(id: '6', name: 'Romance'),
  ];

  static final List<ContentModel> _content = [
    // Action Movies
    ContentModel(
      id: '1',
      title: 'Fast & Furious',
      description:
          'High-octane action thriller featuring incredible car chases and death-defying stunts. Follow the crew as they embark on their most dangerous mission yet.',
      imageUrl: 'https://picsum.photos/seed/action1/400/600',
      category: 'Action',
      isFeatured: true,
      rating: 8.5,
    ),
    ContentModel(
      id: '2',
      title: 'Iron Guardian',
      description:
          'A superhero must save the world from an alien invasion. Epic battles and stunning visual effects make this a must-watch action adventure.',
      imageUrl: 'https://picsum.photos/seed/action2/400/600',
      category: 'Action',
      rating: 9.0,
    ),
    ContentModel(
      id: '3',
      title: 'Mission: Impossible Redux',
      description:
          'Impossible missions, incredible stunts, and edge-of-your-seat action. The ultimate spy thriller that keeps you guessing until the end.',
      imageUrl: 'https://picsum.photos/seed/action3/400/600',
      category: 'Action',
      rating: 8.7,
    ),

    // Drama Movies
    ContentModel(
      id: '4',
      title: 'The Last Letter',
      description:
          'A deeply emotional story about love, loss, and redemption. This heart-wrenching drama explores the complexities of human relationships.',
      imageUrl: 'https://picsum.photos/seed/drama1/400/600',
      category: 'Drama',
      isFeatured: true,
      rating: 9.2,
    ),
    ContentModel(
      id: '5',
      title: 'Broken Dreams',
      description:
          'A powerful tale of resilience and hope in the face of adversity. This drama showcases outstanding performances and compelling storytelling.',
      imageUrl: 'https://picsum.photos/seed/drama2/400/600',
      category: 'Drama',
      rating: 8.8,
    ),
    ContentModel(
      id: '6',
      title: 'The Artist\'s Journey',
      description:
          'Follow a struggling artist as they navigate the challenges of pursuing their passion while dealing with personal and professional setbacks.',
      imageUrl: 'https://picsum.photos/seed/drama3/400/600',
      category: 'Drama',
      rating: 8.4,
    ),

    // Comedy Movies
    ContentModel(
      id: '7',
      title: 'Laugh Out Loud',
      description:
          'A hilarious comedy that will keep you laughing from start to finish. Perfect for a light-hearted movie night with friends and family.',
      imageUrl: 'https://picsum.photos/seed/comedy1/400/600',
      category: 'Comedy',
      isFeatured: true,
      rating: 7.9,
    ),
    ContentModel(
      id: '8',
      title: 'The Funny Guy',
      description:
          'A stand-up comedian\'s journey to stardom filled with mishaps, misunderstandings, and lots of laughs. A feel-good comedy for all ages.',
      imageUrl: 'https://picsum.photos/seed/comedy2/400/600',
      category: 'Comedy',
      rating: 8.1,
    ),
    ContentModel(
      id: '9',
      title: 'Office Shenanigans',
      description:
          'Workplace comedy at its finest. Watch as office employees navigate ridiculous situations and office politics with humor and wit.',
      imageUrl: 'https://picsum.photos/seed/comedy3/400/600',
      category: 'Comedy',
      rating: 7.6,
    ),

    // Additional Comedy Movies
    ContentModel(
      id: '16',
      title: 'Comedy Central',
      description:
          'The ultimate comedy experience with non-stop laughs and hilarious characters. A perfect blend of wit and humor.',
      imageUrl: 'https://picsum.photos/seed/comedy4/400/600',
      category: 'Comedy',
      rating: 7.8,
    ),
    ContentModel(
      id: '17',
      title: 'Joke\'s On You',
      description:
          'A comedy masterpiece that will have you rolling on the floor with laughter. Clever writing meets perfect timing.',
      imageUrl: 'https://picsum.photos/seed/comedy5/400/600',
      category: 'Comedy',
      rating: 8.0,
    ),

    // Thriller Movies
    ContentModel(
      id: '10',
      title: 'Dark Secrets',
      description:
          'A psychological thriller that will keep you on the edge of your seat. Uncover dark secrets and hidden truths in this suspenseful masterpiece.',
      imageUrl: 'https://picsum.photos/seed/thriller1/400/600',
      category: 'Thriller',
      rating: 8.9,
    ),
    ContentModel(
      id: '11',
      title: 'The Hunter',
      description:
          'A cat-and-mouse game between a detective and a serial killer. This intense thriller features unexpected twists and shocking revelations.',
      imageUrl: 'https://picsum.photos/seed/thriller2/400/600',
      category: 'Thriller',
      isFeatured: true,
      rating: 9.1,
    ),

    // Additional Thriller Movies
    ContentModel(
      id: '18',
      title: 'Midnight Terror',
      description:
          'A spine-chilling thriller that will keep you awake at night. Suspense builds with every scene in this masterpiece.',
      imageUrl: 'https://picsum.photos/seed/thriller3/400/600',
      category: 'Thriller',
      rating: 8.7,
    ),
    ContentModel(
      id: '19',
      title: 'The Chase',
      description:
          'High-stakes thriller with non-stop action and unexpected plot twists. Every moment counts in this edge-of-your-seat experience.',
      imageUrl: 'https://picsum.photos/seed/thriller4/400/600',
      category: 'Thriller',
      rating: 8.9,
    ),
    ContentModel(
      id: '20',
      title: 'Silent Killer',
      description:
          'A psychological thriller that explores the darkest corners of the human mind. Prepare for shocking revelations.',
      imageUrl: 'https://picsum.photos/seed/thriller5/400/600',
      category: 'Thriller',
      rating: 9.0,
    ),

    // Sci-Fi Movies
    ContentModel(
      id: '12',
      title: 'Galaxy Wars',
      description:
          'Epic space battles and alien encounters in this stunning sci-fi adventure. The future of humanity hangs in the balance.',
      imageUrl: 'https://picsum.photos/seed/scifi1/400/600',
      category: 'Sci-Fi',
      rating: 8.6,
    ),
    ContentModel(
      id: '13',
      title: 'Time Paradox',
      description:
          'A mind-bending time travel story that explores the consequences of altering the past. Prepare for a thought-provoking sci-fi experience.',
      imageUrl: 'https://picsum.photos/seed/scifi2/400/600',
      category: 'Sci-Fi',
      isFeatured: true,
      rating: 8.8,
    ),

    // Romance Movies
    ContentModel(
      id: '14',
      title: 'Love Actually Happens',
      description:
          'A beautiful love story that spans different timelines and locations. This romantic drama will touch your heart and soul.',
      imageUrl: 'https://picsum.photos/seed/romance1/400/600',
      category: 'Romance',
      rating: 8.3,
    ),
    ContentModel(
      id: '15',
      title: 'Second Chances',
      description:
          'Two people get a second chance at love after years apart. A heartwarming romance that believes in the power of true love.',
      imageUrl: 'https://picsum.photos/seed/romance2/400/600',
      category: 'Romance',
      isFeatured: true,
      rating: 8.5,
    ),

    // Additional Romance Movies
    ContentModel(
      id: '21',
      title: 'Eternal Love',
      description:
          'A timeless love story that transcends all boundaries. Romance at its most beautiful and touching form.',
      imageUrl: 'https://picsum.photos/seed/romance3/400/600',
      category: 'Romance',
      rating: 8.4,
    ),
    ContentModel(
      id: '22',
      title: 'Heart to Heart',
      description:
          'An emotional journey of two souls finding each other against all odds. Love conquers all in this touching tale.',
      imageUrl: 'https://picsum.photos/seed/romance4/400/600',
      category: 'Romance',
      rating: 8.6,
    ),
    ContentModel(
      id: '23',
      title: 'Perfect Match',
      description:
          'A romantic comedy that perfectly balances humor and heart. Sometimes love finds you when you least expect it.',
      imageUrl: 'https://picsum.photos/seed/romance5/400/600',
      category: 'Romance',
      rating: 8.2,
    ),
  ];

  // Simulate network delay
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<ContentModel>> getAllContent() async {
    await _simulateNetworkDelay();
    return List.from(_content);
  }

  Future<List<ContentModel>> getFeaturedContent() async {
    await _simulateNetworkDelay();
    return _content.where((content) => content.isFeatured).toList();
  }

  // Method to get upcoming movies (simulated)
  Future<List<ContentModel>> getUpcomingMovies() async {
    await _simulateNetworkDelay();
    return _content.where((content) => !content.isFeatured).toList();
  }

  Future<List<ContentModel>> getContentByCategory(String category) async {
    await _simulateNetworkDelay();
    return _content.where((content) => content.category == category).toList();
  }

  Future<List<Category>> getCategories() async {
    await _simulateNetworkDelay();
    return List.from(_categories);
  }

  Future<ContentModel?> getContentById(String id) async {
    await _simulateNetworkDelay();
    try {
      return _content.firstWhere((content) => content.id == id);
    } catch (e) {
      return null;
    }
  }
}
