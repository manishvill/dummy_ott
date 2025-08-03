import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/upcoming_movies/upcoming_movies_bloc.dart';
import '../blocs/upcoming_movies/upcoming_movies_event.dart';
import '../blocs/upcoming_movies/upcoming_movies_state.dart';
import '../models/content_model.dart'; // Assuming ContentModel is used for movie data

class UpcomingMoviesPage extends StatefulWidget {
  const UpcomingMoviesPage({super.key});

  @override
  State<UpcomingMoviesPage> createState() => _UpcomingMoviesPageState();
}

class _UpcomingMoviesPageState extends State<UpcomingMoviesPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch the LoadUpcomingMovies event when the page is initialized
    context.read<UpcomingMoviesBloc>().add(const LoadUpcomingMovies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Upcoming Movies',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: BlocBuilder<UpcomingMoviesBloc, UpcomingMoviesState>(
        builder: (context, state) {
          if (state is UpcomingMoviesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UpcomingMoviesLoaded) {
            return _buildMoviesList(state.data);
          } else if (state is UpcomingMoviesError) {
            return _buildErrorWidget(state.message);
          }
          // Return an empty container or a placeholder for the initial state
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMoviesList(List<ContentModel> movies) {
    if (movies.isEmpty) {
      return const Center(
        child: Text(
          'No upcoming movies found.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _buildMovieListItem(movie);
      },
    );
  }

  Widget _buildMovieListItem(ContentModel movie) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              movie.imageUrl,
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 150,
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.movie,
                    color: Colors.white54,
                    size: 48,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),
                Text(
                  movie.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4.0),
                    Text(
                      movie.rating.toString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong.',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Retry loading movies
              context
                  .read<UpcomingMoviesBloc>()
                  .add(const LoadUpcomingMovies());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
