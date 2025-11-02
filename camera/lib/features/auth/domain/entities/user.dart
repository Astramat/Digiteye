import 'package:equatable/equatable.dart';

/// Entité utilisateur du domaine
class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
  });
  
  /// Nom complet de l'utilisateur
  String get fullName => '$firstName $lastName';
  
  /// Initiales de l'utilisateur
  String get initials => '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}';
  
  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    phone,
    avatar,
    createdAt,
    updatedAt,
    isEmailVerified,
  ];
  
  /// Copie l'entité avec de nouvelles valeurs
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
