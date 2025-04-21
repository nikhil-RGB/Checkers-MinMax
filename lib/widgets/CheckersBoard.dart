import 'package:checkers/models/Checkers.dart';
import 'package:checkers/widgets/CheckersPiece.dart';
import 'package:flutter/material.dart';

class CheckersBoard extends StatefulWidget {
  //Reference checkers board object for this widget.
  Checkers referenceBoard;
  @override
  State<CheckersBoard> createState() => _CheckersBoardState();
  CheckersBoard({super.key, required this.referenceBoard});
}

class _CheckersBoardState extends State<CheckersBoard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemCount: 64,
          itemBuilder: (context, index) => buildTile(index),
        ),
      ),
    );
  }

  Widget buildTile(int index) {
    final row = index ~/ 8;
    final col = index % 8;
    final isPlayable = Checkers.isTilePlayable(row, col);
    final piece = widget.referenceBoard.board[row][col];

    return GestureDetector(
      onTap: () => handleTileTap(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: !isPlayable ? Colors.white : Colors.brown,
          border: Border.all(color: Colors.black12),
        ),
        child: Center(
          child: CheckersPiece(tokType: piece.toString()),
        ),
      ),
    );
  }

  void handleTileTap(int r, int c) {}
}
