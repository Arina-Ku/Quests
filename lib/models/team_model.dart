import 'package:cloud_firestore/cloud_firestore.dart';

class TeamModel {
  final String? id;
  final String name;
  final String captainId;
  final List<String> memberIds;
  final String questId;
  final DateTime createdAt;
  final int totalPoints;
  final DateTime? finishedAt;

  TeamModel({
    this.id,
    required this.name,
    required this.captainId,
    required this.memberIds,
    required this.questId,
    required this.createdAt,
    required this.totalPoints,
    this.finishedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'captainId': captainId,
      'memberIds': memberIds,
      'questId': questId,
      'createdAt': createdAt,
      'totalPoints': totalPoints,
      'finishedAt': finishedAt,
    };
  }

  factory TeamModel.fromMap(String id, Map<String, dynamic> map) {
    return TeamModel(
      id: id,
      name: map['name'] ?? '',
      captainId: map['captainId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      questId: map['questId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      totalPoints: map['totalPoints'] ?? 0,
      finishedAt: (map['finishedAt'] as Timestamp?)?.toDate(),
    );
  }
}
