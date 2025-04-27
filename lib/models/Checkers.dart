// ignore_for_file: unnecessary_this

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:logger/logger.dart';

void main() {
  Checkers.main();
}

class Checkers {
  List<List<Token>> board = List.generate(8, (i) => List.filled(8, Token.NONE));
  //Board state information is stored in the instance variable above
  int counter = 0; //even means black's turn, odd means white's turn

  //main method here
  static void main() {
    Checkers game = Checkers();
    game.initBoard();
    game.printBoard();

    String winner = game.gameLoop();
    print("THE WINNER IS: " + winner);
  }

  //Gameloop for game, returns winner.
  //Check for remaining opponent piece after a capture/chain is completed before updating the counter
  //moves available are checked anyway at the start of a colour's turn.
  String gameLoop() {
    while (true) {
      this.printBoard();
      LinkedHashMap<Point, List<List<Point>>> moves = this.movesMap();
      if (moves.isEmpty) {
        return getContraryColour();
      }
      bool isCapturePossible = moves[moves.keys.first]![0][0].x.toInt() != -11;
      if (isCapturePossible) {
        int i = 0;
        for (MapEntry entry in moves.entries) {
          //Print all moves
          List<List<Point>> moveList = entry.value;
          Point source = entry.key;
          for (int j = 0; j < moveList.length; ++j) {
            List<Point> currentCaptureDiagonal = moveList[j];
            print(i.toString() +
                ")  " +
                source.toString() +
                ": ${j}) " +
                currentCaptureDiagonal[1].toString());
            //enter input here
          }
          ++i;
        }
        print("Input your choice 1(source):");
        int choice = int.parse(stdin.readLineSync(encoding: utf8)!);
        print("Input your move number choice");
        int choice2 = int.parse(stdin.readLineSync(encoding: utf8)!);
        List<List<Point>> newCaps = this.executeCapture(
            moves.keys.elementAt(choice),
            moves.values.elementAt(choice)[choice2]);
        //logic for continued capture
        Point newPosition = moves.values.elementAt(choice)[choice2][1];
        this.kingAfterMove(newPosition);
        this.printBoard();
        newCaps = this.captureSequences(newPosition);
        while (newCaps.isNotEmpty) {
          int i1 = 0;
          for (List<Point> diagonal in newCaps) {
            print("$i1) $diagonal\n");
            ++i1;
          }
          //GET HERE, IMPROVE CONTINUED CAPTURE LOGIC
          print("Input your move number choice");
          int choiceCapture = int.parse(stdin.readLineSync(encoding: utf8)!);
          Point futurePosition = newCaps[choiceCapture][1];
          newCaps = this.executeCapture(newPosition, newCaps[choiceCapture]);
          newPosition = futurePosition;
          kingAfterMove(newPosition);
          this.printBoard();
        }
        //before returning check for all remianing pieces of opponent's colour.
        if (!this.arePiecesLeft(getContraryColour())) {
          return this.getColour();
        } //finish here
        ++this.counter;
      } else {
        int i = 0;
        List<Point> sourceChoiceList = [];
        List<Point> moveChoiceList = [];

        for (MapEntry entry in moves.entries) {
          List<Point> moveList = entry.value[1];
          Point source = entry.key;
          for (Point p in moveList) {
            print(i.toString() +
                ") " +
                source.toString() +
                ' to ' +
                p.toString());
            sourceChoiceList.add(source);
            moveChoiceList.add(p);
            ++i;
          }
          //remove extra ++i;
        }
        print("Input your move number choice");
        int choiceCapture = int.parse(stdin.readLineSync(encoding: utf8)!);
        this.executeStandardMove(
            sourceChoiceList[choiceCapture], moveChoiceList[choiceCapture]);
        this.kingAfterMove(moveChoiceList[choiceCapture]);
        ++this.counter;
      }
    }
  }

  //Call kinging function to crown piece a king if it reaches the last row
  //Converts a normal token to a king token if it is in it's corresponding opposite last row if it
  //is not already a king. Returns true if it is crowned, false otherwise.
  bool kingAfterMove(Point point) {
    Token currentRef = this.board[point.x.toInt()][point.y.toInt()];
    bool isWhite = currentRef.toString().contains("W");
    int row = point.x.toInt();
    if (row == 0 && isWhite && !currentRef.toString().contains("K")) {
      this.board[point.x.toInt()][point.y.toInt()] = Token.WHITE_KING;
      return true;
    } else if (row == 7 && !isWhite && !currentRef.toString().contains("K")) {
      this.board[point.x.toInt()][point.y.toInt()] = Token.BLACK_KING;
      return true;
    }
    return false;
  }

// Current player's colour
  String getColour() {
    if (counter % 2 == 0) {
      return "B";
    }
    return "W";
  }

  String getContraryColour() {
    if (counter % 2 == 0) {
      return "W";
    }
    return "B";
  }

  //B: BLACK
  //W: WHITE
  //Check which pieces are left
  bool arePiecesLeft(String col) {
    for (int i = 0; i < 8; ++i) {
      for (int j = 0; j < 8; ++j) {
        Token current = this.board[i][j];
        if (current.toString().contains(col)) {
          return true;
        }
      }
    }
    return false;
  }

  //WILL NOT CHECK IF THE MOVE IS VALID, ENSURE TARGET IS VALID
  void executeStandardMove(Point source, Point target) {
    Token referenceChecker = this.board[source.x.toInt()][source.y.toInt()];
    this.board[target.x.toInt()][target.y.toInt()] = referenceChecker;
    this.board[source.x.toInt()][source.y.toInt()] = Token.NONE;
  }

