import 'package:equatable/equatable.dart';
import '../../models/content_model.dart';

abstract class DetailsState extends Equatable {
  const DetailsState();

  @override
  List<Object?> get props => [];
}

class DetailsInitial extends DetailsState {
  const DetailsInitial();
}

class DetailsLoading extends DetailsState {
  const DetailsLoading();
}

class DetailsLoaded extends DetailsState {
  final ContentModel content;
  final List<ContentModel> similarContent;
  final bool isInWatchlist;
  final bool isPlaying;

  const DetailsLoaded({
    required this.content,
    this.similarContent = const [],
    this.isInWatchlist = false,
    this.isPlaying = false,
  });

  DetailsLoaded copyWith({
    ContentModel? content,
    List<ContentModel>? similarContent,
    bool? isInWatchlist,
    bool? isPlaying,
  }) {
    return DetailsLoaded(
      content: content ?? this.content,
      similarContent: similarContent ?? this.similarContent,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [
        content,
        similarContent,
        isInWatchlist,
        isPlaying,
      ];
}

class DetailsError extends DetailsState {
  final String message;

  const DetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ContentPlaying extends DetailsState {
  final ContentModel content;

  const ContentPlaying(this.content);

  @override
  List<Object?> get props => [content];
}

class WatchlistUpdated extends DetailsState {
  final bool isAdded;
  final String message;

  const WatchlistUpdated({
    required this.isAdded,
    required this.message,
  });

  @override
  List<Object?> get props => [isAdded, message];
}
