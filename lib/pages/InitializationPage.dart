import 'package:checkers/models/Checkers.dart';
import 'package:checkers/pages/HomeBoardPage.dart';
import 'package:checkers/widgets/CheckersBoard.dart';
import 'package:checkers/widgets/CheckersPiece.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class InitializationPage extends StatefulWidget {
  @override
  State<InitializationPage> createState() => _InitializationPageState();
}

class _InitializationPageState extends State<InitializationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/wood-background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                const Spacer(flex: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CheckersPiece(tokType: "BS").blackSoldier(),
                    const Gap(5),
                    const Text(
                      "Checkers!",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors
                            .white, // Change color for better visibility on the background
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black,
                            offset: Offset(5.0, 5.0),
                          ),
                        ],
                      ),
                    ),
                    const Gap(5),
                    CheckersPiece(tokType: "WS").whiteSoldier(),
                  ],
                ),
                const Spacer(flex: 1),
                ElevatedButton(
                    onPressed: () async {
                      int? maxNcap = await _showMoveLimitDialog();
                      if (maxNcap == null) {
                        return;
                      }
                      CheckersBoard.maxNonCapMoveCount = maxNcap;

                      Checkers referenceBoard = Checkers();
                      referenceBoard.initBoard();

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeCheckersPage(
                                    referenceGame: CheckersBoard(
                                        key: const Key("0"),
                                        referenceBoard: referenceBoard,
                                        isAIControlled: false),
                                  )));
                    },
                    child: const Text(
                      "Play against Human",
                      style: TextStyle(fontSize: 17),
                    )),
                const Gap(12),
                ElevatedButton(
                    onPressed: () async {
                      int? maxNcap = await _showMoveLimitDialog();
                      if (maxNcap == null) {
                        return;
                      }
                      CheckersBoard.maxNonCapMoveCount = maxNcap;

                      Checkers referenceBoard = Checkers();
                      referenceBoard.initBoard();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeCheckersPage(
                                    referenceGame: CheckersBoard(
                                        key: const Key("0"),
                                        referenceBoard: referenceBoard,
                                        isAIControlled: true),
                                  )));
                    },
                    child: const Text(
                      " Play against AI  ",
                      style: TextStyle(fontSize: 17),
                    )),
                const Gap(40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<int?> _showMoveLimitDialog() {
    return showDialog<int>(
      context: context,
      barrierDismissible: false, // User must tap a button to close.
      builder: (BuildContext context) {
        return _MoveLimitDialog();
      },
    );
  }
}

/// A stateful dialog that prompts the user for a number between 1 and 100.
class _MoveLimitDialog extends StatefulWidget {
  @override
  _MoveLimitDialogState createState() => _MoveLimitDialogState();
}

class _MoveLimitDialogState extends State<_MoveLimitDialog> {
  final _controller = TextEditingController(text: '40');
  bool _isInputValid = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();

    _controller.addListener(_validateInput);
    _validateInput();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateInput() {
    final text = _controller.text;
    if (text.isEmpty) {
      setState(() {
        _isInputValid = false;
        _errorText = null;
      });
      return;
    }

    final numericRegex = RegExp(r'^[0-9]+$');
    if (!numericRegex.hasMatch(text)) {
      setState(() {
        _isInputValid = false;
        _errorText = 'Please enter only numbers.';
      });
      return;
    }

    final number = int.tryParse(text);
    if (number == null) {
      setState(() {
        _isInputValid = false;
        _errorText = 'Invalid number.';
      });
    } else if (number < 1 || number > 100) {
      setState(() {
        _isInputValid = false;
        _errorText = 'Number must be between 1 and 100.';
      });
    } else {
      // Input is valid
      setState(() {
        _isInputValid = true;
        _errorText = null;
      });
    }
  }

  void _submit() {
    if (_isInputValid) {
      final number = int.parse(_controller.text);
      // Pop the dialog and return the valid number.
      Navigator.of(context).pop(number);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Game Rule'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The game will be a draw if this many moves are made by both players without a piece being captured.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const Gap(16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Max non-capture moves',
              hintText: '1-100',
              errorText: _errorText,
            ),
            onSubmitted: (_) =>
                _submit(), // Allow submitting with the keyboard's done button
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: _isInputValid ? _submit : null,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
