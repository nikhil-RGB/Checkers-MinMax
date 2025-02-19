import 'package:checkers/models/Checkers.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    //Console testing for Checkers model
    Checkers.main();
    return SafeArea(
        child: Scaffold(
      body: Center(
        child: const Text("Yet to be implemented"),
      ),
    ));
  }
}
