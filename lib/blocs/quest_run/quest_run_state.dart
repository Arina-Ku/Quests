import '../../models/checkpoint_model.dart';

abstract class QuestRunState {}

class QuestRunInitial extends QuestRunState {}

class QuestRunLoading extends QuestRunState {}

class CheckpointActive extends QuestRunState {
  final CheckpointModel currentCheckpoint;
  final int currentIndex;
  final int totalCheckpoints;
  final int teamPoints;
  final bool showHint;
  final bool isSubmitting;

  CheckpointActive({
    required this.currentCheckpoint,
    required this.currentIndex,
    required this.totalCheckpoints,
    required this.teamPoints,
    required this.showHint,
    required this.isSubmitting,
  });

  CheckpointActive copyWith({
    CheckpointModel? currentCheckpoint,
    int? currentIndex,
    int? totalCheckpoints,
    int? teamPoints,
    bool? showHint,
    bool? isSubmitting,
  }) {
    return CheckpointActive(
      currentCheckpoint: currentCheckpoint ?? this.currentCheckpoint,
      currentIndex: currentIndex ?? this.currentIndex,
      totalCheckpoints: totalCheckpoints ?? this.totalCheckpoints,
      teamPoints: teamPoints ?? this.teamPoints,
      showHint: showHint ?? this.showHint,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class QuestRunFinished extends QuestRunState {
  final int totalPoints;
  final List<Map<String, dynamic>> results;
  QuestRunFinished({
    required this.totalPoints,
    required this.results,
  });
}

class QuestRunError extends QuestRunState {
  final String message;
  QuestRunError(this.message);
}
