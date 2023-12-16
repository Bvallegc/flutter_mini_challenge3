class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final bool isLiked;
  final String mediaType;
  final String releaseDate;
  final String originalLanguage;
  final int voteCount;
  final String? backdropPath;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.isLiked,
    required this.mediaType,
    required this.releaseDate,
    required this.originalLanguage,
    required this.voteCount,
    this.backdropPath,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      overview: json['overview'] ?? 'No overview available',
      posterPath: json['poster_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      isLiked: json['isLiked'] ?? false,
      mediaType: json['media_type'] ?? 'movie',
      releaseDate: json['release_date'] ?? 'Unknown',
      originalLanguage: json['original_language'] ?? 'Unknown',
      voteCount: json['vote_count'].toInt(),
      backdropPath: json['backdrop_path'],
    );
  }
}