import 'package:flutter/material.dart';

class Numpad extends StatelessWidget {
  final void Function(int) onKeyPressed;
  final int numbers;
  final int except;
  const Numpad({
    required this.numbers,
    required this.except,
    super.key,
    required this.onKeyPressed,
  });

  @override
  Widget build(BuildContext context) {
    var numbersList = [];
    for (var i = 0; i <= numbers; i++) {
      numbersList.add(i);
    }

    return Table(
      children: List.generate((numbersList.length / 3).ceil(), (row) {
        return TableRow(
          children: List.generate(3, (col) {
            int index = row * 3 + col;
            return index < numbersList.length
                ? Padding(
                    padding: EdgeInsetsGeometry.only(left: 10, right: 10),
                    child: ElevatedButton(
                      onPressed: numbersList[index] == except
                          ? null
                          : () {
                              onKeyPressed(numbersList[index]);
                            },
                      child: Text(numbersList[index].toString()),
                    ),
                  )
                : Text("");
          }),
        );
      }),
    );
  }
}
