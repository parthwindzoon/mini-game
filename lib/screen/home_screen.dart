import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/alphabet_game.dart';
import '../game/color_matching_game.dart';
import '../game/counting_game.dart';
import '../game/number_learning_game.dart';
import '../game/number_memory_game.dart';
import '../game/pattern_game.dart';
import '../game/shape_sorting_game.dart';
import '../game/simple_math_game.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Sky blue
              Color(0xFFB0E0E6), // Powder blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              // Container(
              //   padding: const EdgeInsets.all(20),
              //   child: Column(
              //     children: [
              //       const Text(
              //         '🌟 Fun Learning Games 🌟',
              //         style: TextStyle(
              //           fontSize: 28,
              //           fontWeight: FontWeight.bold,
              //           color: Colors.white,
              //           shadows: [
              //             Shadow(
              //               blurRadius: 10.0,
              //               color: Colors.black26,
              //               offset: Offset(2.0, 2.0),
              //             ),
              //           ],
              //         ),
              //         textAlign: TextAlign.center,
              //       ),
              //       const SizedBox(height: 10),
              //       const Text(
              //         'Choose a game to start learning!',
              //         style: TextStyle(
              //           fontSize: 16,
              //           color: Colors.white70,
              //           fontWeight: FontWeight.w500,
              //         ),
              //         textAlign: TextAlign.center,
              //       ),
              //     ],
              //   ),
              // ),

              // Game Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      GameCard(
                        title: 'Alphabet\nLearning',
                        icon: '🔤',
                        color: const Color(0xFFFF6B6B),
                        onTap: () => _navigateToGame(context, AlphabetGame()),
                      ),
                      GameCard(
                        title: 'Number\nLearning',
                        icon: '🔢',
                        color: const Color(0xFF4ECDC4),
                        onTap: () => _navigateToGame(context, NumberLearningGame()),
                      ),
                      GameCard(
                        title: 'Shape\nSorting',
                        icon: '🔺',
                        color: const Color(0xFF4ECDC4),
                        onTap: () => _navigateToGame(context, ShapeSortingGame()),
                      ),
                      GameCard(
                        title: 'Number\nMemory',
                        icon: '🔢',
                        color: const Color(0xFF45B7D1),
                        onTap: () => _navigateToGame(context, NumberMemoryGame()),
                      ),
                      GameCard(
                        title: 'Color\nMatching',
                        icon: '🎨',
                        color: const Color(0xFF96CEB4),
                        onTap: () => _navigateToGame(context, ColorMatchingGame()),
                      ),
                      GameCard(
                        title: 'Counting\nFun',
                        icon: '🔢',
                        color: const Color(0xFFFFC048),
                        onTap: () => _navigateToGame(context, CountingGame()),
                      ),
                      GameCard(
                        title: 'Simple\nMath',
                        icon: '➕',
                        color: const Color(0xFFB983FF),
                        onTap: () => _navigateToGame(context, SimpleMathGame()),
                      ),
                      GameCard(
                        title: 'Pattern\nRecognition',
                        icon: '🔄',
                        color: const Color(0xFFFF8A80),
                        onTap: () => _navigateToGame(context, PatternGame()),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              // Container(
              //   padding: const EdgeInsets.all(16),
              //   child: const Text(
              //     'Have fun learning! 🚀',
              //     style: TextStyle(
              //       fontSize: 14,
              //       color: Colors.white70,
              //       fontWeight: FontWeight.w400,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(game: game),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String title;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 50),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  final Game game;

  const GameScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: GameWidget(game: game),
    );
  }
}