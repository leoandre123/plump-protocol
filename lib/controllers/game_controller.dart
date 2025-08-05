import 'package:flutter/foundation.dart';
import 'package:plumpen_app/models/game_data.dart';
import 'package:plumpen_app/models/game_settings.dart';
import 'package:plumpen_app/models/player.dart';
import 'package:plumpen_app/repositories/settings_repository.dart';

//enum GameState { addingPlayers, bidding, playing, noting, gameOver }

class GameController with ChangeNotifier {
  GameData _gameData;

  final List<GameData> _gameDataHistory;

  GameSettings _gameSettings;

  GameState get gameState => _gameData.gameState;
  int get startCard => _gameData.startCard;
  int get currentRound => _gameData.currentRound;
  List<Player> get players => List.unmodifiable(_gameData.players);
  List<int> get roundCards => List.unmodifiable(_gameData.roundCards);

  int get numCards => _gameData.roundCards.length > _gameData.currentRound
      ? _gameData.roundCards[_gameData.currentRound]
      : -1;

  GameSettings get gameSettings => _gameSettings;

  Player? get currentPlayer =>
      _gameData.players.length > _gameData.currentPlayerIndex
      ? _gameData.players[_gameData.currentPlayerIndex]
      : null;
  Player? get dealingPlayer =>
      _gameData.players.length > _gameData.currentDealerIndex
      ? _gameData.players[_gameData.currentDealerIndex]
      : null;
  int get currentIndex => _gameData.currentPlayerIndex;
  int get dealingIndex => _gameData.currentDealerIndex;

  final SettingsRepository _settingsRepository;

  GameController(int cards)
    : _gameData = GameData(
        startCard: cards,
        roundCards: [-1],
        players: [],
        currentRound: 0,
        gameState: GameState.addingPlayers,
        currentPlayerIndex: 1,
        currentDealerIndex: 0,
      ),
      _gameDataHistory = [],
      _gameSettings = GameSettings(),
      _settingsRepository = SettingsRepository() {
    _settingsRepository.loadSettings().then((val) {
      _gameSettings = val;
    });

    _rebuildRounds();
  }

  int getNotAllowedBid() {
    if (currentIndex != dealingIndex) return -1;

    var total = 0;
    for (var i = 1; i < players.length; i++) {
      total +=
          players[(currentIndex + i) % players.length].bids[currentRound].bid;
    }

    return roundCards[currentRound] - total;
  }

  Player getStartingPlayer() {
    var highestBid = 0;
    var highestIndex = 0;

    for (var i = 0; i < players.length; i++) {
      if (players[(currentIndex + i) % players.length].bids[currentRound].bid >
          highestBid) {
        highestIndex = i;
        highestBid =
            players[(currentIndex + i) % players.length].bids[currentRound].bid;
      }
    }

    return players[(currentIndex + highestIndex) % players.length];
  }

  int getTrickDifference() {
    return players.fold(
          0,
          (sum, player) => sum + player.bids[currentRound].bid,
        ) -
        roundCards[currentRound];
  }

  bool canUndo() {
    return _gameDataHistory.isNotEmpty;
  }

  void startGame() {
    if (_gameData.gameState != GameState.addingPlayers) return;
    _gameData.gameState = GameState.bidding;
    _gameData.currentPlayerIndex =
        (_gameData.currentDealerIndex + 1) % _gameData.players.length;

    for (var player in _gameData.players) {
      player.bids = List.filled(
        roundCards.length,
        Turn(bid: -1, state: TurnState.empty),
      );
    }
  }

  void endGame() {
    _gameData.gameState = GameState.gameOver;

    _calculateScores();
    //for (var player in _gameData.players) {
    //  //player.totalScore = player.scores.reduce((sum, score) => sum + score);
    //  player.totalScore = player.bids.fold(
    //    0,
    //    (sum, bid) => sum + (bid.state == TurnState.success ? bid.bid : 0),
    //  );
    //}
  }

  void restartGame() {
    _gameData.gameState = GameState.addingPlayers;
    _gameData.players.clear();
    _gameDataHistory.clear();

    _gameData.currentRound = 0;
    _gameData.currentPlayerIndex = 0;
    _gameData.currentDealerIndex = 0;

    _rebuildRounds();
  }

