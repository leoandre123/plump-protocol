import 'package:plumpen_app/models/player.dart';

enum GameState { addingPlayers, bidding, playing, noting, gameOver }

class GameData {
  int startCard;
  final List<int> roundCards;
  final List<Player> players;

  int currentRound;
  GameState gameState;

  int currentPlayerIndex;
  int currentDealerIndex;

  GameData({
    required this.startCard,
    required this.roundCards,
    required this.players,
    required this.currentRound,
    required this.gameState,
    required this.currentPlayerIndex,
    required this.currentDealerIndex,
  });

  GameData copy() {
    return GameData(
      startCard: startCard,
      roundCards: List<int>.from(roundCards),
      players: players.map((p) => p.copy()).toList(),
      currentRound: currentRound,
      gameState: gameState,
      currentPlayerIndex: currentPlayerIndex,
      currentDealerIndex: currentDealerIndex,
    );
  }

  Map<String, dynamic> toJson() => {
    'startCard': startCard,
    'roundCards': roundCards,
    'players': players.map((p) => p.toJson()).toList(),
    'currentRound': currentRound,
    'gameState': gameState.index,
    'currentPlayerIndex': currentPlayerIndex,
    'currentDealerIndex': currentDealerIndex,
  };

  factory GameData.fromJson(Map<String, dynamic> json) => GameData(
    startCard: json['startCard'] as int,
    roundCards: List<int>.from(json['roundCards'] as List),
    players: (json['players'] as List)
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList(),
    currentRound: json['currentRound'] as int,
    gameState: GameState.values[json['gameState'] as int],
    currentPlayerIndex: json['currentPlayerIndex'] as int,
    currentDealerIndex: json['currentDealerIndex'] as int,
  );
}
