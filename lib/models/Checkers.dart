// ignore_for_file: unnecessary_this

import 'dart:html';
import 'dart:math';

import 'package:logger/logger.dart';

class Checkers {
  List<List<Token>> board = List.generate(8, (i) => List.filled(8, Token.NONE));
  //Board state information is stored in the instance variable above
  int counter = 0; //even means black's turn, odd means white's turn
  //main method here
  static void main() {
    Checkers game = Checkers();
    game.initBoard();
    game.printBoard();
  }

  //Determines whether a token can be placed in the selected tile/whether the selected tile is black
  bool isTilePlayable(int r, int c) {
    return (((r % 2 == 0) && (c % 2 != 0)) || ((r % 2 != 0) && (c % 2 == 0)));
  }

  //Initialize the board with the initial set of playing tokens
  void initBoard() {
    //Initialize black tokens
    for (int i = 0; i < 3; ++i) {
      for (int j = 0; j < 8; ++j) {
        if (isTilePlayable(i, j)) {
          //Place black token
          this.board[i][j] = Token.BLACK_SOLDIER;
        } else {
          this.board[i][j] = Token.NONE;
        }
      }
    }

    //Initialize all empty in-between playable areas to NONE
    for (int i = 3; i < 5; ++i) {
      for (int j = 0; j < 8; ++j) {
        //Insert the NONE token
        this.board[i][j] = Token.NONE;
      }
    }

    //Initialize remaining empty playable areas to WHITE_SOLDIER
    for (int i = 5; i < 8; ++i) {
      for (int j = 0; j < 8; ++j) {
        if (isTilePlayable(i, j)) {
          this.board[i][j] = Token.WHITE_SOLDIER;
        } else {
          this.board[i][j] = Token.NONE;
        }
      }
    }
  }

  //Prints the board
  void printBoard() {
    String concat = "\n";
    for (int i = 0; i < 8; ++i) {
      for (int j = 0; j < 8; ++j) {
        concat += ("${this.board[i][j]}  ");
      }
      concat += ("\n");
    }
    print(concat);
  }

  //come back to complete this method
  //should present all legal moves for the current player
  List<Point> legalMoves() {
    List<Point> points = [];
    return points;
  }

  //get diagonals, forward right, back left, forward left, back right, based on forward or backward preference
  //down=true means that the diagonal will go from the top of the board to the bottom
  //This method will have to be run twice to get all 4 diagonal movements for a king checker piece
  List<List<Point>> getDiagonals(int x, int y, bool down) {
    int x1 = x;
    int y1 = y;
    List<List<Point>> diagonals = [];
    List<Point> diagonal1 = [];
    List<Point> diagonal2 = [];
    for (int i = 0; i < 2; ++i) {
      if (down) {
        if (x1 < 7 && y1 < 7) {
          diagonal1.add(Point(++x1, ++y1));
        }
        if (x < 7 && y > 0) {
          diagonal2.add(Point(++x, --y));
        }
      } else {
        if (x1 > 0 && y1 > 0) {
          diagonal1.add(Point(--x1, --y1));
        }
        if (x > 0 && y < 7) {
          diagonal2.add(Point(--x, ++y));
        }
      }
    }
    diagonals.addAll([diagonal1, diagonal2]);
    return diagonals;
  }

  //Capture sequences for a particular spot
  List<List<Point>> captureSequences(Point target) {
    List<List<Point>> sequences = [];
    Token referenceChecker = this.board[target.x.toInt()][target.y.toInt()];
    if (referenceChecker == Token.NONE) {
      throw "Capture sequences should not be called on a blank target square";
    }
    List<List<Point>> diagonalsSoldier = this.getDiagonals(
        target.x.toInt(), target.y.toInt(), referenceChecker.isBlack());
    List<List<Point>> diagonalsKing = this.getDiagonals(
        target.x.toInt(), target.y.toInt(), !referenceChecker.isBlack());
    SOLDIER_DIAGONAL_LOOP:
    for (int i = 0; i < diagonalsSoldier.length; ++i) {
      //Diagonal list:
      List<Point> diagonal = diagonalsSoldier[i];
      if (diagonal.length < 2) {
        continue SOLDIER_DIAGONAL_LOOP;
      }
      Token cap_spot = this.board[diagonal[0].x.toInt()][diagonal[0].y.toInt()];
      if (cap_spot == Token.NONE ||
          (!Token.isEnemy(referenceChecker, cap_spot))) {
        continue SOLDIER_DIAGONAL_LOOP;
      }
      if (this.board[diagonal[1].x.toInt()][diagonal[1].y.toInt()] ==
          Token.NONE) {
        sequences.add(diagonal);
      }
    }

    //Now, we account for king pieces, which can move backwards.
    if (referenceChecker == Token.BLACK_KING ||
        referenceChecker == Token.WHITE_KING) {
//Change to King -start
      KING_DIAGONAL_LOOP:
      for (int i = 0; i < diagonalsKing.length; ++i) {
        //Diagonal list:
        List<Point> diagonal = diagonalsKing[i];
        if (diagonal.length < 2) {
          continue KING_DIAGONAL_LOOP;
        }
        Token cap_spot =
            this.board[diagonal[0].x.toInt()][diagonal[0].y.toInt()];
        if (cap_spot == Token.NONE ||
            (!Token.isEnemy(referenceChecker, cap_spot))) {
          continue KING_DIAGONAL_LOOP;
        }
        if (this.board[diagonal[1].x.toInt()][diagonal[1].y.toInt()] ==
            Token.NONE) {
          sequences.add(diagonal);
        }
      }
// Change to King- end
    }
    return sequences;
  }

