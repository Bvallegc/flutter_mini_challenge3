import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../service/movie_service.dart';
import '../components/components.dart';
import '../models/models.dart';
import '../screens/export_screens.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MovieService _tmdbService = MovieService();
  List<Movie> allMovies = [];
  List<Movie> displayedMovies = [];
  List<dynamic> searchResults = [];
  List<RecentSearch> recentSearches = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void addToRecentSearches(String title, String imageUrl, int id, String mediaType) {
    var newSearch = RecentSearch(
      title: title,
      imageUrl: imageUrl,
      personId: mediaType == 'person' ? id : null,
      filmId: mediaType != 'person' ? id : 0, // 0 as a placeholder
      mediaType: mediaType,
    );

    if (!recentSearches.any((rs) => rs.title == newSearch.title && rs.imageUrl == newSearch.imageUrl)) {
      setState(() {
        recentSearches.insert(0, newSearch);
        if (recentSearches.length > 10) {
          recentSearches.removeRange(10, recentSearches.length);
        }
      });
    }
  }

  void performSearch(String query) async {
    if (query.isNotEmpty) {
      setState(() => isLoading = true);
      var results = await _tmdbService.searchMovies(query);
      setState(() {
        searchResults = results['results'];
        isLoading = false;
      });
    } else {
      setState(() {
        searchResults = [];
        isLoading = false;
      });
    }
  }

  Future<bool> _isImageAvailable(String url) async {
  try {
    final response = await http.head(Uri.parse(url));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

  Widget _buildSearchResults(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (searchResults.isNotEmpty) {
      return Expanded(
        child: ListView.builder(
          itemCount: searchResults.length > 10 ? 10 : searchResults.length,
          itemBuilder: (context, index) {
            var result = searchResults[index];
            String title = result['title'] ?? result['name'] ?? 'Unknown';
            String imageUrl = 'https://image.tmdb.org/t/p/w500';
            int id = result['id'];
            String mediaType = result['media_type'];
            print('id , $id');
            //print('Result: $result');

            if (mediaType == 'person') {
              imageUrl += result['profile_path'] ?? '';
              return ListTile(
                title: Text(title),
                leading: _buildImage(imageUrl),
                onTap: () {
                  addToRecentSearches(title, imageUrl, id, mediaType);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActorPage(actorId: id, mediaType: mediaType),
                    ),
                  );
                },
              );
            } else if (mediaType == 'tv') {
              imageUrl += result['poster_path'] ?? '';
              return ListTile(
                title: Text(title),
                leading: _buildImage(imageUrl),
                onTap: () {
                  addToRecentSearches(title, imageUrl, id, mediaType);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeriesPage(seriesId: id, mediaType: mediaType), // Assuming you have a SeriesPage
                    ),
                  );
                },
              );
            } else {
              imageUrl += result['poster_path'] ?? '';
              return ListTile(
                title: Text(title),
                leading: _buildImage(imageUrl),
                onTap: () {
                  addToRecentSearches(title, imageUrl, id, mediaType);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FilmPage(filmId: id, mediaType: mediaType),
                    ),
                  );
                },
              );
            }
          },
        ),
      );
    } else {
      return const SizedBox(); // Empty container when there are no search results
    }
  }

   Widget _buildImage(String url) {
    return FutureBuilder<bool>(
    future: _isImageAvailable(url),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError || snapshot.data == false) {
        // If there's an error or the image is not available, show a placeholder or default image
        return const Icon(Icons.error);
      } else {
        // If the image is available, load it
        return Image.network(
          url,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        );
      }
    },
  );
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: performSearch,
            decoration: InputDecoration(
              labelText: 'Search Movies, TV Shows, Actors',
              labelStyle: TextStyle(color: Colors.blueGrey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.blueGrey),
                onPressed: () {
                  _searchController.clear();
                  performSearch('');
                },
              ),
            ),
          ),
          SizedBox(height: 20.0),
          _buildSearchResults(context),
          SizedBox(height: 20.0),
          Text('Recent Searches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          Expanded(
            child: RecentSearchesWidget(recentSearches: recentSearches),
          ),
        ],
      ),
    ),
  );
}
}