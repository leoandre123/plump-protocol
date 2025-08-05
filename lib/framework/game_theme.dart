import 'package:flutter/material.dart';

class GameTheme extends ThemeExtension<GameTheme> {
  final Color tableHeaderBackground;
  final Color tableHeaderForeground;

  final Color tableBackground;
  final Color tableForeground;

  final Color tableActiveBackground;
  final Color tableActiveForeground;

  final Color tableHeaderBorder;
  final Color tableBorder;

  const GameTheme({
    required this.tableHeaderBackground,
    required this.tableHeaderForeground,
    required this.tableBackground,
    required this.tableForeground,
    required this.tableActiveBackground,
    required this.tableActiveForeground,
    required this.tableHeaderBorder,
    required this.tableBorder,
  });

  @override
  ThemeExtension<GameTheme> copyWith({
    Color? tableHeaderBackground,
    Color? tableHeaderForeground,
    Color? tableBackground,
    Color? tableForeground,
    Color? tableActiveBackground,
    Color? tableActiveForeground,
    Color? tableHeaderBorder,
    Color? tableBorder,
  }) {
    return GameTheme(
      tableHeaderBackground:
          tableHeaderBackground ?? this.tableHeaderBackground,
      tableHeaderForeground:
          tableHeaderForeground ?? this.tableHeaderForeground,
      tableBackground: tableBackground ?? this.tableBackground,
      tableForeground: tableForeground ?? this.tableForeground,
      tableActiveBackground:
          tableActiveBackground ?? this.tableActiveBackground,
      tableActiveForeground:
          tableActiveForeground ?? this.tableActiveForeground,
      tableHeaderBorder: tableHeaderBorder ?? this.tableHeaderBorder,
      tableBorder: tableBorder ?? this.tableBorder,
    );
  }

  @override
  ThemeExtension<GameTheme> lerp(
    covariant ThemeExtension<GameTheme>? other,
    double t,
  ) {
    if (other is! GameTheme) return this;

    Color.lerp(tableHeaderBackground, other.tableActiveBackground, t);

    return GameTheme(
      tableHeaderBackground: Color.lerp(
        tableHeaderBackground,
        other.tableHeaderBackground,
        t,
      )!,
      tableHeaderForeground: Color.lerp(
        tableHeaderForeground,
        other.tableHeaderForeground,
        t,
      )!,
      tableBackground: Color.lerp(tableBackground, other.tableBackground, t)!,
      tableForeground: Color.lerp(tableForeground, other.tableForeground, t)!,
      tableActiveBackground: Color.lerp(
        tableActiveBackground,
        other.tableActiveBackground,
        t,
      )!,
      tableActiveForeground: Color.lerp(
        tableActiveForeground,
        other.tableActiveForeground,
        t,
      )!,
      tableHeaderBorder: Color.lerp(
        tableHeaderBorder,
        other.tableHeaderBorder,
        t,
      )!,
      tableBorder: Color.lerp(tableBorder, other.tableBorder, t)!,
    );
  }
}
