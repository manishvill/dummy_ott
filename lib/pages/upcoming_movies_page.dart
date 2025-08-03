import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/upcoming_movies/upcoming_movies_bloc.dart';
import '../blocs/upcoming_movies/upcoming_movies_event.dart';
import '../blocs/upcoming_movies/upcoming_movies_state.dart';
import '../models/content_model.dart';

class UpcomingMoviesPage extends StatefulWidget {
  const UpcomingMoviesPage({super.key});

  @override
  State<UpcomingMoviesPage> createState() => _UpcomingMoviesPageState();
}

class _UpcomingMoviesPageState extends State<UpcomingMoviesPage> {
  @override
  void initState() {
    super.initState();
    context.read<UpcomingMoviesBloc>().add(const LoadUpcomingMovies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Movies'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: BlocBuilder<UpcomingMoviesBloc, UpcomingMoviesState>(
        builder: (context, state) {
          if (state is UpcomingMoviesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UpcomingMoviesLoaded) {
            // Build the content list if data is loaded
            return _buildContentList(state.data);
          } else if (state is UpcomingMoviesError) {
            // Build the error widget if an error occurred
            return _buildErrorWidget(state.message);
          }
          // Return an empty container for the initial state or any other unhandled state
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Widget to build the list of upcoming movies
  Widget _buildContentList(List<ContentModel> movies) {
    return RefreshIndicator(
      onRefresh: () async {
        // Dispatch the RefreshUpcomingMovies event when the user pulls to refresh
        context.read<UpcomingMoviesBloc>().add(const RefreshUpcomingMovies());
      },
      child: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: Image.network(
                movie.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Display a placeholder or error icon if the image fails to load
                  return const Icon(Icons.error);
                },
              ),
              title: Text(movie.title),
              subtitle: Text(movie.description),
              trailing: Text(movie.category),
              onTap: () {
                // Navigate to a detail page, passing the movie ID
                Navigator.pushNamed(
                  context,
                  '/movie_details', // Assuming a route named '/movie_details' exists
                  arguments: {'movieId': movie.id},
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Widget to display an error message
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading movies: $message',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Retry loading movies by dispatching the LoadUpcomingMovies event
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
