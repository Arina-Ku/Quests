import '../../models/team_model.dart';

abstract class TeamState {}

class TeamInitial extends TeamState {}

class TeamLoading extends TeamState {}

class CaptainLoaded extends TeamState {
  final String captainId;
  final List<String> memberIds;
  CaptainLoaded({
    required this.captainId,
    required this.memberIds,
  });
}

class MemberAdded extends TeamState {
  final List<String> memberIds;
  MemberAdded(this.memberIds);
}

class MemberRemoved extends TeamState {
  final List<String> memberIds;
  MemberRemoved(this.memberIds);
}

class TeamRegistered extends TeamState {
  final String message;
  TeamRegistered(this.message);
}

class TeamError extends TeamState {
  final String message;
  TeamError(this.message);
}

class MyTeamsLoaded extends TeamState {
  final List<TeamModel> teams;
  MyTeamsLoaded(this.teams);
}
