import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/checkpoint_model.dart';
import '../models/quest_run_model.dart';

class QuestRunRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Загрузка контрольных точек
  Future<List<CheckpointModel>> loadCheckpoints(String questId) async {
    final snapshot = await _firestore
        .collection('checkpoints')
        .where('questId', isEqualTo: questId)
        .orderBy('orderNumber')
        .get();

    return snapshot.docs
        .map((doc) => CheckpointModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Загрузка очков команды
  Future<int> loadTeamPoints(String teamId) async {
    final teamDoc = await _firestore.collection('teams').doc(teamId).get();
    return teamDoc.data()?['totalPoints'] ?? 0;
  }

  // Загрузка ответов команды
  Future<List<SubmissionModel>> loadSubmissions(String teamId) async {
    final snapshot = await _firestore
        .collection('submissions')
        .where('teamId', isEqualTo: teamId)
        .orderBy('timestamp')
        .get();

    return snapshot.docs
        .map((doc) => SubmissionModel.fromMap(doc.data()))
        .toList();
  }

  // Сохранение ответа
  Future<void> saveSubmission({
    required String checkpointId,
    required String teamId,
    required String answer,
  }) async {
    await _firestore.collection('submissions').add({
      'checkpointId': checkpointId,
      'teamId': teamId,
      'answer': answer,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Расчёт результатов и обновление очков
  Future<int> calculateAndUpdateResults({
    required List<CheckpointModel> checkpoints,
    required List<SubmissionModel> submissions,
    required String teamId,
  }) async {
    int totalPoints = 0;

    for (int i = 0; i < checkpoints.length; i++) {
      final checkpoint = checkpoints[i];
      final correctAnswer = checkpoint.answer.toLowerCase().trim();

      final submission = submissions.firstWhere(
        (s) => s.checkpointId == checkpoint.id,
        orElse: () => SubmissionModel(
          checkpointId: checkpoint.id,
          answer: '',
          pointsEarned: 0,
          timestamp: DateTime.now(),
        ),
      );

      final userAnswer = submission.answer.toLowerCase().trim();
      final isCorrect = userAnswer == correctAnswer && userAnswer.isNotEmpty;
      final points = isCorrect ? checkpoint.pointsReward : 0;

      if (isCorrect) {
        totalPoints += points;
      }

      // Обновляем запись в Firestore
      final submissionQuery = await _firestore
          .collection('submissions')
          .where('teamId', isEqualTo: teamId)
          .where('checkpointId', isEqualTo: checkpoint.id)
          .get();

      if (submissionQuery.docs.isNotEmpty) {
        await submissionQuery.docs.first.reference.update({
          'isCorrect': isCorrect,
          'pointsEarned': points,
        });
      }
    }

    // Обновляем очки команды
    await _firestore.collection('teams').doc(teamId).update({
      'totalPoints': FieldValue.increment(totalPoints),
      'finishedAt': FieldValue.serverTimestamp(),
    });

    return totalPoints;
  }
}
