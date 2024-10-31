class User {
  final int userId;
  final String firstName;
  final String lastName;
  final int points;

  User({required this.userId, required this.firstName, required this.lastName, required this.points});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      points: json['points'],
    );
  }
}