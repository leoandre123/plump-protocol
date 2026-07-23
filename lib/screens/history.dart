import 'package:flutter/material.dart';
import 'package:plumpen_app/framework/game_theme.dart';
import 'package:plumpen_app/models/game_history_entry.dart';
import 'package:plumpen_app/repositories/game_history_repository.dart';
import 'package:plumpen_app/utils/protocol_sharing.dart';
import 'package:plumpen_app/widgets/score_table.dart';

String _formatDate(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  return "${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}";
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final GameHistoryRepository _repository = GameHistoryRepository();
  List<GameHistoryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _repository.loadHistory();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _delete(int index) async {
    await _repository.deleteEntryAt(index);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(
      context,
    ).extension<GameTheme>()!.tableBackground;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historik"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
          ? const Center(child: Text("Ingen historik än"))
          : ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                final players = entry.gameData.players;
                final winner = players.isEmpty
                    ? null
                    : players.reduce(
                        (a, b) => a.totalScore > b.totalScore ? a : b,
                      );

                return Dismissible(
                  key: ValueKey(
                    "${entry.playedAt.toIso8601String()}_$index",
                  ),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _delete(index),
                  child: ListTile(
                    title: Text(players.map((p) => p.name).join(", ")),
                    subtitle: Text(
                      winner != null
                          ? "${_formatDate(entry.playedAt)} • ${winner.name} vann (${winner.totalScore} p)"
                          : _formatDate(entry.playedAt),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HistoryDetailPage(entry: entry),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      ),
    );
  }
}

class HistoryDetailPage extends StatelessWidget {
  final GameHistoryEntry entry;

  const HistoryDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final gameData = entry.gameData;

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatDate(entry.playedAt)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              shareProtocolImage(
                context: context,
                protocolWidget: ScoreTable(
                  players: gameData.players,
                  roundCards: gameData.roundCards,
                  currentRound: -1,
                  dealerIndex: gameData.currentDealerIndex,
                  currentIndex: -10,
                  scoreForZero: entry.scoreForZero,
                  scrollable: false,
                ),
                text: "Plump-protokoll – ${_formatDate(entry.playedAt)}",
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ScoreTable(
          players: gameData.players,
          roundCards: gameData.roundCards,
          currentRound: -1,
          dealerIndex: gameData.currentDealerIndex,
          currentIndex: -10,
          scoreForZero: entry.scoreForZero,
        ),
      ),
    );
  }
}
