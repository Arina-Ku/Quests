import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/submission_model.dart';

class SubmissionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получение ответов команды по квесту
  Stream<List<SubmissionModel>> getSubmissionsByTeam(String teamId) {
    return _firestore
        .collection('submissions')
        .where('teamId', isEqualTo: teamId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubmissionModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Получение ответов на конкретную точку
  Stream<List<SubmissionModel>> getSubmissionsByCheckpoint(
      String checkpointId) {
    return _firestore
        .collection('submissions')
        .where('checkpointId', isEqualTo: checkpointId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubmissionModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Сохранение ответа
  Future<void> saveSubmission(SubmissionModel submission) async {
    await _firestore.collection('submissions').add(submission.toMap());
  }

  // Обновление ответа (после проверки)
  Future<void> updateSubmission(
    String id, {
    bool? isCorrect,
    int? pointsEarned,
  }) async {
    final data = <String, dynamic>{};
    if (isCorrect != null) data['isCorrect'] = isCorrect;
    if (pointsEarned != null) data['pointsEarned'] = pointsEarned;

    await _firestore.collection('submissions').doc(id).update(data);
  }

  // Получение статистики по квесту (для организатора)
  Future<Map<String, dynamic>> getQuestStatistics(String questId) async {
    // Получаем все команды квеста
    final teams = await _firestore
        .collection('teams')
        .where('questId', isEqualTo: questId)
        .get();

    // Получаем все точки квеста
    final checkpoints = await _firestore
        .collection('checkpoints')
        .where('questId', isEqualTo: questId)
        .get();

    // Получаем все ответы на эти точки
    final allSubmissions = <SubmissionModel>[];
    for (var team in teams.docs) {
      final subs = await _firestore
          .collection('submissions')
          .where('teamId', isEqualTo: team.id)
          .get();
      allSubmissions.addAll(
          subs.docs.map((doc) => SubmissionModel.fromMap(doc.id, doc.data())));
    }

    return {
      'totalTeams': teams.docs.length,
      'totalCheckpoints': checkpoints.docs.length,
      'totalSubmissions': allSubmissions.length,
      'averagePoints': allSubmissions.isEmpty
          ? 0
          : allSubmissions.fold(0, (sum, s) => sum + s.pointsEarned) /
              allSubmissions.length,
    };
  }
}
