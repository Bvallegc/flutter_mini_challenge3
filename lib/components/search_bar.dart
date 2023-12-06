import 'package:flutter/material.dart';
import '../models/models.dart';
import '../service/movie_service.dart';

final MovieService _tmdbService = MovieService();

class SearchBarWidget extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onBrightnessToggle;
  final ValueChanged<String> onSearch;
  final VoidCallback onSubmit;

  const SearchBarWidget({
    Key? key,

    required this.isDark,
    required this.onBrightnessToggle,
    required this.onSearch,
    required this.onSubmit,

  }) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          onTap: () {
            controller.openView();
          },
          onChanged: (query) {
            // Invoke the onSearch callback with the entered query
            onSearch(query);
            controller.openView();
          },
          
          onSubmitted: (query) {
            // Invoke the onSearch callback with the entered query when submitted
            onSearch(query);
            controller.closeView(""); // Pass an empty string as the argument
          },
          
          leading: const Icon(Icons.search),
          trailing: <Widget>[
            IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: onSubmit, // Call the submit callback
                )
          ],
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) async {
        List<Movie> movies = await MovieService.movieSuggestion(controller.text);

        return movies.map((Movie movie) {
          return ListTile(
            title: Text(movie.title),
            onTap: () {
              controller.closeView(movie.title); // or use a unique identifier for the movie
            },
          );
        }).toList();
      },
    );
  }
}
