import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dice Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DiceGame(),
    );
  }
}

class DiceGame extends StatefulWidget {
  const DiceGame({Key? key}) : super(key: key);

  @override
  State<DiceGame> createState() => _DiceGameState();
}

class _DiceGameState extends State<DiceGame> {
  final _roundsController = TextEditingController();
  final _player1ScoreController = TextEditingController(text: '0');
  final _player2ScoreController = TextEditingController(text: '0');
  final _player3ScoreController = TextEditingController(text: '0');
  final _player4ScoreController = TextEditingController(text: '0');
  int _diceValue = 1;
  int _currentPlayer = 1;
  int _player1Score = 0;
  int _player2Score = 0;
  int _player3Score = 0;
  int _player4Score = 0;
  final _random = Random();
  bool _gameStarted = false;
  int _totalRounds = 0;
  int _currentRound = 0;

  String getDiceImage(int value) {
    switch (value) {
      case 1:
        return 'assets/images/dice_1.png';
      case 2:
        return 'assets/images/dice_2.png';
      case 3:
        return 'assets/images/dice_3.png';
      case 4:
        return 'assets/images/dice_4.png';
      case 5:
        return 'assets/images/dice_5.png';
      case 6:
        return 'assets/images/dice_6.png';
      default:
        return 'assets/images/dice.png';
    }
  }

  void _rollDice() {
    setState(() {
      _diceValue = _random.nextInt(6) + 1;
      if (_currentPlayer == 1) {
        _player1Score += _diceValue;
        _player1ScoreController.text = _player1Score.toString();
        if (_diceValue == 6) {
          // do nothing, player gets another turn
        } else {
          _currentPlayer = 2;
        }
      } else if (_currentPlayer == 2) {
        _player2Score += _diceValue;
        _player2ScoreController.text = _player2Score.toString();
        if (_diceValue == 6) {
          // do nothing, player gets another turn
        } else {
          _currentPlayer = 3;
        }
      } else if (_currentPlayer == 3) {
        _player3Score += _diceValue;
        _player3ScoreController.text = _player3Score.toString();
        if (_diceValue == 6) {
          // do nothing, player gets another turn
        } else {
          _currentPlayer = 4;
        }
      } else if (_currentPlayer == 4) {
        _player4Score += _diceValue;
        _player4ScoreController.text = _player4Score.toString();
        if (_diceValue == 6) {
          // do nothing, player gets another turn
        } else {
          _currentPlayer = 1;
          _currentRound++;
          if (_currentRound == _totalRounds) {
            _endGame();
          }
        }
      }
    });
  }

  void _startGame() {
    setState(() {
      _totalRounds = int.parse(_roundsController.text);
      _gameStarted = true;
    });
  }

  void _endGame() {
    int maxScore = _player1Score;
    String winner = 'Player 1';
    if (_player2Score > maxScore) {
      maxScore = _player2Score;
      winner = 'Player 2';
    }
    if (_player3Score > maxScore) {
      maxScore = _player3Score;
      winner = 'Player 3';
    }
    if (_player4Score > maxScore) {
      maxScore = _player4Score;
      winner = 'Player 4';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Congratulations!'),
        content: Text('$winner is the winner with a score of $maxScore'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _gameStarted = false;
      _player1Score = 0;
      _player2Score = 0;
      _player3Score = 0;
      _player4Score = 0;
      _player1ScoreController.text = '0';
      _player2ScoreController.text = '0';
      _player3ScoreController.text = '0';
      _player4ScoreController.text = '0';
      _roundsController.clear();
      _currentPlayer = 1;
      _currentRound = 0;
      _diceValue = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Dice Game')),

      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _gameStarted
                  ? Text('Player $_currentPlayer\'s turn', style: TextStyle(fontSize: 24))
                  : TextField(
                controller: _roundsController,
                decoration: InputDecoration(labelText: 'Total Rounds'),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 250,
              height: 150,
              child :Image.asset(getDiceImage(_diceValue),
                fit: BoxFit.contain,
              ),),
              SizedBox(height: 20),
              Container(
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: TextField(
                  enabled: false,
                  textAlign: TextAlign.center,
                  controller: _player1ScoreController,
                  decoration: InputDecoration(labelText: 'Player 1 Score', border: InputBorder.none),
                ),
              ),
              Container(
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: TextField(
                  enabled: false,
                  textAlign: TextAlign.center,
                  controller: _player2ScoreController,
                  decoration: InputDecoration(labelText: 'Player 2 Score', border: InputBorder.none),
                ),
              ),
              Container(
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: TextField(
                  enabled: false,
                  textAlign: TextAlign.center,
                  controller: _player3ScoreController,
                  decoration: InputDecoration(labelText: 'Player 3 Score', border: InputBorder.none),
                ),
              ),
              Container(
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: TextField(
                  enabled: false,
                  textAlign: TextAlign.center,
                  controller: _player4ScoreController,
                  decoration: InputDecoration(labelText: 'Player 4 Score', border: InputBorder.none),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: _gameStarted ? _rollDice : _startGame,
                child: Text(_gameStarted ? 'Roll Dice' : 'Start Game'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: _restartGame,
                child: Text('Restart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}