  //Compute moves available at a particular spot
  List<Point> standardMoves(Point target) {
    List<Point> points = [];
    Token referenceChecker = this.board[target.x.toInt()][target.y.toInt()];
    List<List<Point>> diagonalsSoldier = this.getDiagonals(
        target.x.toInt(), target.y.toInt(), referenceChecker.isBlack());
    List<List<Point>> diagonalsKing = this.getDiagonals(
        target.x.toInt(), target.y.toInt(), !referenceChecker.isBlack());
    SOLDIER_DIAGONAL:
    for (int i = 0; i < diagonalsSoldier.length; ++i) {
      List<Point> currentDiagonal = diagonalsSoldier[i];

      if (currentDiagonal.length < 1) {
        continue SOLDIER_DIAGONAL;
      }
      Token moveTo = this.board[currentDiagonal[0].x.toInt()]
          [currentDiagonal[0].y.toInt()];
      if (moveTo == Token.NONE) {
        points.add(
            Point(currentDiagonal[0].x.toInt(), currentDiagonal[0].y.toInt()));
      }
    }
    //Now, we consider positions for kings
    if (referenceChecker == Token.BLACK_KING ||
        referenceChecker == Token.WHITE_KING) {
      KING_DIAGONAL:
      for (int i = 0; i < diagonalsKing.length; ++i) {
        List<Point> currentDiagonal = diagonalsKing[i];

        if (currentDiagonal.length < 1) {
          continue KING_DIAGONAL;
        }
        Token moveTo = this.board[currentDiagonal[0].x.toInt()]
            [currentDiagonal[0].y.toInt()];
        if (moveTo == Token.NONE) {
          points.add(Point(
              currentDiagonal[0].x.toInt(), currentDiagonal[0].y.toInt()));
        }
      }
    }
    return points;
  }

//create moves function, calculates both normal and capture moves and gives the final result for all points
//by combining both
}

//This enum specifies the token type and affiliation
enum Token {
  BLACK_SOLDIER,
  WHITE_SOLDIER,
  BLACK_KING,
  WHITE_KING,
  NONE;

  //use to check if a checker should capture another one
  static bool isEnemy(Token attacker, Token victim) {
    if (attacker == Token.NONE || victim == Token.NONE) {
      throw "isEnemy should not be called on an empty square";
    }
    if ((attacker == Token.BLACK_KING || attacker == Token.BLACK_SOLDIER) &&
        (victim == Token.WHITE_KING || victim == Token.WHITE_SOLDIER)) {
      return true;
    } else if ((attacker == Token.WHITE_KING ||
            attacker == Token.WHITE_SOLDIER) &&
        (victim == Token.BLACK_KING || victim == Token.BLACK_SOLDIER)) {
      return true;
    }
    return false;
  }

  //checks if the token is black
  bool isBlack() {
    return (this == Token.BLACK_KING || this == Token.BLACK_SOLDIER);
  }

  //checks if the token is white
  bool isWhite() {
    return (this == Token.WHITE_KING || this == Token.WHITE_SOLDIER);
  }

  @override
  String toString() {
    Token type = this;
    switch (type) {
      case BLACK_SOLDIER:
        return "BS";
      case WHITE_SOLDIER:
        return "WS";
      case BLACK_KING:
        return "BK";
      case WHITE_KING:
        return "WK";
      case NONE:
        return "O ";
      default:
        throw "Illegal Token";
    }
  }
}

class Move {
  bool isCapture = false;
  Point targetPosition;
  Point initialPosition;
  Checkers board;
  Move(
      {required this.initialPosition,
      required this.targetPosition,
      required this.board});
}
