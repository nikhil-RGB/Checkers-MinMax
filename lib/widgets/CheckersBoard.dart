import 'dart:collection';
import 'dart:math';

import 'package:checkers/models/Checkers.dart';
import 'package:checkers/widgets/CheckersPiece.dart';
import 'package:flutter/material.dart';

class CheckersBoard extends StatefulWidget {
  //Reference checkers board object for this widget.
  Checkers referenceBoard;
  LinkedHashMap<Point, List<List<Point>>> possibleMoves;
  Point selectedTile = const Point(0, 0);
  Point contCapturePoint = const Point(-1, -1);
  @override
  State<CheckersBoard> createState() => _CheckersBoardState();
  CheckersBoard({super.key, required this.referenceBoard})
      : possibleMoves = referenceBoard.movesMap();
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
      onTap: () => handleTilePress(row, col),
      onLongPress: handleTileLongPress(row, col),
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

  //handle selection for which piece move-LONG PRESS
  //disable if contd capture is available
  void handleTileLongPress(int r, int c) {
    if (widget.contCapturePoint != const Point(-1, -1)) {
      //contd capture mode
      return;
    }
    widget.selectedTile = Point(r, c);
    Token reference = widget.referenceBoard.board[r][c];
    if ((reference
            .toString()
            .startsWith(widget.referenceBoard.getContraryColour())) ||
        (reference == Token.NONE)) {
      //Clicked on invalid tile,reset possible moves
      widget.possibleMoves.clear();
    } else {
      widget.possibleMoves = widget.referenceBoard.movesMap();
    }
  }

  //handle selection for final destination of piece-SHORT PRESS
  //also has to handle win condition checking and kinging of tokens
  void handleTilePress(int r, int c) {
    if (widget.possibleMoves.isEmpty ||
        !widget.possibleMoves.containsKey(widget.selectedTile)) {
      return;
    }
    //Currently selected long press tile has valid moves available
    Point newLocation = Point(r, c);
    Point originalLocation = widget.selectedTile;
    Checkers game = widget.referenceBoard;
    Token piece = game.getAt(originalLocation);

    List<List<Point>> validChoices = widget.possibleMoves[widget.selectedTile]!;
    bool isStandardMove = validChoices[0][0] == const Point(-11, -11);

    List<List<Point>> contCapList =
        []; //list of moves possible in case of contd capture

    if (isStandardMove) {
      List<Point> possibleDestinations = validChoices[1];
      if (!possibleDestinations.contains(Point(r, c))) {
        //Tile pressed location is not a valid destination
        return;
      }
      //Here, execute the move and update the board

      // setState(() {
      //Token at og location should be NONE
      game.setAt(originalLocation, Token.NONE);
      //Token at new location should be the checkers token moved
      game.setAt(newLocation, piece);
      // });
    } else {
      //Control reaching here means that a piece must be eliminated alongside moving the reference piece
      //The move type is one of a capture type.
      List<Point> selectedDiagonal = [];
      for (List<Point> diagonal in validChoices) {
        if (diagonal[1] == newLocation) {
          selectedDiagonal = diagonal;
          break;
        }
      }
      if (selectedDiagonal.isEmpty) {
        return; //Not a valid location
      }
      //here, execute capture and check for chained capture
      Point victimLocation = selectedDiagonal[0];
      // setState(() {
      game.setAt(originalLocation, Token.NONE);
      game.setAt(victimLocation, Token.NONE);
      game.setAt(newLocation, piece);
      // });

      //contd capture check
      contCapList = game.captureSequences(newLocation);
      if (contCapList.isNotEmpty) {
        //CONTD CAPTURE MODE
        widget.contCapturePoint = newLocation;
      } else {
        widget.contCapturePoint = const Point(-1, -1);
        //end contd capture
      }
    }
    //Here- Write code to reset possibleMoves and selectedTile
    //This data should be updated in all cases except those of invalid tile selections
    //and continued captures
    //invalid cases= cases where a return statement is explicitly written.
    if (widget.contCapturePoint == const Point(-1, -1)) {
      widget.referenceBoard.counter++;
      widget.possibleMoves = widget.referenceBoard.movesMap();
      widget.selectedTile = const Point(0, 0);
    } else {
      LinkedHashMap<Point, List<List<Point>>> posMoves = LinkedHashMap();
      posMoves[widget.contCapturePoint] = contCapList;
      widget.possibleMoves = posMoves;
      widget.selectedTile = widget.contCapturePoint;
    }
    setState(() {});
  }
}
