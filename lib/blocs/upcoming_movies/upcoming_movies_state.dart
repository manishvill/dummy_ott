import 'package:equatable/equatable.dart';
import '../../models/content_model.dart';

abstract class UpcomingMoviesState extends Equatable {
  const UpcomingMoviesState();

  @override
  List<Object?> get props => [];
}

class UpcomingMoviesInitial extends UpcomingMoviesState {
  const UpcomingMoviesInitial();
}

class UpcomingMoviesLoading extends UpcomingMoviesState {
  const UpcomingMoviesLoading();
}

class UpcomingMoviesLoaded extends UpcomingMoviesState {
  final List<ContentModel> data;

  const UpcomingMoviesLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class UpcomingMoviesError extends UpcomingMoviesState {
  final String message;

  const UpcomingMoviesError({required this.message});

  @override
  List<Object?> get props => [message];
}