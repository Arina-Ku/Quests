abstract class QuestRunEvent {}

class LoadQuestRunDataEvent extends QuestRunEvent {
  final String questId;
  final String teamId;
  LoadQuestRunDataEvent({required this.questId, required this.teamId});
}

class SubmitAnswerEvent extends QuestRunEvent {
  final String answer;
  SubmitAnswerEvent({required this.answer});
}

class SkipCheckpointEvent extends QuestRunEvent {}

class NextCheckpointEvent extends QuestRunEvent {}

class FinishQuestEvent extends QuestRunEvent {}

class ShowHintEvent extends QuestRunEvent {}
