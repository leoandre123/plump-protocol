import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plumpen_app/controllers/game_controller.dart';
import 'package:plumpen_app/dialogs/settings_dialog.dart';
import 'package:plumpen_app/framework/game_theme.dart';
import 'package:plumpen_app/models/game_data.dart';
import 'package:plumpen_app/widgets/numpad.dart';
import 'package:plumpen_app/widgets/score_table.dart';

class GamePage extends StatefulWidget {
  final void Function(ThemeMode) onThemeChanged;

  const GamePage({super.key, required this.onThemeChanged});

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final GameController _controller = GameController(10);

  Widget getActionContent() {
    Color textColor = Theme.of(context).extension<GameTheme>()!.tableForeground;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (_controller.gameState) {
      case GameState.addingPlayers:
        return Column(
          children: [
            ElevatedButton(
              onPressed: () {
                _showAddPlayerDialog(context);
              },
              child: Text("Lägg till spelare"),
            ),
            ElevatedButton(
              onPressed: () {
                _showEditPlayersDialog(context);
              },
              child: Text("Ändra/ta bort spelare"),
            ),
            //Padding(padding: EdgeInsetsGeometry.all(16.0)),
            Text("Antal startkort"),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: 32.0,
                  onPressed: () {
                    setState(() {
                      _controller.setStartCardCount(_controller.startCard - 1);
                    });
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text(_controller.startCard.toString()),
                IconButton(
                  iconSize: 32.0,
                  onPressed: () {
                    setState(() {
                      _controller.setStartCardCount(_controller.startCard + 1);
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            Text(
              _controller.players.length < 2 ? "Minst 2 spelare" : "",
              style: TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: _controller.players.length < 2
                  ? null
                  : () {
                      setState(() {
                        _controller.startGame();
                      });
                    },
              child: Text("Starta"),
            ),
          ],
        );
      case GameState.bidding:
        var notAllowed = _controller.getNotAllowedBid();

        return Column(
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: textColor),
                children: [
                  TextSpan(
                    text: _controller.currentPlayer?.name,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: " ger bud"),
                ],
              ),
            ),
            Numpad(
              numbers: _controller.roundCards[_controller.currentRound],
              except: notAllowed,
              onKeyPressed: (numPressed) {
                setState(() {
                  assert(numPressed != -1);
                  _controller.addGuess(numPressed);
                });
              },
            ),
          ],
        );
      case GameState.playing:
        return Column(
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: textColor),
                children: [
                  TextSpan(
                    text: _controller.getStartingPlayer().name,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: " börjar!"),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _controller.goToNoting();
                });
              },
              child: Text("Gå vidare!"),
            ),
          ],
        );
      case GameState.noting:
        return Column(
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: textColor),
                children: [
                  TextSpan(text: "Tog "),
                  TextSpan(
                    text: "${_controller.currentPlayer?.name} ",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        "${_controller.currentPlayer?.bids[_controller.currentRound].bid}",
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.solid,
                    ),
                  ),
                  TextSpan(text: " stick?"),
                ],
              ),
            ),
            //Text(
            //  "Tog ${_controller.currentPlayer?.name} ${_controller.currentPlayer?.bids[_controller.currentRound].bid} stick?",
            //  style: Theme.of(
            //    context,
            //  ).textTheme.headlineSmall?.copyWith(color: textColor),
            //),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _controller.applyScore(true);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.green.shade100
                        : Colors.green.shade300,
                    foregroundColor: isDark
                        ? Colors.green.shade900
                        : Colors.white,
                  ),
                  child: Text("Ja"),
                ),
                Padding(padding: EdgeInsetsGeometry.all(5)),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _controller.applyScore(false);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.red.shade200
                        : Colors.red.shade300,
                    foregroundColor: isDark
                        ? Colors.red.shade900
                        : Colors.white,
                  ),
                  child: Text("Nej"),
                ),
              ],
            ),
          ],
        );
      case GameState.gameOver:
        return Column(
          children: [
            Text(
              "${_controller.players.reduce((a, b) {
                return a.totalScore > b.totalScore ? a : b;
              }).name} vann!",
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Padding(padding: EdgeInsetsGeometry.all(16.0)),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _controller.restartGame();
                });
              },
              child: Text("Ny runda"),
            ),
          ],
        );
    }
  }

  void _showAddPlayerDialog(BuildContext context) {
    final TextEditingController editingController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Lägg till spelare"),
          content: TextField(
            controller: editingController,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(hintText: "Namn..."),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Avbryt"),
            ),
            TextButton(
              onPressed: () {
                String input = editingController.text;
                setState(() {
                  _controller.addPlayer(input);
                });

                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showEditPlayersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text("Ändra spelare"),
              content: SizedBox(
                height: MediaQuery.of(context).size.height / 2.5,
                width: MediaQuery.of(context).size.width,
                child: ReorderableListView.builder(
                  shrinkWrap: false,
                  buildDefaultDragHandles: true,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(_controller.players[index].name),
                    subtitle: Text(
                      index == 0
                          ? "Delar ut"
                          : index == 1
                          ? "Börjar buda"
                          : "",
                    ),
                    key: ValueKey(index),
                    trailing: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                "Ta bort ${_controller.players[index].name}?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Avbryt"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _controller.removePlayer(index);
                                    });
                                    dialogSetState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Ja"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      _controller.swapPlayers(oldIndex, newIndex);
                    });
                    dialogSetState(() {});
                  },
                  itemCount: _controller.players.length,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Starta om spel?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Avbryt"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _controller.restartGame();
                });
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).extension<GameTheme>()!.tableForeground;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = Theme.of(
      context,
    ).extension<GameTheme>()!.tableBackground;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            widget.onThemeChanged(isDark ? ThemeMode.light : ThemeMode.dark);
          },
          color: Colors.white,
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
        ),
        title: Text(
          "Plump",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        actions: [
          (kDebugMode
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _controller.addDebugPlayer();
                    });
                  },
                  icon: const Icon(Icons.group_add),
                )
              : SizedBox()),
          IconButton(
            onPressed: () {
              _showRestartDialog(context);
            },
            color: Colors.white,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) =>
                    SettingsDialog(initialSettings: _controller.gameSettings),
              ).then((newSettings) {
                if (newSettings != null) {
                  setState(() {
                    _controller.updateSettings(newSettings);
                  });
                }
              });
            },
            color: Colors.white,
            icon: const Icon(Icons.settings),
          ),
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleTextStyle: Theme.of(context).textTheme.titleMedium,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: EdgeInsetsGeometry.all(0),
          child: Column(
            children: [
              Expanded(
                child: ScoreTable(
                  players: _controller.players,
                  roundCards: _controller.roundCards,
                  currentRound: _controller.currentRound,
                  dealerIndex: _controller.dealingIndex,
                  currentIndex:
                      (_controller.gameState == GameState.noting ||
                          _controller.gameState == GameState.bidding)
                      ? _controller.currentIndex
                      : -10,
                  scoreForZero: _controller.gameSettings.scoreForZero,
                ),
              ),
              SizedBox(
                height:
                    MediaQuery.of(context).size.height /
                    (_controller.gameState == GameState.addingPlayers
                        ? 2
                        : 2.8),
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff343231) : Colors.white,
                    boxShadow: [
                      BoxShadow(blurRadius: 20, color: Colors.black26),
                    ],
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: SizedBox.expand(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: _controller.canUndo()
                                        ? () {
                                            setState(() {
                                              _controller.undo();
                                            });
                                          }
                                        : null,
                                    child: Text("Ångra"),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    "${_controller.numCards == -1 ? _controller.roundCards[0] : _controller.numCards} kort",
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(color: textColor),
                                  ),
                                  Text(
                                    _controller.dealingPlayer != null
                                        ? "${_controller.dealingPlayer?.name} delar ut"
                                        : "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: textColor),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(child: Text("")),
                          ],
                        ),
                        Divider(),
                        Expanded(
                          child: SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: MediaQuery.of(context).size.width,
                              ),
                              child: getActionContent(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
