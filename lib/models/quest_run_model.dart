import 'package:cloud_firestore/cloud_firestore.dart';
import 'checkpoint_model.dart';

class SubmissionModel {
  final String checkpointId;
  final String answer;
  final bool? isCorrect;
  final int pointsEarned;
  final DateTime timestamp;

  SubmissionModel({
    required this.checkpointId,
    required this.answer,
    this.isCorrect,
    required this.pointsEarned,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'checkpointId': checkpointId,
      'answer': answer,
      'isCorrect': isCorrect,
      'pointsEarned': pointsEarned,
      'timestamp': timestamp,
    };
  }

  factory SubmissionModel.fromMap(Map<String, dynamic> map) {
    return SubmissionModel(
      checkpointId: map['checkpointId'] ?? '',
      answer: map['answer'] ?? '',
      isCorrect: map['isCorrect'],
      pointsEarned: map['pointsEarned'] ?? 0,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}

class QuestRunData {
  final List<CheckpointModel> checkpoints;
  final int teamPoints;
  final List<SubmissionModel> submissions;

  QuestRunData({
    required this.checkpoints,
    required this.teamPoints,
    required this.submissions,
  });
}
