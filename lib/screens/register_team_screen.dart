// lib/screens/register_team_screen.dart

import 'package:flutter/material.dart';
import '../blocs/team/team_bloc.dart';
import '../blocs/team/team_event.dart';
import '../blocs/team/team_state.dart';

class RegisterTeamScreen extends StatefulWidget {
  final String questId;
  final Map<String, dynamic> questData;

  const RegisterTeamScreen({
    super.key,
    required this.questId,
    required this.questData,
  });

  @override
  State<RegisterTeamScreen> createState() => _RegisterTeamScreenState();
}

class _RegisterTeamScreenState extends State<RegisterTeamScreen> {
  late TeamBloc _teamBloc;
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _memberIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _teamBloc = TeamBloc();
    _teamBloc.handleEvent(LoadCaptainIdEvent());

    _teamBloc.stateStream.listen((state) {
      if (state is TeamRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (state is TeamError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _memberIdController.dispose();
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
          'Регистрация команды',
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

          if (state is CaptainLoaded) {
            return _buildForm(state);
          }

          if (state is MemberAdded || state is MemberRemoved) {
            final currentState = _teamBloc.currentState;
            if (currentState is MemberAdded) {
              return _buildFormWithMembers(currentState.memberIds);
            }
            if (currentState is MemberRemoved) {
              return _buildFormWithMembers(currentState.memberIds);
            }
          }

          if (state is TeamError) {
            return _buildErrorScreen(state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildForm(CaptainLoaded state) {
    return _buildFormWithMembers(state.memberIds);
  }

  Widget _buildFormWithMembers(List<String> memberIds) {
    final captainId = memberIds.isNotEmpty ? memberIds[0] : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Информация о квесте
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.questData['title'] ?? 'Без названия',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.questData['city'] ?? 'Неизвестный город',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Название команды
          const Text(
            'Название команды',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _teamNameController,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Введите название',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Добавление участников
          const Text(
            'Участники команды',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // ID капитана (нельзя удалить)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Капитан: ${captainId.substring(0, captainId.length > 6 ? 6 : captainId.length)}...',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'это вы',
                    style: TextStyle(color: Colors.orange, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),

          // Список добавленных участников
          ...memberIds.where((id) => id != captainId).map((id) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        id.length > 10 ? '${id.substring(0, 10)}...' : id,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.close, color: Colors.red, size: 16),
                      onPressed: () {
                        _teamBloc.handleEvent(
                          RemoveMemberEvent(memberId: id),
                        );
                      },
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 12),

          // Добавление нового участника
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _memberIdController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Введите ID участника',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    _teamBloc.handleEvent(
                      AddMemberEvent(memberId: _memberIdController.text),
                    );
                    _memberIdController.clear();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Кнопка регистрации
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                _teamBloc.handleEvent(
                  RegisterTeamEvent(teamName: _teamNameController.text),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Зарегистрировать команду',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Вернуться'),
          ),
        ],
      ),
    );
  }
}
