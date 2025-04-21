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
      body: Center(
        child: CheckersBoard(referenceBoard: referenceGame),
      ),
    ));
  }
}
