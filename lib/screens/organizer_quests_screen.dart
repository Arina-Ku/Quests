// lib/screens/organizer_quests_screen.dart

import 'package:flutter/material.dart';
import '../blocs/quest/quest_bloc.dart';
import '../blocs/quest/quest_event.dart';
import '../blocs/quest/quest_state.dart';
import '../models/quest_model.dart';
import 'create_quest_screen.dart';
import 'manage_quest_screen.dart';

class OrganizerQuestsScreen extends StatefulWidget {
  const OrganizerQuestsScreen({super.key});

  @override
  State<OrganizerQuestsScreen> createState() => _OrganizerQuestsScreenState();
}

class _OrganizerQuestsScreenState extends State<OrganizerQuestsScreen> {
  late QuestBloc _questBloc;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _questBloc = QuestBloc();
  }

  @override
  void dispose() {
    _questBloc.dispose();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.orange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateQuestScreen(),
                ),
              ).then((_) {
                // После создания квеста перезагружаем список
                if (_userId != null) {
                  _questBloc.handleEvent(
                      LoadOrganizerQuestsEvent(creatorId: _userId!));
                }
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuestState>(
        stream: _questBloc.stateStream,
        initialData: _questBloc.currentState,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is QuestLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (state is QuestError) {
            return Center(
              child: Text(
                'Ошибка: ${state.message}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          if (state is QuestsLoaded) {
            final quests = state.quests;

            if (quests.isEmpty) {
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
                      'У вас пока нет квестов',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateQuestScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Создать первый квест'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: quests.length,
              itemBuilder: (context, index) {
                final quest = quests[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageQuestScreen(
                          questId: quest.id!,
                          questData: quest.toMap(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: quest.isPublished
                                ? Colors.green.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            quest.isPublished ? Icons.public : Icons.lock,
                            color:
                                quest.isPublished ? Colors.green : Colors.grey,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quest.title,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${quest.city} • ${quest.difficulty}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[500],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
