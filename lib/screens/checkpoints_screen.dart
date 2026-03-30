import 'package:flutter/material.dart';
import '../blocs/checkpoint/checkpoint_bloc.dart';
import '../blocs/checkpoint/checkpoint_event.dart';
import '../blocs/checkpoint/checkpoint_state.dart';
import '../models/checkpoint_model.dart';
import 'edit_checkpoint_screen.dart';

class CheckpointsScreen extends StatefulWidget {
  final String questId;
  final String questTitle;

  const CheckpointsScreen({
    super.key,
    required this.questId,
    required this.questTitle,
  });

  @override
  State<CheckpointsScreen> createState() => _CheckpointsScreenState();
}

class _CheckpointsScreenState extends State<CheckpointsScreen> {
  late CheckpointBloc _checkpointBloc;

  @override
  void initState() {
    super.initState();
    _checkpointBloc = CheckpointBloc();
    _checkpointBloc.handleEvent(LoadCheckpointsEvent(questId: widget.questId));

    _checkpointBloc.stateStream.listen((state) {
      if (state is CheckpointOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.green,
          ),
        );
      } else if (state is CheckpointError) {
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
    _checkpointBloc.dispose();
    super.dispose();
  }

  Future<void> _deleteCheckpoint(String checkpointId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Удаление точки',
          style: TextStyle(color: Colors.black87),
        ),
        content: const Text(
          'Вы уверены?',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkpointBloc.handleEvent(DeleteCheckpointEvent(
                checkpointId: checkpointId,
              ));
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Контрольные точки',
              style: TextStyle(color: Colors.black87, fontSize: 18),
            ),
            Text(
              widget.questTitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
      body: StreamBuilder<CheckpointState>(
        stream: _checkpointBloc.stateStream,
        initialData: _checkpointBloc.currentState,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is CheckpointLoading && state is! CheckpointsLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (state is CheckpointError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          if (state is CheckpointsLoaded && state.checkpoints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Нет контрольных точек',
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
                          builder: (context) => EditCheckpointScreen(
                            questId: widget.questId,
                          ),
                        ),
                      ).then((_) {
                        _checkpointBloc.handleEvent(
                          LoadCheckpointsEvent(questId: widget.questId),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Добавить первую точку'),
                  ),
                ],
              ),
            );
          }

          if (state is CheckpointsLoaded) {
            final checkpoints = state.checkpoints;

            return ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: checkpoints.length,
              itemBuilder: (context, index) {
                final checkpoint = checkpoints[index];

                return Card(
                  key: ValueKey(checkpoint.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.withOpacity(0.2),
                      child: Text(
                        '${checkpoint.orderNumber}',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                    title: Text(
                      checkpoint.title,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    subtitle: Text(
                      'Баллов: ${checkpoint.pointsReward} • ${checkpoint.taskType}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.blue, size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditCheckpointScreen(
                                  questId: widget.questId,
                                  checkpointId: checkpoint.id,
                                  checkpointData: checkpoint.toMap(),
                                ),
                              ),
                            ).then((_) {
                              _checkpointBloc.handleEvent(
                                LoadCheckpointsEvent(questId: widget.questId),
                              );
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 20),
                          onPressed: () => _deleteCheckpoint(checkpoint.id),
                        ),
                        Icon(Icons.drag_handle, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                _checkpointBloc.handleEvent(
                  ReorderCheckpointsEvent(
                    checkpoints: checkpoints,
                    oldIndex: oldIndex,
                    newIndex: newIndex,
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditCheckpointScreen(
                questId: widget.questId,
              ),
            ),
          ).then((_) {
            _checkpointBloc.handleEvent(
              LoadCheckpointsEvent(questId: widget.questId),
            );
          });
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
