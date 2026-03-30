import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/checkpoint_model.dart';

class CheckpointRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получение всех точек квеста (с сортировкой по orderNumber)
  Stream<List<CheckpointModel>> getCheckpoints(String questId) {
    return _firestore
        .collection('checkpoints')
        .where('questId', isEqualTo: questId)
        .orderBy('orderNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CheckpointModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Создание новой точки
  Future<CheckpointModel> createCheckpoint(CheckpointModel checkpoint) async {
    // Получаем следующий orderNumber
    final snapshot = await _firestore
        .collection('checkpoints')
        .where('questId', isEqualTo: checkpoint.questId)
        .orderBy('orderNumber', descending: true)
        .limit(1)
        .get();

    final nextOrder = snapshot.docs.isEmpty
        ? 1
        : (snapshot.docs.first.data()['orderNumber'] as int) + 1;

    final data = checkpoint.toMap();
    data['orderNumber'] = nextOrder;

    final docRef = await _firestore.collection('checkpoints').add(data);
    return CheckpointModel.fromMap(docRef.id, data);
  }

  // Обновление точки
  Future<void> updateCheckpoint(
      String checkpointId, Map<String, dynamic> data) async {
    await _firestore.collection('checkpoints').doc(checkpointId).update(data);
  }

  // Удаление точки
  Future<void> deleteCheckpoint(String checkpointId) async {
    await _firestore.collection('checkpoints').doc(checkpointId).delete();
  }

  // Перестановка точек (обновление orderNumber)
  Future<void> reorderCheckpoints(
      List<CheckpointModel> checkpoints, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex--;

    final batch = _firestore.batch();

    for (int i = 0; i < checkpoints.length; i++) {
      final ref = _firestore.collection('checkpoints').doc(checkpoints[i].id);
      int newOrder;

      if (i == oldIndex) {
        newOrder = newIndex + 1;
      } else if (i >= newIndex && i < oldIndex) {
        newOrder = i + 2;
      } else if (i <= newIndex && i > oldIndex) {
        newOrder = i;
      } else {
        newOrder = i + 1;
      }

      batch.update(ref, {'orderNumber': newOrder});
    }

    await batch.commit();
  }
}
