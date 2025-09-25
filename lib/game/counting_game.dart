import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class CountingGame extends FlameGame with TapCallbacks {
  List<CountingObject> objects = [];
  List<NumberButton> numberButtons = [];
  int currentCount = 0;
  int targetCount = 0;
  int score = 0;
  late TextComponent scoreText;
  late TextComponent instructionText;

  final List<String> objectEmojis = ['🎈', '⭐', '🎄', '🌸', '🦋', '🎾', '🍎', '🐰'];
  final Random random = Random();

  @override
  Color backgroundColor() => const Color(0xFF2ECC71);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add instruction text
    instructionText = TextComponent(
      text: 'Count the objects and pick the right number!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, 40),
      anchor: Anchor.center,
    );
    add(instructionText);

    // Add score text
    scoreText = TextComponent(
      text: 'Score: $score',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x - 20, 30),
      anchor: Anchor.topRight,
    );
    add(scoreText);

    _setupNumberButtons();
    _newRound();
  }

  void _setupNumberButtons() {
    const buttonSize = 50.0;
    const spacing = 15.0;
    final totalWidth = 10 * buttonSize + 9 * spacing;
    final startX = (size.x - totalWidth) / 2;
    final buttonY = size.y - 80;

    // Create number buttons 1-10
    for (int i = 1; i <= 10; i++) {
      final button = NumberButton(
        number: i,
        game: this,
        size: Vector2.all(buttonSize),
        position: Vector2(startX + (i - 1) * (buttonSize + spacing), buttonY),
      );

      numberButtons.add(button);
      add(button);
    }
  }

  void _newRound() {
    // Clear existing objects
    for (final obj in objects) {
      obj.removeFromParent();
    }
    objects.clear();

    // Generate random count between 1 and 10
    targetCount = random.nextInt(10) + 1;

    // Choose random emoji
    final emoji = objectEmojis[random.nextInt(objectEmojis.length)];

    // Create objects in random positions
    final objectArea = Rect.fromLTWH(20, 100, size.x - 40, size.y - 250);

    for (int i = 0; i < targetCount; i++) {
      bool validPosition = false;
      Vector2 position = Vector2.zero();
      int attempts = 0;

      // Try to find a position that doesn't overlap with existing objects
      while (!validPosition && attempts < 50) {
        position = Vector2(
          objectArea.left + random.nextDouble() * objectArea.width,
          objectArea.top + random.nextDouble() * objectArea.height,
        );

        validPosition = true;
        for (final existingObj in objects) {
          if (position.distanceTo(existingObj.position) < 60) {
            validPosition = false;
            break;
          }
        }
        attempts++;
      }

      final obj = CountingObject(
        emoji: emoji,
        size: Vector2.all(40),
        position: position,
      );

      objects.add(obj);
      add(obj);
    }
  }

  void onNumberSelected(int number) {
    if (number == targetCount) {
      // Correct answer!
      score += 10;
      scoreText.text = 'Score: $score';

      // Show success feedback
      final successText = TextComponent(
        text: 'Correct! There are $targetCount objects! +10',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2, size.y / 2 - 50),
        anchor: Anchor.center,
      );
      add(successText);

      // Animate objects
      for (final obj in objects) {
        obj.celebrate();
      }

      Future.delayed(const Duration(seconds: 2), () {
        successText.removeFromParent();
        _newRound();
      });
    } else {
      // Wrong answer
      final wrongText = TextComponent(
        text: 'Try counting again!',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2, size.y / 2 - 50),
        anchor: Anchor.center,
      );
      add(wrongText);

      Future.delayed(const Duration(seconds: 1), () {
        wrongText.removeFromParent();
      });
    }
  }
}

class CountingObject extends PositionComponent {
  final String emoji;
  bool isCelebrating = false;
  double celebrationTime = 0;

  CountingObject({
    required this.emoji,
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: size.x,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final offset = Offset(
      (size.x - textPainter.width) / 2,
      (size.y - textPainter.height) / 2,
    );

    canvas.save();
    if (isCelebrating) {
      // Add bounce effect during celebration
      final bounce = sin(celebrationTime * 10) * 0.2 + 1.0;
      canvas.scale(bounce);
    }
    textPainter.paint(canvas, offset);
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isCelebrating) {
      celebrationTime += dt;
    }
  }

  void celebrate() {
    isCelebrating = true;
    celebrationTime = 0;
  }
}

