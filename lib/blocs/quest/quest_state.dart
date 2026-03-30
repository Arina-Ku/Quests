import '../../models/quest_model.dart';

abstract class QuestState {}

class QuestInitial extends QuestState {}

class QuestLoading extends QuestState {}

class QuestsLoaded extends QuestState {
  final List<QuestModel> quests;
  QuestsLoaded(this.quests);
}

class QuestOperationSuccess extends QuestState {
  final String message;
  QuestOperationSuccess(this.message);
}

class QuestError extends QuestState {
  final String message;
  QuestError(this.message);
}
