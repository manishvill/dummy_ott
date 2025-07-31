import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_event.dart';
import '../blocs/category/category_state.dart';
import '../models/content_model.dart';
import 'details_page.dart';

class CategoryPage extends StatefulWidget {
  final String? selectedCategory;

  const CategoryPage({
    super.key,
    this.selectedCategory,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String? currentCategory;

  @override
  void initState() {
    super.initState();
    currentCategory = widget.selectedCategory;

    if (currentCategory != null) {
      context.read<CategoryBloc>().add(FilterByCategory(currentCategory!));
    } else {
      context.read<CategoryBloc>().add(const LoadAllCategoryContent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentCategory != null
              ? '$currentCategory Movies'
              : 'All Categories',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          }

          if (state is CategoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (currentCategory != null) {
                        context.read<CategoryBloc>().add(
                              FilterByCategory(currentCategory!),
                            );
                      } else {
                        context
                            .read<CategoryBloc>()
                            .add(const LoadAllCategoryContent());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CategoryLoaded) {
            return Column(
              children: [
                // Category Filter Chips
                if (state.categories.isNotEmpty)
                  _buildCategoryFilters(state.categories),

                // Content Grid
                Expanded(
                  child: _buildContentGrid(state.filteredContent),
                ),
              ],
            );
          }

          return const Center(
            child: Text(
              'No content available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilters(List<Category> categories) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" filter chip
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('All'),
                selected: currentCategory == null,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      currentCategory = null;
                    });
                    context
                        .read<CategoryBloc>()
                        .add(const ClearCategoryFilter());
                  }
                },
                selectedColor: Colors.red,
                backgroundColor: Colors.grey[800],
                labelStyle: TextStyle(
                  color:
                      currentCategory == null ? Colors.white : Colors.white70,
                ),
              ),
            );
          }

          final category = categories[index - 1];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category.name),
              selected: currentCategory == category.name,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    currentCategory = category.name;
                  });
                  context.read<CategoryBloc>().add(
                        FilterByCategory(category.name),
                      );
                }
              },
              selectedColor: Colors.red,
              backgroundColor: Colors.grey[800],
              labelStyle: TextStyle(
                color: currentCategory == category.name
                    ? Colors.white
                    : Colors.white70,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentGrid(List<ContentModel> content) {
    if (content.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              color: Colors.white54,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No content found in this category',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: content.length,
      itemBuilder: (context, index) {
        final item = content[index];
        return _buildContentCard(item);
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 6;
    if (width > 800) return 4;
    if (width > 600) return 3;
    return 2;
  }

  Widget _buildContentCard(ContentModel content) {
    return GestureDetector(
      onTap: () => _navigateToDetails(content),
      child: Card(
        color: Colors.grey[900],
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  content.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
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
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content.category,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          content.rating.toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(ContentModel content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(content: content),
      ),
    );
  }
}
