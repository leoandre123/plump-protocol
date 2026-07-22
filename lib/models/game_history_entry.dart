import 'package:plumpen_app/models/game_data.dart';

class GameHistoryEntry {
  final DateTime playedAt;
  final GameData gameData;
  final int scoreForZero;

  GameHistoryEntry({
    required this.playedAt,
    required this.gameData,
    required this.scoreForZero,
  });

  Map<String, dynamic> toJson() => {
    'playedAt': playedAt.toIso8601String(),
    'gameData': gameData.toJson(),
    'scoreForZero': scoreForZero,
  };

  factory GameHistoryEntry.fromJson(Map<String, dynamic> json) =>
      GameHistoryEntry(
        playedAt: DateTime.parse(json['playedAt'] as String),
        gameData: GameData.fromJson(json['gameData'] as Map<String, dynamic>),
        scoreForZero: json['scoreForZero'] as int,
      );
}
