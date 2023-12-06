import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../models/models.dart';
import '../service/movie_service.dart';

class MovieSlider extends StatelessWidget {
  final Stream<QuerySnapshot> stream;

  MovieSlider({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String? movieId = data['movieId'];
              print('Data: $data');
              print('movieId: $movieId');

              if (movieId != null) {
                return FutureBuilder<dynamic>(
                  future: MovieService.movieDetails(int.parse(movieId)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      Movie movie = snapshot.data!;
                      return Container(
                        width: 130,
                        child: Column(
                          children: [
                            movie.posterPath != null 
                              ? Image.network('https://image.tmdb.org/t/p/w500${movie.posterPath}')
                              : Image.asset('assets/images/placeholder.png'), // Replace with your placeholder image
                            Text(movie.title ?? ''),
                          ],
                        ),
                      );
                    }
                  },
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        );
      },
    );
  }
}