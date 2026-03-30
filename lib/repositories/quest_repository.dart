import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/quest_model.dart';

class QuestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получение всех опубликованных квестов
  Stream<List<QuestModel>> getAllQuests() {
    return _firestore
        .collection('quests')
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuestModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Получение квестов организатора
  Stream<List<QuestModel>> getOrganizerQuests(String creatorId) {
    return _firestore
        .collection('quests')
        .where('creatorId', isEqualTo: creatorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuestModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Создание нового квеста
  Future<QuestModel> createQuest(QuestModel quest,
      {String? coverBase64}) async {
    final data = quest.toMap();
    data['coverBase64'] = coverBase64 ?? '';
    data['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await _firestore.collection('quests').add(data);
    return QuestModel.fromMap(docRef.id, data);
  }

  // Обновление квеста
  Future<void> updateQuest(String questId, Map<String, dynamic> data) async {
    await _firestore.collection('quests').doc(questId).update(data);
  }

  // Удаление квеста (со всеми точками)
  Future<void> deleteQuest(String questId) async {
    // Удаляем все контрольные точки
    final checkpoints = await _firestore
        .collection('checkpoints')
        .where('questId', isEqualTo: questId)
        .get();

    for (var doc in checkpoints.docs) {
      await doc.reference.delete();
    }

    // Удаляем сам квест
    await _firestore.collection('quests').doc(questId).delete();
  }

  // Конвертация изображения в Base64
  String? imageToBase64(Uint8List? imageBytes) {
    if (imageBytes == null) return null;
    return base64Encode(imageBytes);
  }
}
