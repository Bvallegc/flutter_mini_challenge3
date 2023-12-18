import 'package:flutter/material.dart';
import '../service/movie_service.dart';
import '../models/models.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SeriesPage extends StatefulWidget {
  final int seriesId;
  final String mediaType;

  const SeriesPage({Key? key, required this.seriesId, required this.mediaType}) : super(key: key);

  @override
  _SeriesPageState createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  final ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);
  double isRated = 0;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentReference series = FirebaseFirestore.instance.collection('users').doc(userId).collection('series').doc('${widget.seriesId}');
    // Get the document
    DocumentSnapshot snapshot = await series.get();

    // Check if the document exists
    if (snapshot.exists) {
      // Load the saved preferences
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      isLiked.value = data['isLiked'] as bool;
      isRated = data['isRated'] as double;
      
    }
  }

  Future<void> savePreferences(Series series) async {
  // Get a CollectionReference
  String userId = FirebaseAuth.instance.currentUser!.uid;

  // Get a CollectionReference
  CollectionReference series = FirebaseFirestore.instance.collection('users').doc(userId).collection('series');
  // Set the document with a specific ID
  return series
    .doc('${widget.seriesId}')
    .get()
    .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        return series
          .doc('${widget.seriesId}')
          .set({
            'isLiked': isLiked.value,
            'isRated': isRated,
            'title': data['name'], // store the series title
            'poster': data['poster_path'], // store the series poster
          })
          .then((value) => print("Preferences Saved"))
          .catchError((error) => print("Failed to save preferences: $error"));
      } else {
        print("Document does not exist");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text('Series Details'),
    ),
    body: FutureBuilder<dynamic>(
      future: MovieService.tvShowDetails(widget.seriesId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        } else if (snapshot.hasData) {
          Series series = Series.fromJson(snapshot.data!);
          return _buildSeriesDetails(series);
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    ),
  );
  }

  Widget _buildSeriesDetails(Series series) {
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
                          'https://image.tmdb.org/t/p/w500${series.posterPath}', 
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
                    text: '${series.name}',
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
                    text: '${series.overview}',
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
                    text: 'First air date: ',
                    style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                  TextSpan(
                    text: '${series.firstAirDate}',
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
                    text: 'Last air date: ',
                    style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                  TextSpan(
                    text: '${series.lastAirDate}',
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
                    text: '${series.originalLanguage}',
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
                    text: '${series.voteCount}',
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
              onPressed: () => savePreferences(series),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
