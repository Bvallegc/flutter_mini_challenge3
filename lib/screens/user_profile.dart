import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';  
import '../models/export_to_user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xffeef444c);
  String profilePicLink = "";

  Future pickUploadProfilePic() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 90,
    );

    Reference ref = FirebaseStorage.instance
        .ref().child("profilepic.jpg");

    await ref.putFile(File(image!.path));

    ref.getDownloadURL().then((value) async {
      setState(() {
       profilePicLink = value;
      });
    });
  }

  Future<DocumentSnapshot> getUserData() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  } else {
    throw Exception('User is not logged in');
  }
}
  Future<List<Movie>> loadPreferencesLiked() async {
    // Get a CollectionReference
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Get a CollectionReference
    CollectionReference movies = FirebaseFirestore.instance.collection('users').doc(userId).collection('movies');

    // Get the documents
    QuerySnapshot snapshot = await movies.get();

    // Map each document to a Movie object
    List<Movie> movieList = snapshot.docs.map((doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if (data['isLiked'] as bool){
      return Movie(
        id: int.parse(doc.id),
        overview: data['overview'] as String? ?? "",
        isLiked: data['isLiked'] as bool,
        voteAverage: data['isRated'] as double,
        title: data['title'] as String,
        posterPath: data['poster'] as String,
      );
    }
  }).where((movie) => movie != null).toList().cast<Movie>();

  return movieList;
 }

  Future<List<Movie>> loadPreferencesRated() async {
    // Get a CollectionReference
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Get a CollectionReference
    CollectionReference movies = FirebaseFirestore.instance.collection('users').doc(userId).collection('movies');

    // Get the documents
    QuerySnapshot snapshot = await movies.get();

    // Map each document to a Movie object
    List<Movie> movieList = snapshot.docs.map((doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if (data['isRated'] as double >= 0){
      return Movie(
        id: int.parse(doc.id),
        overview: data['overview'] as String? ?? "",
        isLiked: data['isLiked'] as bool,
        voteAverage: data['isRated'] as double,
        title: data['title'] as String,
        posterPath: data['poster'] as String,
      );
    }
  }).where((movie) => movie != null).toList().cast<Movie>();

  return movieList;
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    String defaultUsername = "Username";
    String defaultEmail = "Email";
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Center children horizontally
              children: [
                GestureDetector(
                  onTap: () {
                    pickUploadProfilePic();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    height: 120,
                    width: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: primary,
                    ),
                    child: profilePicLink.isEmpty ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 80,
                      ) : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(profilePicLink),
                      ),
                    ),
                  ),
                FutureBuilder<DocumentSnapshot>(
                  future: getUserData(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        children: [
                          Text(
                            data['username'],
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            FirebaseAuth.instance.currentUser!.email!,
                            style: const TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  height: 350,
                  child: FutureBuilder<List<Movie>>(
                  future: loadPreferencesLiked(),
                  builder: (BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return MovieSlider(movies: snapshot.data!, title: 'Your watchList');
                    }
                  },
                              ),
                ),
                Container(
                  height: 350,
                  child: FutureBuilder<List<Movie>>(
                  future: loadPreferencesRated(),
                  builder: (BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return MovieSlider(movies: snapshot.data!,  title: 'Your ratedList');
                    }
                  },
                ),
                )
              ],
            ),
          ),
      ),
    );
  }
  }