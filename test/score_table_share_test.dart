import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plumpen_app/framework/game_theme.dart';
import 'package:plumpen_app/models/player.dart';
import 'package:plumpen_app/widgets/score_table.dart';
import 'package:screenshot/screenshot.dart';

ThemeData _testTheme() {
  return ThemeData.light().copyWith(
    extensions: [
      GameTheme(
        tableHeaderBackground: Colors.grey,
        tableHeaderForeground: Colors.black,
        tableBackground: Colors.white,
        tableForeground: Colors.black,
        tableActiveBackground: Colors.green,
        tableActiveForeground: Colors.black,
        tableHeaderBorder: Colors.black12,
        tableBorder: Colors.black12,
      ),
    ],
  );
}

void main() {
  testWidgets(
    'captureFromLongWidget captures the full protocol, not just one screen',
    (tester) async {
      // Simulate a small phone viewport.
      await tester.binding.setSurfaceSize(const Size(400, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final players = [Player('Anna'), Player('Bo'), Player('Cissi')];
      // Enough rounds that the table is far taller than the 700px viewport.
      final roundCards = List<int>.generate(40, (i) => 40 - i);

      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          theme: _testTheme(),
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const Scaffold(body: SizedBox());
            },
          ),
        ),
      );

      final bytes = await tester.runAsync(() {
        return ScreenshotController().captureFromLongWidget(
          InheritedTheme.captureAll(
            capturedContext,
            Material(
              child: ScoreTable(
                players: players,
                roundCards: roundCards,
                currentRound: -1,
                dealerIndex: -1,
                currentIndex: -10,
                scoreForZero: 0,
                scrollable: false,
              ),
            ),
          ),
          context: capturedContext,
          pixelRatio: 1.0,
          constraints: const BoxConstraints.tightFor(width: 400),
        );
      });

      expect(bytes, isNotNull);

      final codec = await ui.instantiateImageCodec(bytes!);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // Header row (~44px) + 41 data rows at 42px each (32 content + 10
      // padding) + a 20px footer spacer, comfortably exceeds one 700px
      // "screen" worth of content — proving the capture isn't clipped to
      // the viewport the way the old on-screen RepaintBoundary capture was.
      expect(image.height, greaterThan(700));
    },
  );
}
