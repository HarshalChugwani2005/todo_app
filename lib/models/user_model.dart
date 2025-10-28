class User {
  String id;
  String name;
  String email;
  DateTime? createdAt;
  DateTime? lastLoginAt;
  bool isEmailVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      isEmailVerified: json['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, isEmailVerified: $isEmailVerified)';
  }
}