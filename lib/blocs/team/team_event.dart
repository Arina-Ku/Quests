abstract class TeamEvent {}

class LoadCaptainIdEvent extends TeamEvent {}

class AddMemberEvent extends TeamEvent {
  final String memberId;
  AddMemberEvent({required this.memberId});
}

class RemoveMemberEvent extends TeamEvent {
  final String memberId;
  RemoveMemberEvent({required this.memberId});
}

class RegisterTeamEvent extends TeamEvent {
  final String teamName;
  RegisterTeamEvent({required this.teamName});
}

class LoadMyTeamsEvent extends TeamEvent {}
