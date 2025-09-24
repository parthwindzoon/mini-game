import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class PatternGame extends FlameGame with TapCallbacks {
  List<PatternBlock> patternBlocks = [];
  List<ChoiceButton> choiceButtons = [];
  List<Color> currentPattern = [];
  Color missingColor = Colors.red;
  int missingIndex = 0;
  int score = 0;
  late TextComponent scoreText;
  late TextComponent instructionText;

  final List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  final Random random = Random();

  @override
  Color backgroundColor() => const Color(0xFF9B59B6);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add instruction text
    instructionText = TextComponent(
      text: 'Complete the pattern!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, 50),
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

    _setupChoiceButtons();
    _newPattern();
  }

  void _setupChoiceButtons() {
    const buttonSize = 50.0;
    const spacing = 15.0;
    final totalWidth = 3 * buttonSize + 2 * spacing;
    final startX = (size.x - totalWidth) / 2;
    final buttonY = size.y - 100;

    // Create 3 choice buttons
    for (int i = 0; i < 3; i++) {
      final button = ChoiceButton(
        color: Colors.red, // Will be set in _newPattern()
        game: this,
        size: Vector2.all(buttonSize),
        position: Vector2(startX + i * (buttonSize + spacing), buttonY),
      );

      choiceButtons.add(button);
      add(button);
    }
  }

  void _newPattern() {
    // Clear existing pattern blocks
    for (final block in patternBlocks) {
      block.removeFromParent();
    }
    patternBlocks.clear();

    // Generate a simple repeating pattern (length 4-6)
    final patternLength = random.nextInt(3) + 4; // 4-6 blocks
    currentPattern.clear();

    // Create a simple AB or ABC pattern
    final basePattern = <Color>[];
    final patternType = random.nextInt(3);

    if (patternType == 0) {
      // AB pattern: RED-BLUE-RED-BLUE...
      basePattern.addAll([availableColors[0], availableColors[1]]);
    } else if (patternType == 1) {
      // ABC pattern: RED-BLUE-GREEN-RED-BLUE-GREEN...
      basePattern.addAll([availableColors[0], availableColors[1], availableColors[2]]);
    } else {
      // ABB pattern: RED-BLUE-BLUE-RED-BLUE-BLUE...
      basePattern.addAll([availableColors[0], availableColors[1], availableColors[1]]);
    }

    // Fill the current pattern by repeating the base pattern
    for (int i = 0; i < patternLength; i++) {
      currentPattern.add(basePattern[i % basePattern.length]);
    }

    // Choose which block to make missing (not the first one)
    missingIndex = random.nextInt(patternLength - 1) + 1;
    missingColor = currentPattern[missingIndex];

    // Create pattern blocks
    const blockSize = 50.0;
    const spacing = 10.0;
    final totalWidth = patternLength * blockSize + (patternLength - 1) * spacing;
    final startX = (size.x - totalWidth) / 2;
    final blockY = 200.0;

    for (int i = 0; i < patternLength; i++) {
      final block = PatternBlock(
        color: i == missingIndex ? null : currentPattern[i],
        isMissing: i == missingIndex,
        size: Vector2.all(blockSize),
        position: Vector2(startX + i * (blockSize + spacing), blockY),
      );

      patternBlocks.add(block);
      add(block);
    }

    // Setup choice buttons with correct answer and 2 wrong answers
    List<Color> choices = [missingColor];

    // Add wrong choices
    while (choices.length < 3) {
      final wrongColor = availableColors[random.nextInt(availableColors.length)];
      if (!choices.contains(wrongColor)) {
        choices.add(wrongColor);
      }
    }

    // Shuffle choices
    choices.shuffle();

    // Update choice buttons
    for (int i = 0; i < choiceButtons.length; i++) {
      choiceButtons[i].updateColor(choices[i]);
    }
  }

  void onColorSelected(Color selectedColor) {
    if (selectedColor == missingColor) {
      // Correct choice!
      score += 20;
      scoreText.text = 'Score: $score';

      // Fill in the missing block
      patternBlocks[missingIndex].fillColor(selectedColor);

      // Show success feedback
      final successText = TextComponent(
        text: 'Perfect! Pattern complete! +20',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2, 300),
        anchor: Anchor.center,
      );
      add(successText);

      // Animate pattern blocks
      for (final block in patternBlocks) {
        block.celebrate();
      }

      Future.delayed(const Duration(seconds: 2), () {
        successText.removeFromParent();
        _newPattern();
      });
    } else {
      // Wrong choice
      final wrongText = TextComponent(
        text: 'Look at the pattern more carefully!',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2, 300),
        anchor: Anchor.center,
      );
      add(wrongText);

      Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
        wrongText.removeFromParent();
      });
    }
  }
}

class PatternBlock extends PositionComponent {
  Color? color;
  bool isMissing;
  bool isCelebrating = false;
  double celebrationTime = 0;

  PatternBlock({
    required this.color,
    required this.isMissing,
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2),
      width: size.x - 4,
      height: size.y - 4,
    );

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

    canvas.save();
    if (isCelebrating) {
      final bounce = sin(celebrationTime * 8) * 0.1 + 1.0;
      canvas.scale(bounce);
    }

    if (isMissing && color == null) {
      // Draw dashed outline for missing block
      final dashPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      // Simple dashed effect
      canvas.drawRRect(rrect, dashPaint);

      // Draw question mark
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '?',
          style: TextStyle(
            fontSize: 24,
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
    } else if (color != null) {
      // Draw colored block
      final paint = Paint()..color = color!;
      canvas.drawRRect(rrect, paint);

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(rrect, borderPaint);
    }

    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isCelebrating) {
      celebrationTime += dt;
    }
  }

  void fillColor(Color newColor) {
    color = newColor;
    isMissing = false;
  }

  void celebrate() {
    isCelebrating = true;
    celebrationTime = 0;
  }
}

class ChoiceButton extends PositionComponent with TapCallbacks {
  Color color;
  final PatternGame game;
  bool isPressed = false;

  ChoiceButton({
    required this.color,
    required this.game,
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final radius = size.x / 2;
    final center = Offset(size.x / 2, size.y / 2);

    // Draw shadow if not pressed
    if (!isPressed) {
      final shadowPaint = Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(center + const Offset(2, 2), radius, shadowPaint);
    }

    // Draw main circle
    final paint = Paint()..color = color;
    canvas.drawCircle(center, radius - 2, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius - 2, borderPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    isPressed = false;
    game.onColorSelected(color);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isPressed = false;
  }

  void updateColor(Color newColor) {
    color = newColor;
  }
}