import 'package:flutter/material.dart';
import '../service/movie_service.dart';
import '../models/models.dart';

class ActorPage extends StatelessWidget {
  final int actorId;
  final String mediaType;
  const ActorPage({Key? key, required this.actorId, required this.mediaType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text('Actor Details'),
    ),
    body: FutureBuilder<dynamic>(
      future: MovieService.actorDetails(actorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        } else if (snapshot.hasData) {
          Actor actor = Actor.fromJson(snapshot.data!);
          return _buildActorDetails(actor);
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    ),
  );
  }

  Widget _buildActorDetails(Actor actor) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://image.tmdb.org/t/p/w500${actor.profilePath}')),
            const SizedBox(height: 16.0),
            Text(actor.name, style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            Text(
              actor.biography,
              style: const TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}