  /* Setup Actions */

  void addPlayer(String name) {
    _gameData.players.add(Player(name));
    _rebuildRounds();
  }

  void swapPlayers(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Player item = _gameData.players.removeAt(oldIndex);
    _gameData.players.insert(newIndex, item);
  }

  void removePlayer(int index) {
    _gameData.players.removeAt(index);
  }

  void setStartCardCount(int count) {
    if (count < 2) return;
    _gameData.startCard = count;

    _rebuildRounds();
  }

  /* Game Actions (Requires state recording) */
  void addGuess(int guess) {
    _recordGameState();

    currentPlayer?.bids[_gameData.currentRound] = Turn(
      bid: guess,
      state: TurnState.guess,
    );

    if (_gameData.currentPlayerIndex == _gameData.currentDealerIndex) {
      _gameData.gameState = GameState.playing;
    }

    _gameData.currentPlayerIndex =
        (_gameData.currentPlayerIndex + 1) % _gameData.players.length;
  }

  void goToNoting() {
    _recordGameState();
    if (_gameData.gameState == GameState.playing) {
      _gameData.gameState = GameState.noting;
    }
  }

  void applyScore(bool success) {
    _recordGameState();

    currentPlayer?.bids[_gameData.currentRound] = currentPlayer!
        .bids[_gameData.currentRound]
        .copyWith(state: success ? TurnState.success : TurnState.fail);

    if (_gameData.currentPlayerIndex == _gameData.currentDealerIndex) {
      _advanceRound();
    } else {
      _gameData.currentPlayerIndex =
          (_gameData.currentPlayerIndex + 1) % _gameData.players.length;
    }
  }

  void undo() {
    _gameData = _gameDataHistory.removeLast();
  }

  void updateSettings(GameSettings settings) {
    _gameSettings = settings;
    _settingsRepository.saveSettings(_gameSettings);

    if (_gameData.currentRound < _gameData.startCard) {
      _rebuildRounds();
    }

    if (settings.allwaysShowScore) {
      _calculateScores();
    } else {
      for (var player in _gameData.players) {
        player.totalScore = -1;
      }
    }
  }

  /* Private Methods */
  void _rebuildRounds() {
    _gameData.roundCards.clear();

    _gameData.roundCards.addAll(
      List.generate(_gameData.startCard - 1, (i) {
        return _gameData.startCard - i;
      }),
    );

    var numOnes = 2;

    switch (_gameSettings.oneCardMode) {
      case OneCardMode.one:
        numOnes = 1;
        break;
      case OneCardMode.two:
        numOnes = 2;
        break;
      case OneCardMode.onePerPlayer:
        numOnes = _gameData.players.length;
        break;
    }

    _gameData.roundCards.addAll(
      List.generate(numOnes, (i) {
        return 1;
      }),
    );
    _gameData.roundCards.addAll(
      List.generate(_gameData.startCard - 1, (i) {
        return 2 + i;
      }),
    );
  }

  void _calculateScores() {
    for (var player in _gameData.players) {
      player.totalScore = player.bids.fold(
        0,
        (sum, bid) =>
            sum +
            (bid.state == TurnState.success
                ? (bid.bid == 0
                      ? _gameSettings.scoreForZero
                      : int.parse("1${bid.bid}"))
                : 0),
      );
    }
  }

  void _advanceRound() {
    _gameData.gameState = GameState.bidding;
    _gameData.currentRound++;
    _gameData.currentDealerIndex =
        (_gameData.currentDealerIndex + 1) % _gameData.players.length;
    _gameData.currentPlayerIndex =
        (_gameData.currentDealerIndex + 1) % _gameData.players.length;

    if (_gameSettings.allwaysShowScore) {
      _calculateScores();
    }

    if (_gameData.currentRound >= _gameData.roundCards.length) {
      endGame();
    }
  }

  void _recordGameState() {
    _gameDataHistory.add(_gameData.copy());
  }

  /* DEBUG */
  void addDebugPlayer() {
    if (kDebugMode) {
      addPlayer("Anna");
      addPlayer("Bertil");
      addPlayer("Carl");
      addPlayer("David");
    }
  }
}
