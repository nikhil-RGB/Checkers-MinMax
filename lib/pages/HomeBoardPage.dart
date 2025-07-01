import 'package:checkers/models/Checkers.dart';
import 'package:checkers/widgets/CheckersBoard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.brown,
        // elevation: 0.0,
        actions: [
          IconButton(
              onPressed: () {
                //check for user confirmation before resetting the game
                showRestartConfirmationDialog(context);
              },
              icon: const Icon(
                Icons.restore_rounded,
                color: Colors.black,
              ))
        ],
      ),
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

  void showRestartConfirmationDialog(BuildContext context) {
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
                const Text(
                  'Reset Game',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Are you sure you want to reset the game?", // Added draw condition
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(120, 40),
                        ),
                        onPressed: () => Phoenix.rebirth(context),
                        child: const Text('OK'),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(120, 40),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
