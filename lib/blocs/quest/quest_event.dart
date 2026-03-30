import 'dart:typed_data';
import '../../models/quest_model.dart';

abstract class QuestEvent {}

class CreateQuestEvent extends QuestEvent {
  final QuestModel quest;
  final Uint8List? imageBytes;
  CreateQuestEvent({required this.quest, this.imageBytes});
}

class UpdateQuestEvent extends QuestEvent {
  final String questId;
  final Map<String, dynamic> data;
  UpdateQuestEvent({required this.questId, required this.data});
}

class DeleteQuestEvent extends QuestEvent {
  final String questId;
  DeleteQuestEvent({required this.questId});
}

class LoadQuestsEvent extends QuestEvent {}

class LoadOrganizerQuestsEvent extends QuestEvent {
  final String creatorId;
  LoadOrganizerQuestsEvent({required this.creatorId});
}
