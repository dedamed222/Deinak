class UserModel {
  final int? id;
  final String username;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final String? fullName;
  final String? country;

  UserModel({
    this.id,
    required this.username,
    required this.passwordHash,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isVerified = false,
    this.fullName,
    this.country,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_verified': isVerified,
      'full_name': fullName,
      'country': country,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      passwordHash: map['password_hash'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isVerified: map['is_verified'] ?? false,
      fullName: map['full_name'],
      country: map['country'],
    );
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    String? fullName,
    String? country,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      fullName: fullName ?? this.fullName,
      country: country ?? this.country,
    );
  }
}
