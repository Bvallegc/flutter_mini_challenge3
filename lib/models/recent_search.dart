class RecentSearch {
  final String title;
  final String imageUrl;
  final int? personId;
  final int filmId;
  final String mediaType;

  RecentSearch({
    required this.title,
    required this.imageUrl,
    this.personId,
    required this.filmId,
    required this.mediaType,
  });
}
