import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const TapStreakApp());
}

class TapStreakApp extends StatelessWidget {
  const TapStreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TapStreak',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3498db)),
        useMaterial3: true,
      ),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Game'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3498db),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TapGame()),
          ),
        ),
      ),
    );
  }
}

class TapGame extends StatefulWidget {
  const TapGame({super.key});

  @override
  State<TapGame> createState() => _TapGameState();
}

class _TapGameState extends State<TapGame> with SingleTickerProviderStateMixin {
  int _streak = 0;
  int _highScore = 0;
  int _timeLeft = 5;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1.0,
    )..addListener(() {
        setState(() {});
      });
    _scaleAnimation = _animationController.drive(Tween(begin: 1.0, end: 1.2));
    _startGame();
  }

  void _startGame() {
    setState(() {
      _streak = 0;
      _timeLeft = 5;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      if (_streak > _highScore) _highScore = _streak;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your streak: $_streak'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Restart'),
          ),
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Main Menu'),
          )
        ],
      ),
    );
  }

  void _handleTap() {
    setState(() {
      _streak++;
      _timeLeft = 5; // reset timer
    });
    _animationController.forward(from: 0.9);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoBox('Time', '$_timeLeft', const Color(0xFFF39C12)),
                _buildInfoBox('Streak', '$_streak', const Color(0xFF2ECC71)),
                _buildInfoBox('High', '$_highScore', const Color(0xFFF39C12)),
              ],
            ),
            GestureDetector(
              onTap: _handleTap,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.touch_app,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.replay),
              label: const Text('Restart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498db),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _startGame,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: color),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}