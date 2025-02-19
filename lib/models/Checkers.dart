// ignore_for_file: unnecessary_this

import 'package:logger/logger.dart';

class Checkers {
  List<List<Token>> board = List.generate(8, (i) => List.filled(8, Token.NONE));
  //Board state information is stored in the instance variable above

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
}

//This enum specifies the token type and affiliation
enum Token {
  BLACK_SOLDIER,
  WHITE_SOLDIER,
  BLACK_KING,
  WHITE_KING,
  NONE;

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
