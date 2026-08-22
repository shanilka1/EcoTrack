import 'package:cloud_firestore/cloud_firestore.dart';

/// Application User Profile Model stored in Cloud Firestore `users/{uid}`
class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String? photoUrl;
  final String role;
  final int ecoPoints;
  final int level;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl,
    this.role = 'user',
    this.ecoPoints = 0,
    this.level = 1,
    required this.createdAt,
  });

  /// Factory constructor to create a default new user profile upon registration
  factory UserModel.createDefault({
    required String uid,
    required String fullName,
    required String email,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      photoUrl: photoUrl,
      role: 'user',
      ecoPoints: 0,
      level: 1,
      createdAt: DateTime.now(),
    );
  }

  /// Converts the user model into a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'ecoPoints': ecoPoints,
      'level': level,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a UserModel from a Map / Firestore document data
  factory UserModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime parsedCreatedAt;
    final rawCreatedAt = map['createdAt'];

    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else if (rawCreatedAt is int) {
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return UserModel(
      uid: map['uid'] as String? ?? documentId ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      role: map['role'] as String? ?? 'user',
      ecoPoints: (map['ecoPoints'] as num?)?.toInt() ?? 0,
      level: (map['level'] as num?)?.toInt() ?? 1,
      createdAt: parsedCreatedAt,
    );
  }

  /// Creates a UserModel from a Firestore DocumentSnapshot
  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return UserModel.fromMap(data, documentId: snapshot.id);
  }

  /// Creates a copy of the user model with updated fields
  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? photoUrl,
    String? role,
    int? ecoPoints,
    int? level,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      ecoPoints: ecoPoints ?? this.ecoPoints,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.uid == uid &&
        other.fullName == fullName &&
        other.email == email &&
        other.photoUrl == photoUrl &&
        other.role == role &&
        other.ecoPoints == ecoPoints &&
        other.level == level &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      uid,
      fullName,
      email,
      photoUrl,
      role,
      ecoPoints,
      level,
      createdAt,
    );
  }
}
