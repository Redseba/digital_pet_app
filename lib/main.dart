import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  final TextEditingController _nameController = TextEditingController();
  Timer? _hungerTimer;
  String happinessStatus = "Neutral"; 
  bool nameSet = false;
    bool _isGameOver = false; // Track game over state
  bool _hasWon = false; // Track if player has won
  Timer? _winTimer;



  void initState() {
    super.initState();
    _startHungerTimer(); // Start the timer when the app starts
  }

  @override
  void dispose() {
    _hungerTimer?.cancel(); // Cancel the timer when the widget is disposed
    _winTimer?.cancel(); 
    super.dispose();
  }

  // Function to start the hunger timer
  void _startHungerTimer() {
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        _increaseHunger(); // Increase hunger every 30 seconds
        _checkLossCondition();
        _updateHappinessStatus(); // Update happiness status based on current levels
      });
    });
  }

  void _increaseHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100); // Increase hunger by 5
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100); // Decrease happiness if hunger is maxed out
    }
  }

  // Function to increase happiness and update hunger when playing with the pet
  void _playWithPet() {
    if (_isGameOver) return; 
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHappinessStatus();
      _updateHunger();
      _checkWinCondition();
    });
  }

  // Function to decrease hunger and update happiness when feeding the pet
  void _feedPet() {
    if (_isGameOver) return; 
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness(); // Update happiness based on hunger
      _updateHappinessStatus(); // Update happiness status
    });
  }

  void _updateHappinessStatus() {
    if (happinessLevel > 70) {
      happinessStatus = "Happy";
    } else if (happinessLevel < 30) {
      happinessStatus = "Mad";
    } else {
      happinessStatus = "Neutral";
    }
  }

  // Update happiness based on hunger level
  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
  }

  // Check for loss condition
  void _checkLossCondition() {
    if (hungerLevel == 100 && happinessLevel <= 10) {
      setState(() {
        _isGameOver = true; // Set game over state
      });
      _showGameOverDialog(); // Show game over message
    }
  }

  // Check for win condition
  void _checkWinCondition() {
    if (happinessLevel > 80 && _winTimer == null) {
      _winTimer = Timer(Duration(minutes: 3), () {
        setState(() {
          _hasWon = true; // Set win state
        });
        _showWinDialog(); // Show win message
      });
    } else if (happinessLevel <= 80) {
      _winTimer?.cancel(); // Cancel the win timer if happiness drops below 80
      _winTimer = null;
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("Your pet is too hungry and unhappy!"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("You Win!"),
          content: Text("Your pet is happy for 3 minutes!"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getImagePath() {
    if (happinessLevel > 70) {
      return 'Assets/Turtle_Happy.png'; // Happy image
    } else if (happinessLevel < 30) {
      return 'Assets/Turtle_Mad.png'; // Sad image
    } else {
      return 'Assets/Turtle_Neutral.png'; // Neutral image
    }
  }

  Color _backgroundColor() {
    if (happinessLevel > 70) {
      return Colors.green; // Happy image
    } else if (happinessLevel < 30) {
      return Colors.red; // Sad image
    } else {
      return Colors.yellow; // Neutral image
    }
  }

  void _updatePetName() {
    setState(() {
      petName = _nameController.text.isNotEmpty ? _nameController.text : "Your Pet";
      nameSet = true; // Mark that the name is set
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Container(
        color: _backgroundColor(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (!nameSet) // Show name input until it's set
                Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Enter a name for your pet!',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _updatePetName(),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _updatePetName,
                      child: Text('Confirm Name'),
                    ),
                  ],
                ),
              if (nameSet) // Show pet info once the name is set
                Column(
                  children: [
                    Image.asset(
                      _getImagePath(),
                      width: 200,
                      height: 200,
                    ),
                    Text(
                      'Name: $petName',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Status: $happinessStatus', // Display the status
                      style: TextStyle(fontSize: 20.0),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Happiness Level: $happinessLevel',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Hunger Level: $hungerLevel',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: _playWithPet,
                      child: Text('Play with Your Pet'),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _feedPet,
                      child: Text('Feed Your Pet'),
                    ),
                    if (_isGameOver) // Show game over message if applicable
                Text(
                  'Game Over',
                  style: TextStyle(fontSize: 24, color: Colors.red),
                ),
              if (_hasWon) // Show win message if applicable
                Text(
                  'You Win!',
                  style: TextStyle(fontSize: 24, color: Colors.green),
                ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
