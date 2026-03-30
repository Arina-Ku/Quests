import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'register_team_screen.dart';

class QuestDetailScreen extends StatelessWidget {
  final String questId;
  final Map<String, dynamic> questData;

  const QuestDetailScreen({
    super.key,
    required this.questId,
    required this.questData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верхняя часть с градиентом и кнопкой назад
              Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade900,
                          Colors.orange.shade700
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -40,
                          top: -40,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          left: -30,
                          bottom: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Кнопка назад
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  // Рейтинг
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${questData['difficulty'] ?? 0}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Основная информация
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Название и город
                    Text(
                      questData['title'] ?? 'Без названия',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          questData['city'] ?? 'Неизвестный город',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Дата и время
                    _buildInfoCard(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Дата проведения',
                      value: _formatDate(questData['questDate']),
                    ),

                    const SizedBox(height: 12),

                    // Место старта
                    _buildInfoCard(
                      context,
                      icon: Icons.flag,
                      title: 'Место старта',
                      value: questData['startLocation'] ?? 'Уточняется',
                    ),

                    const SizedBox(height: 12),

                    // Время сбора
                    _buildInfoCard(
                      context,
                      icon: Icons.access_time,
                      title: 'Время сбора',
                      value: questData['gatheringTime'] ?? 'Уточняется',
                    ),

                    const SizedBox(height: 12),

                    // Прием заявок
                    _buildInfoCard(
                      context,
                      icon: Icons.event_available,
                      title: 'Прием заявок',
                      value: _formatRegistrationPeriod(questData),
                    ),

                    const SizedBox(height: 24),

                    // Теги
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTag(questData['difficulty'] is String
                            ? questData['difficulty']
                            : _getDifficultyText(questData['difficulty'])),
                        _buildTag(questData['category'] ?? 'История'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Раздел "Информация"
                    const Text(
                      'Информация',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        questData['description'] ?? 'Нет описания',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Кнопка регистрации
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterTeamScreen(
                                questId: questId,
                                questData: questData,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Зарегистрироваться',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 14,
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Не указана';
    try {
      final date = (timestamp as Timestamp).toDate();
      return DateFormat('d MMMM yyyy', 'ru').format(date);
    } catch (e) {
      return 'Не указана';
    }
  }

  String _formatRegistrationPeriod(Map<String, dynamic> data) {
    final start = data['registrationStart'];
    final end = data['registrationEnd'];

    if (start == null || end == null) return 'Не указан';

    try {
      final startDate = (start as Timestamp).toDate();
      final endDate = (end as Timestamp).toDate();
      return 'с ${DateFormat('HH:mm d MMM', 'ru').format(startDate)} по ${DateFormat('HH:mm d MMM', 'ru').format(endDate)}';
    } catch (e) {
      return 'Не указан';
    }
  }

  String _getDifficultyText(dynamic difficulty) {
    if (difficulty == null) return 'Легкий';

    if (difficulty is int || difficulty is double) {
      switch (difficulty) {
        case 1:
          return 'Легкий';
        case 2:
          return 'Средний';
        case 3:
          return 'Сложный';
        default:
          return 'Легкий';
      }
    }

    return difficulty.toString();
  }
}
