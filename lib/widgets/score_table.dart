import 'dart:math';

import 'package:flutter/material.dart';
import 'package:plumpen_app/framework/game_theme.dart';
import 'package:plumpen_app/models/player.dart';

class ScoreTable extends StatelessWidget {
  final List<Player> players;
  final List<int> roundCards;
  final int currentRound;
  final int dealerIndex;
  final int currentIndex;
  final int scoreForZero;

  const ScoreTable({
    super.key,
    required this.players,
    required this.roundCards,
    required this.currentRound,
    required this.dealerIndex,
    required this.currentIndex,
    required this.scoreForZero,
  });

  @override
  Widget build(BuildContext context) {
    Color headerFg = Theme.of(
      context,
    ).extension<GameTheme>()!.tableHeaderForeground;
    Color headerBg = Theme.of(
      context,
    ).extension<GameTheme>()!.tableHeaderBackground;

    Color headerBorder = Theme.of(
      context,
    ).extension<GameTheme>()!.tableHeaderBorder;
    Color border = Theme.of(context).extension<GameTheme>()!.tableBorder;

    Color tableFg = Theme.of(context).extension<GameTheme>()!.tableForeground;
    Color tableBg = Theme.of(context).extension<GameTheme>()!.tableBackground;
    Color tableBgActiveRow = Theme.of(
      context,
    ).extension<GameTheme>()!.tableActiveBackground;

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Table(
          border: TableBorder.all(
            color: headerBorder,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          columnWidths: <int, TableColumnWidth>{0: FixedColumnWidth(64.0)},
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              children: List.generate(max(players.length + 1, 2), (col) {
                return Center(
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(5),
                    child: Wrap(
                      //mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          col == 0
                              ? "# kort"
                              : col - 1 < players.length
                              ? players[col - 1].name
                              : "",
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: headerFg,
                                fontWeight: currentIndex == col - 1
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                        (col - 1 == dealerIndex
                            ? Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Icon(Icons.style, color: headerFg),
                              )
                            : SizedBox()),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(color: border),
                    verticalInside: BorderSide(color: border),
                  ),
                  columnWidths: <int, TableColumnWidth>{
                    0: FixedColumnWidth(64.0),
                  },
                  children: List.generate(roundCards.length + 1, (row) {
                    return TableRow(
                      children: List.generate(max(players.length + 1, 2), (
                        col,
                      ) {
                        return Container(
                          height: 32.0,
                          color: (row == currentRound && col - 1 == currentIndex
                              ? Color(0x30000000)
                              : Colors.transparent),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: getTableContent(col, row, tableFg),
                            ),
                          ),
                        );
                      }),
                      decoration: BoxDecoration(
                        color: row == currentRound ? tableBgActiveRow : tableBg,
                      ),
                    );
                  }),
                ),
                Container(
                  height: 20.0,
                  decoration: BoxDecoration(color: tableBg),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getTableContent(int col, int row, Color textColor) {
    var player = col - 1;
    var round = row;

    final textStyle = TextStyle(fontSize: 14.0, color: textColor);
    final fontSize = textStyle.fontSize ?? 14.0;

    if (round == roundCards.length) {
      return Text(
        col == 0
            ? "Tot"
            : player >= players.length || players[player].totalScore == -1
            ? ""
            : players[player].totalScore.toString(),
        style: textStyle,
      );
    }

    if (col == 0) return Text(roundCards[round].toString(), style: textStyle);

    if (player >= players.length) {
      return Text("");
    }

    if (players[player].bids.isEmpty) return SizedBox();
    var bid = players[player].bids[round];
    switch (bid.state) {
      case TurnState.empty:
        return SizedBox();
      case TurnState.guess:
        return Text(bid.bid.toString(), style: textStyle);
      case TurnState.success:
        var result = bid.bid == 0 ? scoreForZero : int.parse("1${bid.bid}");
        return Text("$result", style: textStyle);
      case TurnState.fail:
        return Container(
          width: fontSize * 1.5,
          height: fontSize * 1.5,
          decoration: BoxDecoration(shape: BoxShape.circle, color: textColor),
        );
    }
  }
}