  //Execute captures and return possible further captures
  //No checks, ensure supplied diagonal is  a verified capture move
  List<List<Point>> executeCapture(Point source, List<Point> captureDiagonal) {
    Point attackerPoint = source;
    Point capturePoint = captureDiagonal[0];
    Point newPosition = captureDiagonal[1];
    Token attackChecker =
        this.board[attackerPoint.x.toInt()][attackerPoint.y.toInt()];
    this.board[capturePoint.x.toInt()][capturePoint.y.toInt()] = Token.NONE;
    this.board[newPosition.x.toInt()][newPosition.y.toInt()] = attackChecker;
    this.board[attackerPoint.x.toInt()][attackerPoint.y.toInt()] = Token.NONE;
    return this.captureSequences(newPosition);

    //if return is non-empty engage chained captures!
  }

  //This function can be used to determine which tiles to colour dark in the UI
  //Determines whether a token can be placed in the selected tile/whether the selected tile is black
  static bool isTilePlayable(int r, int c) {
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
        concat += ("${this.board[i][j]}($i,$j)   ");
      }
      concat += ("\n");
    }
    print(concat);
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
  //This function  returns a List of List of Points- List<List<Point>>
  //Each List<Point> is a diagonal where a capture sequence is possible from the target point.
  //Eg: If it is possible for a capture to be made from (2,1) to (4,3)- eliminating an opponent token at (3,2), then the List<Point> will be [(3,2), (4,3)].
  //Such a diagonal will make for one element of the final list.
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

  //Compute normal moves available at a particular spot
  //This function uses formatted output to differentiate between a standard moves list and a capture move list(an output from another function)
  //The function will return an empty list [] if no moves are available for the current target piece.
  //if moves are available, the function returns a List of List of Points List<List<Point>>.
  //This list has two point lists. The first one is ALWAYS [Point(-11,-11)] to indicate that this output is for a standard move, not a capture move.
  //The second list is a list of possible Points the target token can move to eg [Point(3,4),Point(3,2)].
  //Output may therefore look something like this:
  //[[Point(-11,-11)] ,[Point(3,4),Point(3,2)]]
  List<List<Point>> standardMoves(Point target) {
    List<Point> points = [];
    List<List<Point>> results = [];
    results.add([const Point(-11, -11)]);
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
    if (points.isNotEmpty) {
      results.add(points);
      return results;
    } else {
      return [];
    }
  }

//create moves function, calculates both normal and capture moves and gives the final result for all points
//by combining both.
//returns List<List<Point>>, if the first point in the first list is (-11,-11), this means that no capture sequences are available
  // //This means that all moves now are standard moves in a single point list
  // List<List<Point>> moves(Point target) {
  //   Token referenceChecker = this.board[target.x.toInt()][target.y.toInt()];
  //   if (referenceChecker == Token.NONE) {
  //     throw "Should not check a blank target grid square";
  //   }
  //   List<List<Point>> sequences = [];
  //   List<List<Point>> captureSequences = this.captureSequences(target);
  //   if (captureSequences.isNotEmpty) {
  //     return captureSequences;
  //   }
  //   List<Point> standardMoves = this.standardMoves(target);
  //   if (standardMoves.isNotEmpty) {
  //     Point marker = const Point(-11, -11);
  //     sequences.add([marker]);
  //     sequences.add(standardMoves);
  //   }
  //   return sequences;
  // }

  //This function should return a map of all possible moves for all pieces belonging to the current player.
  //Each key is a point that refers to the possible moves for that piece.
  //The List<List<Point>> referred to by a Point contains either the output of captureSequences() or standardMoves()- refer to
  //the comments above these functions to understand how the output is presented.
  LinkedHashMap<Point, List<List<Point>>> movesMap() {
    LinkedHashMap<Point, List<List<Point>>> movesMap = LinkedHashMap();
    String currentPlayer = this.counter % 2 == 0 ? "B" : "W";
    CAPTURE_STANDARD_MOVE_ITERATOR:
    //Prioritize capture moves over standard moves.
    //Iterate first for all capture moves, and then for standard moves.
    for (int boardChecker = 0; boardChecker < 2; ++boardChecker) {
      for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
          Token currentGridBox = this.board[i][j];
          Point referencePoint = Point(i, j);
          if (currentGridBox == Token.NONE ||
              (!currentGridBox.toString().startsWith(currentPlayer))) {
            continue;
          }
          //Reference point is the current point being examined,
          if (boardChecker == 0) {
            List<List<Point>> captures = this.captureSequences(referencePoint);
            if (captures.isNotEmpty) {
              movesMap[referencePoint] = captures;
            }
          } else {
            List<List<Point>> standardMoves =
                this.standardMoves(referencePoint);
            if (standardMoves.isNotEmpty) {
              movesMap[referencePoint] = standardMoves;
            }
          }
        }
      }
      if (movesMap.isNotEmpty) {
        break CAPTURE_STANDARD_MOVE_ITERATOR;
      }
    }

    return movesMap;
  }

  Token getAt(Point point) {
    return this.board[point.x.toInt()][point.y.toInt()];
  }

  void setAt(Point point, Token token) {
    this.board[point.x.toInt()][point.y.toInt()] = token;
  }
  //Now, make game loop and implement logic for continued captures.
  //Test all functions with a false board, generate the board via a LLM.
  //Then, test the game loop with the generated board.
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
//Possibly not required- TODO: Delete before code is put into production
// class Move {
//   bool isCapture = false;
//   Point targetPosition;
//   Point initialPosition;
//   Checkers board;
//   Move(
//       {required this.initialPosition,
//       required this.targetPosition,
//       required this.board});
// }
