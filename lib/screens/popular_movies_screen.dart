import 'package:flutter/material.dart';
import '../service/movie_service.dart';
import '../models/models.dart';

class PopularScreen extends StatelessWidget {
  final movieService = MovieService();

  PopularScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: MovieService.fetchMovies(),
        builder: (context, AsyncSnapshot<List<Movie>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MovieListView(movies: snapshot.data ?? []);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
