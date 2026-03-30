import 'package:cloud_firestore/cloud_firestore.dart';

class CheckpointModel {
  final String id;
  final String questId;
  final int orderNumber;
  final String title;
  final String description;
  final String task;
  final String taskType;
  final String answer;
  final String qrCode;
  final double? latitude;
  final double? longitude;
  final int pointsReward;
  final String hint;

  CheckpointModel({
    required this.id,
    required this.questId,
    required this.orderNumber,
    required this.title,
    required this.description,
    required this.task,
    required this.taskType,
    required this.answer,
    required this.qrCode,
    this.latitude,
    this.longitude,
    required this.pointsReward,
    required this.hint,
  });

  Map<String, dynamic> toMap() {
    return {
      'questId': questId,
      'orderNumber': orderNumber,
      'title': title,
      'description': description,
      'task': task,
      'taskType': taskType,
      'answer': answer,
      'qrCode': qrCode,
      'latitude': latitude,
      'longitude': longitude,
      'pointsReward': pointsReward,
      'hint': hint,
    };
  }

  factory CheckpointModel.fromMap(String id, Map<String, dynamic> map) {
    return CheckpointModel(
      id: id,
      questId: map['questId'] ?? '',
      orderNumber: map['orderNumber'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      task: map['task'] ?? '',
      taskType: map['taskType'] ?? 'text',
      answer: map['answer'] ?? '',
      qrCode: map['qrCode'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      pointsReward: map['pointsReward'] ?? 10,
      hint: map['hint'] ?? '',
    );
  }
}
