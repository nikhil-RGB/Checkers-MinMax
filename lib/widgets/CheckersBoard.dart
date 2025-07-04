// ignore_for_file: unnecessary_this

import 'dart:collection';
import 'dart:math';

import 'package:checkers/models/Checkers.dart';
import 'package:checkers/widgets/CheckersPiece.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

// ignore: must_be_immutable
class CheckersBoard extends StatefulWidget {
  //This field can be used to visually determine what move the AI has played.
  List<Point> redOutlineField = [];
  //The field below can be used to visually determine which pieces the AI
  //has captured.
  List<Point> redFilledField = [];
  //Reference checkers board object for this widget.
  Checkers referenceBoard;
  LinkedHashMap<Point, List<List<Point>>> possibleMoves;
  Point selectedTile = const Point(0, 0);
  Point contCapturePoint = const Point(-1, -1);
  int nonCapMoveCount = 0;
  static const int maxNonCapMoveCount = 40;
  @override
  State<CheckersBoard> createState() => _CheckersBoardState();
  CheckersBoard({super.key, required this.referenceBoard})
      : possibleMoves = referenceBoard.movesMap();
}

class _CheckersBoardState extends State<CheckersBoard> {
  bool isAIControlled = true;
  bool isGameRunning = true;
  List<Point> greenPoints = [];
  @override
  Widget build(BuildContext context) {
    greenPoints = [];
    if (widget.possibleMoves.containsKey(widget.selectedTile)) {
      List<List<Point>> moves = widget.possibleMoves[widget.selectedTile]!;
      if (moves[0][0] == const Point(-11, -11)) {
        greenPoints = moves[1];
      } else {
        for (List<Point> capDiagonal in moves) {
          greenPoints.add(capDiagonal[1]);
        }
      }
    }
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
      onLongPress: () => handleTileLongPress(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: greenPoints.contains(Point(row, col))
              ? Colors.greenAccent
              : widget.redFilledField.contains(Point(row, col))
                  ? Colors.redAccent
                  : !isPlayable
                      ? Colors.white
                      : Colors.brown,
          border: Border.all(
              width: 2.5,
              color: (widget.selectedTile == Point(row, col))
                  ? Colors.greenAccent
                  : (widget.redOutlineField.contains(Point(row, col)))
                      ? Colors.redAccent
                      : Colors.black12),
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
    if ((widget.contCapturePoint != const Point(-1, -1)) || !isGameRunning) {
      //contd capture mode
      Logger().w(
          "Control denied isGameRunning= $isGameRunning and contd capture point = ${widget.contCapturePoint.toString()}");
      return;
    }
    //block if AI opponent is enabled and it is white's turn
    if (isAIControlled && widget.referenceBoard.getColour() == "W") {
      Logger()
          .w("Control denied, colour= ${widget.referenceBoard.getColour()}");
      //AI's turn,block inputs
      return;
    }
    setState(() {
      widget.selectedTile = Point(r, c);
      widget.redOutlineField.clear();
      widget.redFilledField.clear();
    });

    // Token reference = widget.referenceBoard.board[r][c];
    // if ((reference
    //         .toString()
    //         .startsWith(widget.referenceBoard.getContraryColour())) ||
    //     (reference == Token.NONE)) {
    //Clicked on invalid tile,with no moves- no need to clear possible moves
    //since it is a LinkedHashMap with all moves for all pieces
    //widget.possibleMoves.clear();
    // } else {
    //   widget.possibleMoves = widget.referenceBoard.movesMap();
    // }
    //The above else statement is redundant since moveMap only needs to be updated on a turn change or
    //in case of a continued capture(for which handling logic is already implemented).
    // }
  }

  //handle selection for final destination of piece-SHORT PRESS
  //also has to handle win condition checking and kinging of tokens
  void handleTilePress(int r, int c) async {
    if (widget.possibleMoves.isEmpty ||
        !widget.possibleMoves.containsKey(widget.selectedTile) ||
        !isGameRunning) {
      return;
    }
//Check if AI is enabled and it is it's turn to play
    if (isAIControlled && widget.referenceBoard.getColour() == "W") {
      //AI's turn,block inputs
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

      //Token at og location should be NONE
      game.setAt(originalLocation, Token.NONE);
      //Token at new location should be the checkers token moved
      game.setAt(newLocation, piece);

      widget.referenceBoard.kingAfterMove(newLocation);

      //Check for n-standard moves game ender
      ++widget.nonCapMoveCount;
      if (widget.nonCapMoveCount >= CheckersBoard.maxNonCapMoveCount) {
        //Game tied, end game with tie dialogue
        isGameRunning = false;
        showGameOverDialog(context,
            "Tie- \n Too many non-capture moves played (>=${CheckersBoard.maxNonCapMoveCount})");
      }
    } else {
      widget.nonCapMoveCount =
          0; //Reset to 0, since a capture is being made now
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

      game.setAt(originalLocation, Token.NONE);
      game.setAt(victimLocation, Token.NONE);
      game.setAt(newLocation, piece);

      widget.referenceBoard.kingAfterMove(newLocation);
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
      //king current player if required.
      // widget.referenceBoard.kingAfterMove(newLocation);
      //change location back to where piece shifting is done
      widget.referenceBoard.counter++;
      widget.possibleMoves = widget.referenceBoard.movesMap();
      widget.selectedTile = const Point(0, 0);
    } else {
      //king current player if required.
      // widget.referenceBoard.kingAfterMove(newLocation);
      //change location back to where piece shifting is done
      LinkedHashMap<Point, List<List<Point>>> posMoves = LinkedHashMap();
      posMoves[widget.contCapturePoint] = contCapList;
      widget.possibleMoves = posMoves;
      widget.selectedTile = widget.contCapturePoint;
    }
    setState(() {});
    //Check if the game is over. If so, display the winner.
    if (widget.possibleMoves.isEmpty) {
      isGameRunning = false;
      String winner = widget.referenceBoard.getContraryColour();
      winner = (winner == "W") ? "White" : "Black";
      showGameOverDialog(context, winner);
    } else //if game is not over, check for AI being enabled and allow AI to play if it
    {
      //is it's turn
      if (!(isAIControlled && widget.referenceBoard.getColour() == "W")) {
        //NOT AI's turn, terminate
        return;
      }
      //move start print data
      Logger().wtf("After User Move");
      widget.referenceBoard.debug();
      await Future.delayed(
          const Duration(seconds: 1, milliseconds: 600), () {});
      Checkers board =
          Checkers.beginMinimax(widget.referenceBoard, widget.nonCapMoveCount);
      List<List<Point>> outlineAndFilledList =
          this.tileColorCheck(widget.referenceBoard, board);
      setState(() {
        widget.redOutlineField = outlineAndFilledList[0];
      });
      await Future.delayed(
          const Duration(seconds: 1, milliseconds: 940), () {});
      //write code here to finish up setting new board and resetting state values to mimic a human move
      setState(() {
        widget.referenceBoard = board;
        widget.possibleMoves = widget.referenceBoard.movesMap();
        widget.selectedTile = const Point(0, 0);
        widget.nonCapMoveCount = widget.referenceBoard.nonCapMovesTemp;

        widget.redFilledField = outlineAndFilledList[1];

        //move end print data
        Logger().wtf("After AI Move");
        widget.referenceBoard.debug();
      });
//Check if AI won

      if (widget.possibleMoves.isEmpty) {
        isGameRunning = false;
        String winner = widget.referenceBoard.getContraryColour();
        winner = (winner == "W") ? "White" : "Black";
        showGameOverDialog(context, winner);
      }

//End check

//Check if AI caused tie by non-cap move limit

      if (widget.nonCapMoveCount >= CheckersBoard.maxNonCapMoveCount) {
        //Game tied, end game with tie dialogue
        isGameRunning = false;
        showGameOverDialog(context,
            "Tie- \n Too many non-capture moves played (>=${CheckersBoard.maxNonCapMoveCount})");
      }

//End check
    }
  }

  //Return a List to compare the boards and return a list of list of points for
  //red outline(self-movement)-0 and red filled(captured enemies)-1
  List<List<Point>> tileColorCheck(Checkers originalBoard, Checkers newBoard) {
    List<Point> redFilled = []; //1
    List<Point> redOutline = []; //0
    for (int i = 0; i < 8; ++i) {
      for (int j = 0; j < 8; ++j) {
        //Since the AI has completed it's turn by the time
        //this function is called, it is black's turn now
        //Since it is black's turn, consider the opposite color(white) for all computations.
        Token ogPiece = originalBoard.board[i][j];
        Token newPiece = newBoard.board[i][j];
        //red outline means that the spot has a white piece moved
        //into or out of it. Filled means captured black piece.
        if ((ogPiece.isWhite() && newPiece == Token.NONE) ||
            (ogPiece == Token.NONE && newPiece.isWhite())) {
          //insert red outline at location's tile
          redOutline.add(Point(i, j));
        } else if (ogPiece.isBlack() && newPiece == Token.NONE) {
          redFilled.add(Point(i, j));
        }
      }
    }
    List<List<Point>> result = [redOutline, redFilled];
    return result;
  }
}

void showGameOverDialog(BuildContext context, String winner) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.brown, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Game Over',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                (winner.length > 5)
                    ? winner
                    : '$winner has won the game!', // Added draw condition
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(120, 40),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
