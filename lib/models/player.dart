// ignore_for_file: public_member_api_docs, sort_constructors_first
enum TurnState { empty, guess, success, fail }

class Turn {
  final int bid;
  final TurnState state;

  const Turn({required this.bid, required this.state});

  Turn copyWith({int? bid, TurnState? state}) {
    return Turn(bid: bid ?? this.bid, state: state ?? this.state);
  }

  Map<String, dynamic> toJson() => {'bid': bid, 'state': state.index};

  factory Turn.fromJson(Map<String, dynamic> json) => Turn(
    bid: json['bid'] as int,
    state: TurnState.values[json['state'] as int],
  );
}

class Player {
  Player(this.name);

  String name;
  List<Turn> bids = [];

  int totalScore = -1;

  Player copy() {
    var player = Player(name);
    player.bids = bids.map((p) => p.copyWith()).toList();
    player.totalScore = totalScore;
    return player;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'bids': bids.map((b) => b.toJson()).toList(),
    'totalScore': totalScore,
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    var player = Player(json['name'] as String);
    player.bids = (json['bids'] as List)
        .map((b) => Turn.fromJson(b as Map<String, dynamic>))
        .toList();
    player.totalScore = json['totalScore'] as int;
    return player;
  }
}
