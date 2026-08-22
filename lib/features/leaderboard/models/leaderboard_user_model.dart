import 'package:cloud_firestore/cloud_firestore.dart';

/// Lightweight, privacy-safe Public Profile model for Leaderboard entries
class LeaderboardUserModel {
  final String uid;
  final String fullName;
  final String? photoUrl;
  final int ecoPoints;
  final int level;
  final int rank;

  const LeaderboardUserModel({
    required this.uid,
    required this.fullName,
    this.photoUrl,
    required this.ecoPoints,
    required this.level,
    this.rank = 0,
  });

  /// Creates a LeaderboardUserModel safely from Firestore document data
  factory LeaderboardUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, {
    int rank = 0,
  }) {
    final data = snapshot.data() ?? {};
    return LeaderboardUserModel(
      uid: snapshot.id,
      fullName: data['fullName'] as String? ?? 'Eco Warrior',
      photoUrl: data['photoUrl'] as String?,
      ecoPoints: (data['ecoPoints'] as num?)?.toInt() ?? 0,
      level: (data['level'] as num?)?.toInt() ?? 1,
      rank: rank,
    );
  }

  /// Creates a LeaderboardUserModel safely from Map
  factory LeaderboardUserModel.fromMap(
    Map<String, dynamic> map, {
    String? uid,
    int rank = 0,
  }) {
    return LeaderboardUserModel(
      uid: map['uid'] as String? ?? uid ?? '',
      fullName: map['fullName'] as String? ?? 'Eco Warrior',
      photoUrl: map['photoUrl'] as String?,
      ecoPoints: (map['ecoPoints'] as num?)?.toInt() ?? 0,
      level: (map['level'] as num?)?.toInt() ?? 1,
      rank: rank,
    );
  }

  /// Copies model with updated rank
  LeaderboardUserModel copyWithRank(int newRank) {
    return LeaderboardUserModel(
      uid: uid,
      fullName: fullName,
      photoUrl: photoUrl,
      ecoPoints: ecoPoints,
      level: level,
      rank: newRank,
    );
  }
}
