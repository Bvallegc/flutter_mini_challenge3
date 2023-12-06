class Actor {
  final int id;
  final String name;
  final String biography;
  final String? profilePath;

  Actor({
    required this.id,
    required this.name,
    required this.biography,
    this.profilePath,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id'],
      name: json['name'],
      biography: json['biography'],
      profilePath: json['profile_path'],
    );
  }
}