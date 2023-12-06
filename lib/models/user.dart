class User {
  final String? id;
  final String username;
  final String email;
  final String password;
  final String fullname;


  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.fullname, 
  });
  toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'fullname': fullname,
    };
  }
}