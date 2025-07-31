import 'package:equatable/equatable.dart';
import '../../models/content_model.dart';

abstract class DetailsEvent extends Equatable {
  const DetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadContentDetails extends DetailsEvent {
  final ContentModel content;

  const LoadContentDetails(this.content);

  @override
  List<Object?> get props => [content];
}

class PlayContent extends DetailsEvent {
  const PlayContent();
}

class AddToWatchlist extends DetailsEvent {
  const AddToWatchlist();
}

class RemoveFromWatchlist extends DetailsEvent {
  const RemoveFromWatchlist();
}

class LoadSimilarContent extends DetailsEvent {
  final String category;

  const LoadSimilarContent(this.category);

  @override
  List<Object?> get props => [category];
}
