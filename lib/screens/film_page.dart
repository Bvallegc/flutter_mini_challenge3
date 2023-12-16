import 'package:flutter/material.dart';
import '../service/movie_service.dart';
import '../models/models.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


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
    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentReference movie = FirebaseFirestore.instance.collection('users').doc(userId).collection('movies').doc('${widget.filmId}');
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

  Future<void> savePreferences(Movie movie) async {
  // Get a CollectionReference
  String userId = FirebaseAuth.instance.currentUser!.uid;

  // Get a CollectionReference
  CollectionReference movies = FirebaseFirestore.instance.collection('users').doc(userId).collection('movies');
  // Set the document with a specific ID
  return movies
    .doc('${widget.filmId}')
    .set({
      'isLiked': isLiked.value,
      'isRated': isRated,
      'title': movie.title, // store the movie title
      'poster': movie.posterPath, // store the movie poster
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
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
            height: 275,
              child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500${movie.posterPath}', 
                          width: 200.0, 
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                      ),
            ),
            const SizedBox(height: 20.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 24.0),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Title: ',
                    style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 26.0),
                  ),
                  TextSpan(
                    text: '${movie.title}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 15.0),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Overview: ',
                    style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                  TextSpan(
                    text: '${movie.overview}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 15.0),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Release Date: ',
                    style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                  TextSpan(
                    text: '${movie.releaseDate}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 15.0),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Original Language: ',
                    style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                  TextSpan(
                    text: '${movie.originalLanguage}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 15.0),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Number of votes: ',
                    style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                  TextSpan(
                    text: '${movie.voteCount}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
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
            const SizedBox(height: 20.0),
            ElevatedButton(
              child: Text('Save Changes'),
              onPressed: () => savePreferences(movie),
            ),
          ],
        ),
      ),
    ),
  );
}
}