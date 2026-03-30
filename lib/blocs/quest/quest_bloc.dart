import 'dart:async';
import '../../repositories/quest_repository.dart';
import '../../models/quest_model.dart';
import 'quest_event.dart';
import 'quest_state.dart';

class QuestBloc {
  final QuestRepository _repository = QuestRepository();
  final _stateController = StreamController<QuestState>.broadcast();

  QuestState _currentState = QuestInitial();
  StreamSubscription? _questsSubscription;

  Stream<QuestState> get stateStream => _stateController.stream;
  QuestState get currentState => _currentState;

  QuestBloc() {
    _stateController.add(_currentState);
  }

  Future<void> handleEvent(QuestEvent event) async {
    if (event is CreateQuestEvent) {
      await _handleCreateQuest(event);
    } else if (event is UpdateQuestEvent) {
      await _handleUpdateQuest(event);
    } else if (event is DeleteQuestEvent) {
      await _handleDeleteQuest(event);
    } else if (event is LoadQuestsEvent) {
      _handleLoadQuests();
    } else if (event is LoadOrganizerQuestsEvent) {
      _handleLoadOrganizerQuests(event);
    }
  }

  void _handleLoadQuests() {
    _updateState(QuestLoading());

    _questsSubscription?.cancel();
    _questsSubscription = _repository.getAllQuests().listen(
      (quests) {
        _updateState(QuestsLoaded(quests));
      },
      onError: (error) {
        _updateState(QuestError('Ошибка загрузки: $error'));
      },
    );
  }

  void _handleLoadOrganizerQuests(LoadOrganizerQuestsEvent event) {
    _updateState(QuestLoading());

    _questsSubscription?.cancel();
    _questsSubscription =
        _repository.getOrganizerQuests(event.creatorId).listen(
      (quests) {
        _updateState(QuestsLoaded(quests));
      },
      onError: (error) {
        _updateState(QuestError('Ошибка загрузки: $error'));
      },
    );
  }

  Future<void> _handleCreateQuest(CreateQuestEvent event) async {
    _updateState(QuestLoading());

    try {
      final coverBase64 = _repository.imageToBase64(event.imageBytes);
      await _repository.createQuest(event.quest, coverBase64: coverBase64);
      _updateState(QuestOperationSuccess('Квест успешно создан!'));
    } catch (e) {
      _updateState(QuestError('Ошибка создания: $e'));
    }
  }

  Future<void> _handleUpdateQuest(UpdateQuestEvent event) async {
    _updateState(QuestLoading());

    try {
      await _repository.updateQuest(event.questId, event.data);
      _updateState(QuestOperationSuccess('Квест обновлён'));
    } catch (e) {
      _updateState(QuestError('Ошибка обновления: $e'));
    }
  }

  Future<void> _handleDeleteQuest(DeleteQuestEvent event) async {
    _updateState(QuestLoading());

    try {
      await _repository.deleteQuest(event.questId);
      _updateState(QuestOperationSuccess('Квест удалён'));
    } catch (e) {
      _updateState(QuestError('Ошибка удаления: $e'));
    }
  }

  void _updateState(QuestState state) {
    _currentState = state;
    _stateController.add(state);
  }

  void dispose() {
    _questsSubscription?.cancel();
    _stateController.close();
  }
}
