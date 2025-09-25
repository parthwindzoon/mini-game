import 'dart:math';
import 'package:flutter/material.dart';

class NumberTracingGame extends StatefulWidget {
  const NumberTracingGame({super.key});

  @override
  State<NumberTracingGame> createState() => _NumberTracingGameState();
}

class _NumberTracingGameState extends State<NumberTracingGame>
    with SingleTickerProviderStateMixin {
  String targetNumber = '1';
  List<String> displayedNumbers = [];
  int score = 0;
  bool showResult = false;
  String resultMessage = '';
  Color resultColor = Colors.green;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<String> numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  final List<String> numberWords = [
    'Zero', 'One', 'Two', 'Three', 'Four',
    'Five', 'Six', 'Seven', 'Eight', 'Nine'
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
      // Pick a random target number
      targetNumber = numbers[random.nextInt(numbers.length)];

      // Create list of 6-7 numbers including the target
      displayedNumbers.clear();
      displayedNumbers.add(targetNumber);

      // Add 5-6 wrong numbers
      final numberCount = 6 + random.nextInt(2); // 6 or 7 numbers
      while (displayedNumbers.length < numberCount) {
        String wrongNumber;
        do {
          wrongNumber = numbers[random.nextInt(numbers.length)];
        } while (displayedNumbers.contains(wrongNumber));
        displayedNumbers.add(wrongNumber);
      }

      // Shuffle the numbers
      displayedNumbers.shuffle();
      showResult = false;
    });
  }

  void _onNumberSelected(String selectedNumber) {
    if (selectedNumber == targetNumber) {
      setState(() {
        score += 10;
        resultMessage = 'Perfect! You found $targetNumber! +10';
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
        resultMessage = 'Try again! Look for number $targetNumber';
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

  String _getNumberWord(String number) {
    final index = numbers.indexOf(number);
    return index >= 0 ? numberWords[index] : '';
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
            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
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
                      'NUMBER RECOGNITION',
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
                      'Find the Number',
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
                              targetNumber,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _getNumberWord(targetNumber),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Visual counting aid for numbers 1-9
              if (targetNumber != '0')
                Container(
                  margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Count ${_getNumberWord(targetNumber).toLowerCase()}:',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        children: List.generate(
                          int.parse(targetNumber),
                              (index) => Container(
                            margin: const EdgeInsets.all(2),
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '⭐',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

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

              // Number Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: displayedNumbers.length <= 6 ? 3 : 4,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: displayedNumbers.length,
                    itemBuilder: (context, index) {
                      return _NumberButton(
                        number: displayedNumbers[index],
                        onTap: () => _onNumberSelected(displayedNumbers[index]),
                        isCorrect: displayedNumbers[index] == targetNumber,
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
              //     '🎯 Tap the number that matches the one shown above!',
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

class _NumberButton extends StatefulWidget {
  final String number;
  final VoidCallback onTap;
  final bool isCorrect;

  const _NumberButton({
    required this.number,
    required this.onTap,
    required this.isCorrect,
  });

  @override
  State<_NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<_NumberButton>
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
      const Color(0xFF34495E), // Dark Blue
      const Color(0xFF16A085), // Green Sea
    ];
    return colors[int.parse(widget.number) % colors.length];
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
                    // Number
                    Center(
                      child: Text(
                        widget.number,
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