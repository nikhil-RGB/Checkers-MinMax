import 'package:flutter/material.dart';

class CheckersPiece extends StatelessWidget {
  final String tokType;
  CheckersPiece({required this.tokType});
  @override
  Widget build(BuildContext context) {
    //Switch case here for each piece type
    switch (tokType) {
      case "WS":
        return whiteSoldier();
      case "BS":
        return blackSoldier();
      case "WK":
        return whiteKing();
      case "BK":
        return blackKing();
      default:
        return const SizedBox(
          width: 40,
          height: 40,
        );
    }
  }

  //WS
  Widget whiteSoldier() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey, width: 1),
          ),
        ),
      ),
    );
  }

  //BS
  Widget blackSoldier() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.grey.shade700,
            Colors.grey.shade900,
          ],
        ),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.grey.shade600,
                Colors.grey.shade800,
              ],
              stops: [0.4, 1.0],
            ),
            border: Border.all(color: Colors.grey.shade800, width: 1),
          ),
        ),
      ),
    );
  }

//WK
  Widget whiteKing() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Base white piece (same as normal white)
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
          ),
          child: Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white, Colors.grey.shade200],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
          ),
        ),
        // Crown decoration
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber,
            border: Border.all(color: Colors.amber.shade700, width: 1),
          ),
          child: Center(
            child: Icon(Icons.star, size: 14, color: Colors.amber.shade100),
          ),
        ),
      ],
    );
  }

  //BK
  Widget blackKing() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Base black piece (same as normal black)
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Colors.grey.shade700, Colors.grey.shade900],
            ),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.grey.shade600, Colors.grey.shade800],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
          ),
        ),
        // Crown decoration (more visible against dark background)
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber.shade600,
            border: Border.all(color: Colors.amber.shade900, width: 1),
          ),
          child: Center(
            child: Icon(Icons.star, size: 14, color: Colors.amber.shade200),
          ),
        ),
      ],
    );
  }
}
