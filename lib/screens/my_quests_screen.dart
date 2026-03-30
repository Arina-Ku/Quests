import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../blocs/team/team_bloc.dart';
import '../blocs/team/team_event.dart';
import '../blocs/team/team_state.dart';
import '../models/team_model.dart';
import 'quest_run_screen.dart';

class MyQuestsScreen extends StatefulWidget {
  const MyQuestsScreen({super.key});

  @override
  State<MyQuestsScreen> createState() => _MyQuestsScreenState();
}

class _MyQuestsScreenState extends State<MyQuestsScreen> {
  late TeamBloc _teamBloc;

  @override
  void initState() {
    super.initState();
    _teamBloc = TeamBloc();
    _teamBloc.handleEvent(LoadMyTeamsEvent());
  }

  @override
  void dispose() {
    _teamBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Мои квесты',
          style: TextStyle(color: Colors.black87, fontSize: 20),
        ),
      ),
      body: StreamBuilder<TeamState>(
        stream: _teamBloc.stateStream,
        initialData: _teamBloc.currentState,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is TeamLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (state is TeamError) {
            return Center(
              child: Text(
                'Ошибка: ${state.message}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          if (state is MyTeamsLoaded && state.teams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Вы ещё не зарегистрированы на квесты',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Найти квест'),
                  ),
                ],
              ),
            );
          }

          if (state is MyTeamsLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.teams.length,
              itemBuilder: (context, index) {
                final team = state.teams[index];
                return _buildQuestCard(team);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildQuestCard(TeamModel team) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('quests')
          .doc(team.questId)
          .get(),
      builder: (context, questSnapshot) {
        if (!questSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final questData = questSnapshot.data!.data() as Map<String, dynamic>;
        final questDate = (questData['questDate'] as Timestamp?)?.toDate();
        final now = DateTime.now();
        final isAvailable = questDate != null &&
            now.isAfter(questDate.subtract(const Duration(minutes: 30))) &&
            now.isBefore(questDate.add(const Duration(hours: 6)));

        return GestureDetector(
          onTap: isAvailable
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestRunScreen(
                        questId: team.questId,
                        teamId: team.id!,
                        questData: questData,
                      ),
                    ),
                  );
                }
              : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isAvailable
                    ? Colors.green.withOpacity(0.3)
                    : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isAvailable ? Icons.play_circle : Icons.lock_clock,
                    color: isAvailable ? Colors.green : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        questData['title'] ?? 'Без названия',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Команда: ${team.name}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      if (!isAvailable && questDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Доступно с ${DateFormat('dd.MM HH:mm', 'ru').format(questDate)}',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isAvailable)
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.green,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
