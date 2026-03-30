import 'package:cloud_firestore/cloud_firestore.dart';

class QuestModel {
  final String? id;
  final String title;
  final String description;
  final String city;
  final String startLocation;
  final String gatheringTime;
  final String difficulty;
  final String category;
  final int maxTeamSize;
  final bool isPublished;
  final DateTime? questDate;
  final DateTime? registrationDeadline;
  final String creatorId;
  final DateTime createdAt;
  final String? coverBase64;

  QuestModel({
    this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.startLocation,
    required this.gatheringTime,
    required this.difficulty,
    required this.category,
    required this.maxTeamSize,
    required this.isPublished,
    this.questDate,
    this.registrationDeadline,
    required this.creatorId,
    required this.createdAt,
    this.coverBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'city': city,
      'startLocation': startLocation,
      'gatheringTime': gatheringTime,
      'difficulty': difficulty,
      'category': category,
      'maxTeamSize': maxTeamSize,
      'isPublished': isPublished,
      'questDate': questDate,
      'registrationDeadline': registrationDeadline,
      'creatorId': creatorId,
      'createdAt': createdAt,
      'coverBase64': coverBase64,
    };
  }

  factory QuestModel.fromMap(String id, Map<String, dynamic> map) {
    return QuestModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      city: map['city'] ?? '',
      startLocation: map['startLocation'] ?? '',
      gatheringTime: map['gatheringTime'] ?? '',
      difficulty: map['difficulty'] ?? 'легкий',
      category: map['category'] ?? 'История',
      maxTeamSize: map['maxTeamSize'] ?? 4,
      isPublished: map['isPublished'] ?? true,
      questDate: (map['questDate'] as Timestamp?)?.toDate(),
      registrationDeadline:
          (map['registrationDeadline'] as Timestamp?)?.toDate(),
      creatorId: map['creatorId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      coverBase64: map['coverBase64'],
    );
  }
}
