import '../../models/checkpoint_model.dart';

abstract class CheckpointEvent {}

class LoadCheckpointsEvent extends CheckpointEvent {
  final String questId;
  LoadCheckpointsEvent({required this.questId});
}

class CreateCheckpointEvent extends CheckpointEvent {
  final CheckpointModel checkpoint;
  CreateCheckpointEvent({required this.checkpoint});
}

class UpdateCheckpointEvent extends CheckpointEvent {
  final String checkpointId;
  final Map<String, dynamic> data;
  UpdateCheckpointEvent({required this.checkpointId, required this.data});
}

class DeleteCheckpointEvent extends CheckpointEvent {
  final String checkpointId;
  DeleteCheckpointEvent({required this.checkpointId});
}

class ReorderCheckpointsEvent extends CheckpointEvent {
  final List<CheckpointModel> checkpoints;
  final int oldIndex;
  final int newIndex;
  ReorderCheckpointsEvent({
    required this.checkpoints,
    required this.oldIndex,
    required this.newIndex,
  });
}
