import 'package:flutter/material.dart';
import '../service/movie_service.dart';
import '../models/models.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilmPage extends StatefulWidget {
  final int filmId;
  final String mediaType;

  const FilmPage({Key? key, required this.filmId, required this.mediaType}) : super(key: key);

  @override
  _FilmPageState createState() => _FilmPageState();
}

class _FilmPageState extends State<FilmPage> {
  final ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);
  double isRated = 0;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    // Get a DocumentReference
    DocumentReference movie = FirebaseFirestore.instance.collection('movies').doc('${widget.filmId}');

    // Get the document
    DocumentSnapshot snapshot = await movie.get();

    // Check if the document exists
    if (snapshot.exists) {
      // Load the saved preferences
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      isLiked.value = data['isLiked'] as bool;
      isRated = data['isRated'] as double;
    }
  }

  Future<void> savePreferences() async {
  // Get a CollectionReference
  CollectionReference movies = FirebaseFirestore.instance.collection('movies');

  // Set the document with a specific ID
  return movies
    .doc('${widget.filmId}')
    .set({
      'isLiked': isLiked.value,
      'isRated': isRated,
    })
    .then((value) => print("Preferences Saved"))
    .catchError((error) => print("Failed to save preferences: $error"));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text('Movie Details'),
    ),
    body: FutureBuilder<dynamic>(
      future: MovieService.movieDetails(widget.filmId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        } else if (snapshot.hasData) {
          Movie movie = Movie.fromJson(snapshot.data!);
          return _buildMovieDetails(movie);
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    ),
  );
  }

  Widget _buildMovieDetails(Movie movie) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage('https://image.tmdb.org/t/p/w500${movie.posterPath}')),
        const SizedBox(height: 16.0),
        Text(movie.title, style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16.0),
        Text(
          movie.overview,
          style: const TextStyle(fontSize: 16.0),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ValueListenableBuilder<bool>(
                valueListenable: isLiked,
                builder: (context, value, child) {
                  return IconButton(
                    icon: Icon(value ? Icons.thumb_up : Icons.thumb_up_alt_outlined),
                    onPressed: () {
                      isLiked.value = !isLiked.value;
                      // Handle the user liking the movie
                    },
                  );
                },
              ),
              RatingBar.builder(
                initialRating: isRated,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  print(rating);
                  isRated = rating;
                })
            ],
          ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          child: Text('Save Changes'),
          onPressed: savePreferences,
        ),
      ],
    ),
  );
}
}