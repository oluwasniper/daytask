class User {
  final String id;
  final String email;
  final String name;

  User({required this.id, required this.email, required this.name});

  // Named constructor for creating User from JSON
  User.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      email = json['email'],
      name = json['name'];

  // Method to convert User to JSON
  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'name': name};

  // Optional: Override toString for better debugging
  @override
  String toString() => 'User(id: $id, email: $email, name: $name)';

  // Optional: Override equality operators
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ name.hashCode;
}
