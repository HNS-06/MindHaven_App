import 'package:flutter/material.dart';
import 'dart:math'; // ADD THIS IMPORT
import 'package:mindhaven/services/reward_service.dart';

class FocusGameScreen extends StatefulWidget {
  const FocusGameScreen({super.key});

  @override
  State<FocusGameScreen> createState() => _FocusGameScreenState();
}

class _FocusGameScreenState extends State<FocusGameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  double _dotX = 0.5;
  double _dotY = 0.5;
  int _score = 0;
  int _timeLeft = 30;
  bool _isPlaying = false;
  bool _showDot = true;
  final Random _random = Random(); // Now this will work

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isPlaying = true;
      _showDot = true;
      _moveDot();
    });
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      if (!_isPlaying) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _timeLeft--;
      });
      if (_timeLeft <= 0) {
        _endGame();
        return false;
      }
      return true;
    });
  }

  void _moveDot() {
    if (!_isPlaying || !mounted) return;

    // Hide dot briefly before moving
    setState(() {
      _showDot = false;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || !_isPlaying) return;
      
      setState(() {
        _dotX = 0.1 + _random.nextDouble() * 0.8;
        _dotY = 0.1 + _random.nextDouble() * 0.8;
        _showDot = true;
      });

      // Restart animation
      _controller.reset();
      _controller.forward();

      // Schedule next move if still playing
      if (_isPlaying) {
        Future.delayed(const Duration(milliseconds: 1500), _moveDot);
      }
    });
  }

  void _tapDot() {
    if (!_isPlaying || !_showDot) return;

    setState(() {
      _score += 10;
    });

    // Visual feedback
    _controller.reset();
    _controller.forward();

    // Immediate next dot
    _moveDot();
  }

  void _endGame() {
    setState(() {
      _isPlaying = false;
      _showDot = false;
    });

    // Award points based on score
    final pointsEarned = (_score ~/ 20).clamp(5, 50);
    RewardService.addPoints(pointsEarned);

    // Show results
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Game Over!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Final Score: $_score'),
              Text('Points Earned: +$pointsEarned'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Game'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Game Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('SCORE', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('$_score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('TIME', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('$_timeLeft', style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _timeLeft <= 10 ? Colors.red : Colors.black,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Game Area
            Expanded(
              child: Stack(
                children: [
                  // Background Pattern
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepPurple.shade50,
                          Colors.blue.shade50,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  // Dot
                  if (_showDot && _isPlaying)
                    Positioned(
                      left: _dotX * (MediaQuery.of(context).size.width - 32 - 80),
                      top: _dotY * (MediaQuery.of(context).size.height - 300),
                      child: GestureDetector(
                        onTap: _tapDot,
                        child: Transform.scale(
                          scale: 1.0 + _animation.value * 0.2,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.8 - _animation.value * 0.3),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.circle,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Instructions or Game Over
                  if (!_isPlaying)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.touch_app,
                            size: 64,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _score == 0 ? 'Focus Game' : 'Game Over!',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _score == 0 
                                ? 'Tap the dots as they appear!\nTest your focus and reaction time.'
                                : 'Final Score: $_score',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: _startGame,
                            icon: const Icon(Icons.play_arrow),
                            label: Text(_score == 0 ? 'Start Game' : 'Play Again'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Instructions
            const SizedBox(height: 20),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Tap the dots quickly as they appear! Each tap = 10 points. '
                  'Game lasts 30 seconds.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}