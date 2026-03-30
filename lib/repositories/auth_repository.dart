import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Поиск пользователя по email и проверка пароля
  Future<UserModel?> login(String email, String password) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    final userDoc = querySnapshot.docs.first;
    final userData = userDoc.data();
    final storedPassword = userData['password'];

    if (password != storedPassword) {
      return null;
    }

    // Сохраняем сессию
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userDoc.id);

    return UserModel.fromMap(userDoc.id, userData);
  }

  // Регистрация нового пользователя
  Future<UserModel?> register(UserModel user) async {
    final existing = await _firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return null;
    }

    // Сохраняем пользователя
    final docRef = await _firestore.collection('users').add(user.toMap());
    final newUser = UserModel.fromMap(docRef.id, user.toMap());

    // Сохраняем сессию
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', docRef.id);

    return newUser;
  }

  // Выход из системы
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  // Получение текущего пользователя
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return null;

    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.id, doc.data()!);
  }
}
