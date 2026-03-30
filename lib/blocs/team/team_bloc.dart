import 'dart:async';
import '../../repositories/team_repository.dart';
import '../../models/team_model.dart';
import 'team_event.dart';
import 'team_state.dart';

class TeamBloc {
  final TeamRepository _repository = TeamRepository();
  final _stateController = StreamController<TeamState>.broadcast();

  TeamState _currentState = TeamInitial();

  // Состояние
  String? _captainId;
  List<String> _memberIds = [];

  Stream<TeamState> get stateStream => _stateController.stream;
  TeamState get currentState => _currentState;

  TeamBloc() {
    _stateController.add(_currentState);
  }

  Future<void> handleEvent(TeamEvent event) async {
    if (event is LoadCaptainIdEvent) {
      await _handleLoadCaptainId();
    } else if (event is AddMemberEvent) {
      _handleAddMember(event);
    } else if (event is RemoveMemberEvent) {
      _handleRemoveMember(event);
    } else if (event is RegisterTeamEvent) {
      await _handleRegisterTeam(event);
    }
  }

  Future<void> _handleLoadCaptainId() async {
    _updateState(TeamLoading());

    final captainId = await _repository.getCaptainId();

    if (captainId != null) {
      _captainId = captainId;
      _memberIds = [captainId];
      _updateState(CaptainLoaded(
        captainId: captainId,
        memberIds: _memberIds,
      ));
    } else {
      _updateState(TeamError('Не удалось загрузить ID пользователя'));
    }
  }

  void _handleAddMember(AddMemberEvent event) {
    final id = event.memberId.trim();

    if (id.isEmpty) {
      _updateState(TeamError('Введите ID участника'));
      return;
    }

    if (_memberIds.contains(id)) {
      _updateState(TeamError('Этот участник уже добавлен'));
      return;
    }

    _memberIds.add(id);
    _updateState(MemberAdded(_memberIds));
  }

  void _handleRemoveMember(RemoveMemberEvent event) {
    if (event.memberId == _captainId) {
      _updateState(TeamError('Нельзя удалить капитана'));
      return;
    }

    _memberIds.remove(event.memberId);
    _updateState(MemberRemoved(_memberIds));
  }

  Future<void> _handleRegisterTeam(
      RegisterTeamEvent event, dynamic widget) async {
    if (event.teamName.isEmpty) {
      _updateState(TeamError('Введите название команды'));
      return;
    }

    if (_captainId == null) {
      _updateState(TeamError('Ошибка: капитан не найден'));
      return;
    }

    _updateState(TeamLoading());

    try {
      // Проверка, не зарегистрирована ли уже команда
      final alreadyRegistered = await _repository.isTeamAlreadyRegistered(
        widget.questId, // нужно передавать questId
        _captainId!,
      );

      if (alreadyRegistered) {
        _updateState(TeamError('Вы уже зарегистрированы на этот квест'));
        return;
      }

      final team = await _repository.registerTeam(
        teamName: event.teamName,
        captainId: _captainId!,
        memberIds: _memberIds,
        questId: widget.questId, // нужно передавать questId
      );

      _updateState(TeamRegistered('Команда "${team.name}" зарегистрирована!'));
    } catch (e) {
      _updateState(TeamError('Ошибка регистрации: $e'));
    }
  }

  void _updateState(TeamState state) {
    _currentState = state;
    _stateController.add(state);
  }

  void dispose() {
    _stateController.close();
  }
}

Future<void> handleEvent(TeamEvent event) async {
  // ... существующие обработчики
  if (event is LoadMyTeamsEvent) {
    await _handleLoadMyTeams();
  }
}

Future<void> _handleLoadMyTeams() async {
  _updateState(TeamLoading());

  final userId = await _repository.getCaptainId();
  if (userId == null) {
    _updateState(TeamError('Пользователь не найден'));
    return;
  }

  _repository.getUserTeams(userId).listen(
    (teams) {
      _updateState(MyTeamsLoaded(teams));
    },
    onError: (error) {
      _updateState(TeamError('Ошибка загрузки: $error'));
    },
  );
}
