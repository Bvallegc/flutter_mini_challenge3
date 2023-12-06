import 'package:flutter/material.dart';
import '../models/models.dart';
import '../screens/export_screens.dart';

class RecentSearchesWidget extends StatelessWidget {
  final List<RecentSearch> recentSearches;

  const RecentSearchesWidget({Key? key, required this.recentSearches}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: recentSearches.length,
      itemBuilder: (context, index) {
        var search = recentSearches[index];
        return ListTile(
          title: Text(search.title),
          subtitle: Text('Media Type: ${search.mediaType}'),
          // You can add more details or customize as per your UI design
          // For example, you might want to show images or different details based on media type
          onTap: () {
            if (search.mediaType == 'person' && search.personId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ActorPage(actorId: search.personId!, mediaType: search.mediaType)),
              );
            }
            // Navigate to FilmPage if it's a movie
            else if (search.mediaType != 'person') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FilmPage(filmId: search.filmId, mediaType: search.mediaType)),
              );
            }
          },
        );
      },
    );
  }
}