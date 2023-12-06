import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';  
import '../models/models.dart';

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

  Widget buildWatchlist() {
  return MovieSlider(
    stream: FirebaseFirestore.instance.collection('movies').where('isLiked', isEqualTo: true).snapshots(),
  );
}

  Widget buildRatedMovies() {
    return MovieSlider(
      stream: FirebaseFirestore.instance.collection('movies').where('isRated', isGreaterThan: 0).snapshots(),
    );
  }
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    String defaultUsername = "Username";
    String defaultEmail = "Email";
    return Scaffold(
      body: Container(
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
              Text(
                defaultUsername,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                defaultEmail,
                style: const TextStyle(fontSize: 20, color: Colors.grey),
              ),
              buildWatchlist(),
            ],
          ),
        ),
    );
  }
  }