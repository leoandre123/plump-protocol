enum OneCardMode {
  onePerPlayer,
  one,
  two;

  String get label {
    switch (this) {
      case OneCardMode.onePerPlayer:
        return "En per spelare";
      case OneCardMode.one:
        return "En";
      case OneCardMode.two:
        return "Två";
    }
  }
}

class GameSettings {
  GameSettings({
    this.oneCardMode = OneCardMode.two,
    this.scoreForZero = 5,
    this.allwaysShowScore = false,
  });

  OneCardMode oneCardMode;
  int scoreForZero;
  bool allwaysShowScore;

  Map<String, String> toMap() {
    return {
      "oneCardMode": oneCardMode.name,
      "scoreForZero": scoreForZero.toString(),
      "allwaysShowScore": allwaysShowScore.toString(),
    };
  }

  static GameSettings fromMap(Map<String, String> map) {
    return GameSettings(
      oneCardMode: OneCardMode.values.firstWhere(
        (e) => e.name == map['oneCardMode'],
        orElse: () => OneCardMode.two,
      ),
      scoreForZero: int.tryParse(map['scoreForZero'] ?? "") ?? 5,
      allwaysShowScore: bool.tryParse(map['allwaysShowScore'] ?? "") ?? false,
    );
  }
}
