import '../../models/checkpoint_model.dart';

abstract class CheckpointState {}

class CheckpointInitial extends CheckpointState {}

class CheckpointLoading extends CheckpointState {}

class CheckpointsLoaded extends CheckpointState {
  final List<CheckpointModel> checkpoints;
  CheckpointsLoaded(this.checkpoints);
}

class CheckpointOperationSuccess extends CheckpointState {
  final String message;
  CheckpointOperationSuccess(this.message);
}

class CheckpointError extends CheckpointState {
  final String message;
  CheckpointError(this.message);
}
