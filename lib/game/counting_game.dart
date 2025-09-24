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