class NumberButton extends PositionComponent with TapCallbacks {
  final int number;
  final CountingGame game;
  bool isPressed = false;

  NumberButton({
    required this.number,
    required this.game,
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final radius = size.x / 2;
    final center = Offset(size.x / 2, size.y / 2);

    // Draw button background
    final bgColor = isPressed ? const Color(0xFF27AE60) : const Color(0xFF3498DB);
    final paint = Paint()..color = bgColor;
    canvas.drawCircle(center, radius - 2, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 2, borderPaint);

    // Draw number
    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final offset = Offset(
      (size.x - textPainter.width) / 2,
      (size.y - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  void onTapDown(TapDownEvent event) {
    isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    isPressed = false;
    game.onNumberSelected(number);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isPressed = false;
  }
}

// Scrollable version of the counting game using Flutter widgets
class ScrollableCountingGame extends StatefulWidget {
  const ScrollableCountingGame({super.key});

  @override
  State<ScrollableCountingGame> createState() => _ScrollableCountingGameState();
}

class _ScrollableCountingGameState extends State<ScrollableCountingGame> {
  int score = 0;
  int targetCount = 0;
  String currentEmoji = '🎈';
  List<String> currentObjects = [];
  List<int> answerOptions = [];
  bool showResult = false;
  String resultMessage = '';
  Color resultColor = Colors.green;

  final List<String> objectEmojis = ['🎈', '⭐', '🎄', '🌸', '🦋', '🎾', '🍎', '🐰'];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    setState(() {
      targetCount = random.nextInt(10) + 1; // 1-10 objects
      currentEmoji = objectEmojis[random.nextInt(objectEmojis.length)];
      currentObjects = List.generate(targetCount, (index) => currentEmoji);
      showResult = false;

      // Generate 4 multiple choice options (1 correct, 3 wrong)
      answerOptions.clear();
      answerOptions.add(targetCount); // Correct answer

      // Add 3 wrong answers
      while (answerOptions.length < 4) {
        int wrongAnswer = random.nextInt(10) + 1; // 1-10
        if (!answerOptions.contains(wrongAnswer)) {
          answerOptions.add(wrongAnswer);
        }
      }

      // Shuffle the options
      answerOptions.shuffle();
    });
  }

  void _onNumberSelected(int selectedNumber) {
    setState(() {
      if (selectedNumber == targetCount) {
        score += 10;
        resultMessage = 'Correct! There are $targetCount objects! +10';
        resultColor = Colors.white; // White as requested
      } else {
        resultMessage = 'Try again! Count carefully.';
        resultColor = Colors.red;
      }
      showResult = true;
    });

    if (selectedNumber == targetCount) {
      // Only generate new round if answer is correct
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _newRound();
        }
      });
    } else {
      // Hide wrong answer message after shorter delay, but keep same question
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
            colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
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
                      'COUNTING FUN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Count the objects and select the right number!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
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

              // Objects area - Scrollable
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      alignment: WrapAlignment.center,
                      children: currentObjects.map((emoji) =>
                          Container(
                            width: 50,
                            height: 50,
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                      ).toList(),
                    ),
                  ),
                ),
              ),

              // Result message
              if (showResult)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    resultMessage,
                    style: TextStyle(
                      color: resultColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Multiple Choice Answers (4 options)
              Padding(
                padding: const EdgeInsets.all(20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _CountingMultipleChoiceButton(
                      number: answerOptions[index],
                      onPressed: () => _onNumberSelected(answerOptions[index]),
                      isCorrect: answerOptions[index] == targetCount,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountingMultipleChoiceButton extends StatefulWidget {
  final int number;
  final VoidCallback onPressed;
  final bool isCorrect;

  const _CountingMultipleChoiceButton({
    required this.number,
    required this.onPressed,
    required this.isCorrect,
  });

  @override
  State<_CountingMultipleChoiceButton> createState() => _CountingMultipleChoiceButtonState();
}

class _CountingMultipleChoiceButtonState extends State<_CountingMultipleChoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
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

  Color _getButtonColor() {
    final colors = [
      const Color(0xFF3498DB), // Blue
      const Color(0xFFE74C3C), // Red
      const Color(0xFFF39C12), // Orange
      const Color(0xFF9B59B6), // Purple
    ];
    return colors[widget.number % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) {
              _animationController.reverse();
              widget.onPressed();
            },
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              decoration: BoxDecoration(
                color: _getButtonColor(),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.number.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
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
            ),
          ),
        );
      },
    );
  }
}