import 'dart:async';
import '../../repositories/checkpoint_repository.dart';
import '../../models/checkpoint_model.dart';
import 'checkpoint_event.dart';
import 'checkpoint_state.dart';

class CheckpointBloc {
  final CheckpointRepository _repository = CheckpointRepository();
  final _stateController = StreamController<CheckpointState>.broadcast();

  CheckpointState _currentState = CheckpointInitial();

  Stream<CheckpointState> get stateStream => _stateController.stream;
  CheckpointState get currentState => _currentState;

  CheckpointBloc() {
    _stateController.add(_currentState);
  }

  Future<void> handleEvent(CheckpointEvent event) async {
    if (event is LoadCheckpointsEvent) {
      await _handleLoadCheckpoints(event);
    } else if (event is CreateCheckpointEvent) {
      await _handleCreateCheckpoint(event);
    } else if (event is UpdateCheckpointEvent) {
      await _handleUpdateCheckpoint(event);
    } else if (event is DeleteCheckpointEvent) {
      await _handleDeleteCheckpoint(event);
    } else if (event is ReorderCheckpointsEvent) {
      await _handleReorderCheckpoints(event);
    }
  }

  Future<void> _handleLoadCheckpoints(LoadCheckpointsEvent event) async {
    _updateState(CheckpointLoading());

    _repository.getCheckpoints(event.questId).listen(
      (checkpoints) {
        _updateState(CheckpointsLoaded(checkpoints));
      },
      onError: (error) {
        _updateState(CheckpointError('Ошибка загрузки: $error'));
      },
    );
  }

  Future<void> _handleCreateCheckpoint(CreateCheckpointEvent event) async {
    _updateState(CheckpointLoading());

    try {
      await _repository.createCheckpoint(event.checkpoint);
      _updateState(CheckpointOperationSuccess('Точка создана'));
    } catch (e) {
      _updateState(CheckpointError('Ошибка создания: $e'));
    }
  }

  Future<void> _handleUpdateCheckpoint(UpdateCheckpointEvent event) async {
    _updateState(CheckpointLoading());

    try {
      await _repository.updateCheckpoint(event.checkpointId, event.data);
      _updateState(CheckpointOperationSuccess('Точка обновлена'));
    } catch (e) {
      _updateState(CheckpointError('Ошибка обновления: $e'));
    }
  }

  Future<void> _handleDeleteCheckpoint(DeleteCheckpointEvent event) async {
    _updateState(CheckpointLoading());

    try {
      await _repository.deleteCheckpoint(event.checkpointId);
      _updateState(CheckpointOperationSuccess('Точка удалена'));
    } catch (e) {
      _updateState(CheckpointError('Ошибка удаления: $e'));
    }
  }

  Future<void> _handleReorderCheckpoints(ReorderCheckpointsEvent event) async {
    try {
      await _repository.reorderCheckpoints(
        event.checkpoints,
        event.oldIndex,
        event.newIndex,
      );
    } catch (e) {
      _updateState(CheckpointError('Ошибка перестановки: $e'));
    }
  }

  void _updateState(CheckpointState state) {
    _currentState = state;
    _stateController.add(state);
  }

  void dispose() {
    _stateController.close();
  }
}
