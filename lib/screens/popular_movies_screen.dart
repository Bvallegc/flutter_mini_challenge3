import 'package:flutter/material.dart';
import '../service/movie_service.dart';
import '../models/models.dart';

class PopularScreen extends StatelessWidget {
  final movieService = MovieService();

  PopularScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          FutureBuilder(
            future: MovieService.fetchPopMovies(),
            builder: (context, AsyncSnapshot<List<Movie>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return MovieSlider(movies: snapshot.data ?? [], title: 'Popular movies',);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          FutureBuilder(
            future: MovieService.fetchTopMovies(),
            builder: (context, AsyncSnapshot<List<Movie>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return MovieSlider(movies: snapshot.data ?? [], title: 'Top Rated Movies');
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          FutureBuilder(
            future: MovieService.fetchNowPlayingMovies(),
            builder: (context, AsyncSnapshot<List<Movie>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return MovieSlider(movies: snapshot.data ?? [], title: 'Now Playing Movies');
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          FutureBuilder(
            future: MovieService.fetchUpcomingMovies(),
            builder: (context, AsyncSnapshot<List<Movie>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return MovieSlider(movies: snapshot.data ?? [], title: 'Upcoming Movies');
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }
}