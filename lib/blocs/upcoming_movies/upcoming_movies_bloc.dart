import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/dummy_content_repository.dart'; // Assuming this repository can provide upcoming movies
import 'upcoming_movies_event.dart';
import 'upcoming_movies_state.dart';

class UpcomingMoviesBloc extends Bloc<UpcomingMoviesEvent, UpcomingMoviesState> {
  final DummyContentRepository repository;

  UpcomingMoviesBloc({required this.repository}) : super(const UpcomingMoviesInitial()) {
    on<LoadUpcomingMovies>(_onLoadUpcomingMovies);
    on<RefreshUpcomingMovies>(_onRefreshUpcomingMovies);
    on<UpdateUpcomingMovieItem>(_onUpdateUpcomingMovieItem);
  }

  Future<void> _onLoadUpcomingMovies(
    LoadUpcomingMovies event,
    Emitter<UpcomingMoviesState> emit,
  ) async {
    try {
      emit(const UpcomingMoviesLoading());
      // Assuming the repository has a method to get upcoming movies
      final data = await repository.getUpcomingMovies();
      emit(UpcomingMoviesLoaded(data: data));
    } catch (error) {
      emit(UpcomingMoviesError(message: error.toString()));
    }
  }

  Future<void> _onRefreshUpcomingMovies(
    RefreshUpcomingMovies event,
    Emitter<UpcomingMoviesState> emit,
  ) async {
    try {
      // Assuming the repository has a method to get upcoming movies
      final data = await repository.getUpcomingMovies();
      emit(UpcomingMoviesLoaded(data: data));
    } catch (error) {
      emit(UpcomingMoviesError(message: error.toString()));
    }
  }

  Future<void> _onUpdateUpcomingMovieItem(
    UpdateUpcomingMovieItem event,
    Emitter<UpcomingMoviesState> emit,
  ) async {
    try {
      // Add your update logic here for a specific movie item
      // For example, fetching updated details for the movie with event.movieId
      // and then emitting a new state if necessary.
    } catch (error) {
      emit(UpcomingMoviesError(message: error.toString()));
    }
  }
}   