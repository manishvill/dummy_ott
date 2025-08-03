import 'package:equatable/equatable.dart';

abstract class UpcomingMoviesEvent extends Equatable {
  const UpcomingMoviesEvent();

  @override
  List<Object?> get props => [];
}

class LoadUpcomingMovies extends UpcomingMoviesEvent {
  const LoadUpcomingMovies();
}

class RefreshUpcomingMovies extends UpcomingMoviesEvent {
  const RefreshUpcomingMovies();
}

class UpdateUpcomingMovieItem extends UpcomingMoviesEvent {
  final String movieId;

  const UpdateUpcomingMovieItem(this.movieId);

  @override
  List<Object?> get props => [movieId];
}      