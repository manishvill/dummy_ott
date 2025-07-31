import 'package:equatable/equatable.dart';

class ContentModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final bool isFeatured;
  final double rating;

  const ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.isFeatured = false,
    this.rating = 0.0,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        category,
        isFeatured,
        rating,
      ];
}

class Category extends Equatable {
  final String id;
  final String name;

  const Category({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
