import 'package:checkers/models/Checkers.dart';
import 'package:checkers/widgets/CheckersBoard.dart';
import 'package:flutter/material.dart';

class HomeCheckersPage extends StatefulWidget {
  @override
  State<HomeCheckersPage> createState() => _HomeCheckersPageState();
}

class _HomeCheckersPageState extends State<HomeCheckersPage> {
  @override
  Widget build(BuildContext context) {
    Checkers referenceGame = Checkers();
    referenceGame.initBoard();
    return SafeArea(
        child: Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/wood-background.jpg"),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            child: CheckersBoard(referenceBoard: referenceGame),
          ),
        ),
      ),
    ));
  }
}
