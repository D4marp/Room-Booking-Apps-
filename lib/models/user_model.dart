enum UserRole { user, admin, booking }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? city;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserRole role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.city,
    required this.createdAt,
    this.updatedAt,
    this.role = UserRole.user,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'],
      city: json['city'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : null,
      role: json['role'] == 'admin' 
          ? UserRole.admin 
          : json['role'] == 'booking'
          ? UserRole.booking
          : UserRole.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'city': city,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'role': role == UserRole.admin ? 'admin' : role == UserRole.booking ? 'booking' : 'user',
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserRole? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
    );
  }

  bool get isAdmin => role == UserRole.admin;
}
