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
}
