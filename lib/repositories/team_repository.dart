import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/team_model.dart';

class TeamRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получение ID капитана из SharedPreferences
  Future<String?> getCaptainId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Регистрация команды
  Future<TeamModel> registerTeam({
    required String teamName,
    required String captainId,
    required List<String> memberIds,
    required String questId,
  }) async {
    final team = TeamModel(
      name: teamName,
      captainId: captainId,
      memberIds: memberIds,
      questId: questId,
      createdAt: DateTime.now(),
      totalPoints: 0,
    );

    final docRef = await _firestore.collection('teams').add(team.toMap());
    return TeamModel.fromMap(docRef.id, team.toMap());
  }

  // Проверка, не зарегистрирована ли уже команда на этот квест
  Future<bool> isTeamAlreadyRegistered(String questId, String captainId) async {
    final snapshot = await _firestore
        .collection('teams')
        .where('questId', isEqualTo: questId)
        .where('captainId', isEqualTo: captainId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Получение команд пользователя
  Stream<List<TeamModel>> getUserTeams(String userId) {
    return _firestore
        .collection('teams')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TeamModel.fromMap(doc.id, doc.data()))
            .toList());
  }
}
