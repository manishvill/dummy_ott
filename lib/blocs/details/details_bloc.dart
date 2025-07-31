import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/dummy_content_repository.dart';
import 'details_event.dart';
import 'details_state.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  final DummyContentRepository repository;

  DetailsBloc({required this.repository}) : super(const DetailsInitial()) {
    on<LoadContentDetails>(_onLoadContentDetails);
    on<PlayContent>(_onPlayContent);
    on<AddToWatchlist>(_onAddToWatchlist);
    on<RemoveFromWatchlist>(_onRemoveFromWatchlist);
    on<LoadSimilarContent>(_onLoadSimilarContent);
  }

  Future<void> _onLoadContentDetails(
    LoadContentDetails event,
    Emitter<DetailsState> emit,
  ) async {
    try {
      emit(const DetailsLoading());

      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Load similar content from the same category
      final similarContent =
          await repository.getContentByCategory(event.content.category);

      // Remove the current content from similar content list
      final filteredSimilarContent = similarContent
          .where((content) => content.id != event.content.id)
          .take(6) // Limit to 6 similar items
          .toList();

      emit(DetailsLoaded(
        content: event.content,
        similarContent: filteredSimilarContent,
        isInWatchlist: false, // Default to not in watchlist
        isPlaying: false,
      ));
    } catch (e) {
      emit(DetailsError('Failed to load content details: $e'));
    }
  }

  Future<void> _onPlayContent(
    PlayContent event,
    Emitter<DetailsState> emit,
  ) async {
    if (state is DetailsLoaded) {
      final currentState = state as DetailsLoaded;
      emit(ContentPlaying(currentState.content));

      // Simulate returning to details after play dialog
      await Future.delayed(const Duration(milliseconds: 100));
      emit(currentState.copyWith(isPlaying: true));
    }
  }

  Future<void> _onAddToWatchlist(
    AddToWatchlist event,
    Emitter<DetailsState> emit,
  ) async {
    if (state is DetailsLoaded) {
      final currentState = state as DetailsLoaded;

      emit(const WatchlistUpdated(
        isAdded: true,
        message: 'Added to watchlist successfully!',
      ));

      // Return to details state with updated watchlist status
      await Future.delayed(const Duration(milliseconds: 100));
      emit(currentState.copyWith(isInWatchlist: true));
    }
  }

  Future<void> _onRemoveFromWatchlist(
    RemoveFromWatchlist event,
    Emitter<DetailsState> emit,
  ) async {
    if (state is DetailsLoaded) {
      final currentState = state as DetailsLoaded;

      emit(const WatchlistUpdated(
        isAdded: false,
        message: 'Removed from watchlist',
      ));

      // Return to details state with updated watchlist status
      await Future.delayed(const Duration(milliseconds: 100));
      emit(currentState.copyWith(isInWatchlist: false));
    }
  }

  Future<void> _onLoadSimilarContent(
    LoadSimilarContent event,
    Emitter<DetailsState> emit,
  ) async {
    if (state is DetailsLoaded) {
      final currentState = state as DetailsLoaded;

      try {
        final similarContent =
            await repository.getContentByCategory(event.category);
        final filteredSimilarContent = similarContent
            .where((content) => content.id != currentState.content.id)
            .take(6)
            .toList();

        emit(currentState.copyWith(similarContent: filteredSimilarContent));
      } catch (e) {
        // Don't emit error for similar content loading failure
        // Just keep the current state
      }
    }
  }
}
