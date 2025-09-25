import 'dart:math';
import 'package:flutter/material.dart';

class AlphabetTracingGame extends StatefulWidget {
  const AlphabetTracingGame({super.key});

  @override
  State<AlphabetTracingGame> createState() => _AlphabetTracingGameState();
}

class _AlphabetTracingGameState extends State<AlphabetTracingGame>
    with SingleTickerProviderStateMixin {
  String targetLetter = 'A';
  List<String> displayedLetters = [];
  int score = 0;
  bool showResult = false;
  String resultMessage = '';
  Color resultColor = Colors.green;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<String> alphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _generateNewChallenge();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateNewChallenge() {
    setState(() {
      // Pick a random target letter
      targetLetter = alphabet[random.nextInt(alphabet.length)];

      // Create list of 6-7 letters including the target
      displayedLetters.clear();
      displayedLetters.add(targetLetter);

      // Add 5-6 wrong letters
      final letterCount = 6 + random.nextInt(2); // 6 or 7 letters
      while (displayedLetters.length < letterCount) {
        String wrongLetter;
        do {
          wrongLetter = alphabet[random.nextInt(alphabet.length)];
        } while (displayedLetters.contains(wrongLetter));
        displayedLetters.add(wrongLetter);
      }

      // Shuffle the letters
      displayedLetters.shuffle();
      showResult = false;
    });
  }

  void _onLetterSelected(String selectedLetter) {
    if (selectedLetter == targetLetter) {
      setState(() {
        score += 10;
        resultMessage = 'Excellent! You found $targetLetter! +10';
        resultColor = Colors.green;
        showResult = true;
      });

      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      // Generate new challenge after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _generateNewChallenge();
        }
      });
    } else {
      setState(() {
        resultMessage = 'Try again! Look for letter $targetLetter';
        resultColor = Colors.red;
        showResult = true;
      });

      // Hide wrong message but keep same challenge
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            showResult = false;
          });
        }
      });
    }
  }

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A4C93), Color(0xFF9B59B6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'ALPHABET RECOGNITION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Score: $score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Challenge Question
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Find the Alphabet',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              targetLetter,
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Result message
              if (showResult)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: resultColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    resultMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 20),

              // Letter Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: displayedLetters.length <= 6 ? 3 : 4,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: displayedLetters.length,
                    itemBuilder: (context, index) {
                      return _LetterButton(
                        letter: displayedLetters[index],
                        onTap: () => _onLetterSelected(displayedLetters[index]),
                        isCorrect: displayedLetters[index] == targetLetter,
                      );
                    },
                  ),
                ),
              ),

              // Instructions
              // Container(
              //   margin: const EdgeInsets.all(20),
              //   padding: const EdgeInsets.all(15),
              //   decoration: BoxDecoration(
              //     color: Colors.white.withOpacity(0.1),
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: const Text(
              //     '🎯 Tap the letter that matches the one shown above!',
              //     style: TextStyle(
              //       color: Colors.white70,
              //       fontSize: 14,
              //       fontWeight: FontWeight.w500,
              //     ),
              //     textAlign: TextAlign.center,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LetterButton extends StatefulWidget {
  final String letter;
  final VoidCallback onTap;
  final bool isCorrect;

  const _LetterButton({
    required this.letter,
    required this.onTap,
    required this.isCorrect,
  });

  @override
  State<_LetterButton> createState() => _LetterButtonState();
}

class _LetterButtonState extends State<_LetterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getRandomColor() {
    final colors = [
      const Color(0xFF3498DB), // Blue
      const Color(0xFFE74C3C), // Red
      const Color(0xFF2ECC71), // Green
      const Color(0xFFF39C12), // Orange
      const Color(0xFF9B59B6), // Purple
      const Color(0xFF1ABC9C), // Turquoise
      const Color(0xFFE67E22), // Carrot
      const Color(0xFFE91E63), // Pink
    ];
    return colors[widget.letter.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) {
                _animationController.reverse();
                widget.onTap();
              },
              onTapCancel: () => _animationController.reverse(),
              child: Container(
                decoration: BoxDecoration(
                  color: _getRandomColor(),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                    // Letter
                    Center(
                      child: Text(
                        widget.letter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}