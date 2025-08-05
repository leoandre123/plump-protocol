// ignore_for_file: public_member_api_docs, sort_constructors_first
enum TurnState { empty, guess, success, fail }

class Turn {
  final int bid;
  final TurnState state;

  const Turn({required this.bid, required this.state});

  Turn copyWith({int? bid, TurnState? state}) {
    return Turn(bid: bid ?? this.bid, state: state ?? this.state);
  }
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
}
