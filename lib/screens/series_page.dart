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
  Series? series;

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

  Future<void> savePreferences2(Series series) async {
  // Get a CollectionReference
  String userId = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference seriesRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('seriesList');

  // Show a dialog with two options.
  String action = await showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Save to existing list'),
            onTap: () => Navigator.pop(dialogContext, 'existing'),
          ),
          ListTile(
            title: const Text('Add to new list'),
            onTap: () => Navigator.pop(dialogContext, 'new'),
          ),
        ],
      ),
    ),
  );

  if (action == 'existing') {
    // Handle saving to existing list.
    _handleSaveToExistingList(series, seriesRef, context);
  } else if (action == 'new') {
    // Handle adding to new list.
   String newListName = await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('New list name'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'List name',
          ),
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
      ),
    );

    // Handle adding to new list.
    _handleAddToNewList(series, seriesRef, newListName);
  }
}

  void _handleSaveToExistingList(Series series, CollectionReference seriesRef, BuildContext context) async {
  // Fetch all the documents from the seriesRef collection.
  QuerySnapshot querySnapshot = await seriesRef.get();
  List<QueryDocumentSnapshot> docs = querySnapshot.docs;

  // Extract the list names from the documents.
  List<String> listNames = docs.map((doc) => doc.id).toList();

  // Display the list names in a dialog.
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select a list'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: listNames.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(listNames[index]),
                onTap: () {
                  // Add the series to the selected list and close the dialog.
                  _addSeriesToList(series, seriesRef, docs[index].id);
                  Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _addSeriesToList(Series series, CollectionReference seriesRef, String listId) async {
    // Add the series to an existing list in your database.
    await seriesRef.doc(listId).update({
      'series': FieldValue.arrayUnion([{
        'id': series.id, // store the series id
        'isLiked': isLiked.value,
        'isRated': isRated,
        'title': series.name, // store the series title
        'posterPath': series.posterPath, // store the series poster
      }]),
    });
  }

  void _handleAddToNewList(Series series, CollectionReference seriesRef, String newListName) async {
  // Add the series to a new list in your database.
  await seriesRef.doc(newListName).set({
    'series': FieldValue.arrayUnion([{
      'id': series.id,
      'title': series.name,
      'isRated': isRated,
      'isLiked': isLiked.value,
      'posterPath': series.posterPath,
      }]),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Series Details'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (series != null) {
                savePreferences2(series!);
              }
            },
          ),
        ],
      ),
    body: FutureBuilder<dynamic>(
      future: MovieService.tvShowDetails(widget.seriesId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        } else if (snapshot.hasData) {
          series = Series.fromJson(snapshot.data!);
          return _buildSeriesDetails(series!);
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
