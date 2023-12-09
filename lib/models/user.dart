class User {
  final String? id;
  final String username;
  final String email;
  final String password;


  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
  });
  toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
    };
  }
}