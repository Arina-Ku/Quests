import 'dart:async';
import '../../repositories/quest_run_repository.dart';
import '../../models/checkpoint_model.dart';
import '../../models/quest_run_model.dart';
import 'quest_run_event.dart';
import 'quest_run_state.dart';

class QuestRunBloc {
  final QuestRunRepository _repository = QuestRunRepository();
  final _stateController = StreamController<QuestRunState>.broadcast();

  QuestRunState _currentState = QuestRunInitial();

  // Данные квеста
  List<CheckpointModel> _checkpoints = [];
  int _teamPoints = 0;
  List<SubmissionModel> _submissions = [];
  int _currentIndex = 0;
  String _questId = '';
  String _teamId = '';

  Stream<QuestRunState> get stateStream => _stateController.stream;
  QuestRunState get currentState => _currentState;

  QuestRunBloc() {
    _stateController.add(_currentState);
  }

  get state => null;

  Future<void> handleEvent(QuestRunEvent event) async {
    if (event is LoadQuestRunDataEvent) {
      await _handleLoadData(event);
    } else if (event is SubmitAnswerEvent) {
      await _handleSubmitAnswer(event);
    } else if (event is SkipCheckpointEvent) {
      await _handleSkipCheckpoint();
    } else if (event is FinishQuestEvent) {
      await _handleFinishQuest();
    } else if (event is ShowHintEvent) {
      _handleShowHint();
    }
  }

  Future<void> _handleLoadData(LoadQuestRunDataEvent event) async {
    _updateState(QuestRunLoading());

    _questId = event.questId;
    _teamId = event.teamId;

    try {
      _checkpoints = await _repository.loadCheckpoints(event.questId);
      _teamPoints = await _repository.loadTeamPoints(event.teamId);
      _submissions = await _repository.loadSubmissions(event.teamId);
      _currentIndex = _submissions.length;
      _currentIndex = _currentIndex.clamp(0, _checkpoints.length);

      if (_currentIndex >= _checkpoints.length) {
        // Все точки пройдены, показываем результаты
        await _handleFinishQuest();
      } else if (_checkpoints.isNotEmpty) {
        _updateActiveState();
      } else {
        _updateState(QuestRunError('В квесте нет точек'));
      }
    } catch (e) {
      _updateState(QuestRunError('Ошибка загрузки: $e'));
    }
  }

  Future<void> _handleSubmitAnswer(SubmitAnswerEvent event) async {
    if (event.answer.isEmpty) {
      _updateState(QuestRunError('Введите ответ'));
      return;
    }

    _updateActiveState(isSubmitting: true);

    try {
      final currentCheckpoint = _checkpoints[_currentIndex];

      await _repository.saveSubmission(
        checkpointId: currentCheckpoint.id,
        teamId: _teamId,
        answer: event.answer,
      );

      _submissions.add(SubmissionModel(
        checkpointId: currentCheckpoint.id,
        answer: event.answer,
        pointsEarned: 0,
        timestamp: DateTime.now(),
      ));

      _updateState(QuestRunLoading());
      await Future.delayed(const Duration(milliseconds: 500));

      if (_currentIndex < _checkpoints.length - 1) {
        _currentIndex++;
        _updateActiveState(showHint: false);
      } else {
        await _handleFinishQuest();
      }
    } catch (e) {
      _updateActiveState(isSubmitting: false);
      _updateState(QuestRunError('Ошибка сохранения: $e'));
    }
  }

  Future<void> _handleSkipCheckpoint() async {
    try {
      final currentCheckpoint = _checkpoints[_currentIndex];

      await _repository.saveSubmission(
        checkpointId: currentCheckpoint.id,
        teamId: _teamId,
        answer: '[ПРОПУЩЕНО]',
      );

      _submissions.add(SubmissionModel(
        checkpointId: currentCheckpoint.id,
        answer: '[ПРОПУЩЕНО]',
        pointsEarned: 0,
        timestamp: DateTime.now(),
      ));

      if (_currentIndex < _checkpoints.length - 1) {
        _currentIndex++;
        _updateActiveState(showHint: false);
      } else {
        await _handleFinishQuest();
      }
    } catch (e) {
      _updateState(QuestRunError('Ошибка пропуска: $e'));
    }
  }

  Future<void> _handleFinishQuest() async {
    _updateState(QuestRunLoading());

    try {
      final totalPoints = await _repository.calculateAndUpdateResults(
        checkpoints: _checkpoints,
        submissions: _submissions,
        teamId: _teamId,
      );

      // Формируем результаты для отображения
      final results = <Map<String, dynamic>>[];
      for (int i = 0; i < _checkpoints.length; i++) {
        final checkpoint = _checkpoints[i];
        final submission = _submissions.firstWhere(
          (s) => s.checkpointId == checkpoint.id,
          orElse: () => SubmissionModel(
            checkpointId: checkpoint.id,
            answer: '—',
            pointsEarned: 0,
            timestamp: DateTime.now(),
          ),
        );

        final isCorrect = submission.isCorrect ?? false;
        final userAnswer = submission.answer;
        final correctAnswer = checkpoint.answer;

        results.add({
          'title': checkpoint.title,
          'userAnswer': userAnswer,
          'correctAnswer': correctAnswer,
          'isCorrect': isCorrect,
          'points': checkpoint.pointsReward,
        });
      }

      _updateState(QuestRunFinished(
        totalPoints: totalPoints,
        results: results,
      ));
    } catch (e) {
      _updateState(QuestRunError('Ошибка подсчёта результатов: $e'));
    }
  }

  void _handleShowHint() {
    if (_currentState is CheckpointActive) {
      final state = _currentState as CheckpointActive;
      _updateActiveState(showHint: !state.showHint);
    }
  }

  void _updateActiveState({
    bool? showHint,
    bool? isSubmitting,
  }) {
    if (_currentIndex < _checkpoints.length) {
      _updateState(CheckpointActive(
        currentCheckpoint: _checkpoints[_currentIndex],
        currentIndex: _currentIndex,
        totalCheckpoints: _checkpoints.length,
        teamPoints: _teamPoints,
        showHint:
            showHint ?? (state is CheckpointActive ? state.showHint : false),
        isSubmitting: isSubmitting ??
            (state is CheckpointActive ? state.isSubmitting : false),
      ));
    }
  }

  void _updateState(QuestRunState state) {
    _currentState = state;
    _stateController.add(state);
  }

  void dispose() {
    _stateController.close();
  }
}
