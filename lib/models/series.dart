class Series {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final bool isLiked;
  final String mediaType;
  final String firstAirDate;
  final String lastAirDate;
  final int numberOfEpisodes;
  final int numberOfSeasons;
  final String originalLanguage;
  final int voteCount;

  Series({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.isLiked,
    required this.mediaType,
    required this.firstAirDate,
    required this.lastAirDate,
    required this.numberOfEpisodes,
    required this.numberOfSeasons,
    required this.originalLanguage,
    required this.voteCount,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      overview: json['overview'] ?? 'No overview available',
      posterPath: json['poster_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      isLiked: json['isLiked'] ?? false,
      mediaType: json['media_type'] ?? 'tv',
      firstAirDate: json['first_air_date'] ?? 'Unknown',
      lastAirDate: json['last_air_date'] ?? 'Unknown',
      numberOfEpisodes: (json['number_of_episodes'] ?? 0).toInt(),
      numberOfSeasons: (json['number_of_seasons'] ?? 0).toInt(),
      originalLanguage: json['original_language'] ?? 'Unknown',
      voteCount: (json['vote_count'] ?? 0).toInt()
    );
  }
}