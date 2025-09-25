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
  int correctAnswers = 0;
  int currentLevel = 1;
  late TextComponent scoreText;
  late TextComponent levelText;
  late TextComponent instructionText;

  // Expanded color palette
  final List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.cyan,
    Colors.brown,
    Colors.lime,
    Colors.indigo,
    Colors.teal,
    Colors.deepOrange,
    Colors.lightGreen,
    Colors.amber,
    Colors.deepPurple,
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

    // Add level text
    levelText = TextComponent(
      text: 'Level: $currentLevel',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(20, 30),
      anchor: Anchor.topLeft,
    );
    add(levelText);

    _setupChoiceButtons();
    _newPattern();
  }

  void _setupChoiceButtons() {
    const buttonSize = 45.0;
    const spacing = 12.0;
    final buttonCount = _getChoiceButtonCount();
    final totalWidth = buttonCount * buttonSize + (buttonCount - 1) * spacing;
    final startX = (size.x - totalWidth) / 2;
    final buttonY = size.y - 100;

    // Create choice buttons based on difficulty
    for (int i = 0; i < buttonCount; i++) {
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

  int _getChoiceButtonCount() {
    // More choices as difficulty increases
    if (currentLevel <= 2) return 3;
    if (currentLevel <= 4) return 4;
    return 5;
  }

  void _newPattern() {
    // Clear existing pattern blocks
    for (final block in patternBlocks) {
      block.removeFromParent();
    }
    patternBlocks.clear();

    // Update level based on correct answers
    final newLevel = (correctAnswers ~/ 10) + 1;
    if (newLevel != currentLevel) {
      currentLevel = newLevel;
      levelText.text = 'Level: $currentLevel';

      // Show level up message
      final levelUpText = TextComponent(
        text: 'Level Up! $currentLevel',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2, 120),
        anchor: Anchor.center,
      );
      add(levelUpText);

      Future.delayed(const Duration(seconds: 1), () {
        levelUpText.removeFromParent();
      });
    }

    // Generate pattern based on difficulty level
    _generatePatternByLevel();
    _createPatternBlocks();
    _updateChoiceButtons();
  }

  void _generatePatternByLevel() {
    currentPattern.clear();

    switch (currentLevel) {
      case 1:
        _generateSimplePattern(2, 4, 5); // AB pattern, 4-5 blocks
        break;
      case 2:
        _generateSimplePattern(3, 5, 6); // ABC pattern, 5-6 blocks
        break;
      case 3:
        _generateComplexPattern(3, 6, 7); // ABCABC pattern, 6-7 blocks
        break;
      case 4:
        _generateAlternatingPattern(4, 6, 8); // ABCDAB pattern, 6-8 blocks
        break;
      default:
        _generateAdvancedPattern(4, 7, 9); // Complex patterns, 7-9 blocks
    }
  }

  void _generateSimplePattern(int colorCount, int minLength, int maxLength) {
    final patternLength = random.nextInt(maxLength - minLength + 1) + minLength;
    final basePattern = <Color>[];

    // Randomly select colors from the full palette instead of just first few
    final shuffledColors = List<Color>.from(availableColors)..shuffle();
    for (int i = 0; i < colorCount; i++) {
      basePattern.add(shuffledColors[i]);
    }

    // Fill the current pattern by repeating the base pattern
    for (int i = 0; i < patternLength; i++) {
      currentPattern.add(basePattern[i % basePattern.length]);
    }
  }

  void _generateComplexPattern(int colorCount, int minLength, int maxLength) {
    final patternLength = random.nextInt(maxLength - minLength + 1) + minLength;
    final patterns = [
      [0, 1, 2, 0, 1, 2], // ABCABC
      [0, 1, 1, 0, 1, 1], // ABBAAB
      [0, 1, 2, 1, 0, 1], // ABCBAB
    ];

    final selectedPattern = patterns[random.nextInt(patterns.length)];
    // Randomly select from full color palette
    final shuffledColors = List<Color>.from(availableColors)..shuffle();
    final colors = shuffledColors.take(colorCount).toList();

    for (int i = 0; i < patternLength && i < selectedPattern.length * 2; i++) {
      final colorIndex = selectedPattern[i % selectedPattern.length];
      currentPattern.add(colors[colorIndex % colors.length]);
    }
  }

  void _generateAlternatingPattern(int colorCount, int minLength, int maxLength) {
    final patternLength = random.nextInt(maxLength - minLength + 1) + minLength;
    // Randomly select from full color palette
    final shuffledColors = List<Color>.from(availableColors)..shuffle();
    final colors = shuffledColors.take(colorCount).toList();

    // Create more complex alternating patterns
    final patternTypes = [
      [0, 1, 2, 3, 0, 1], // ABCDAB
      [0, 1, 0, 2, 0, 1], // ABABCAB
      [0, 1, 2, 0, 3, 1], // ABCADB
    ];

    final selectedType = patternTypes[random.nextInt(patternTypes.length)];

    for (int i = 0; i < patternLength; i++) {
      final colorIndex = selectedType[i % selectedType.length];
      currentPattern.add(colors[colorIndex % colors.length]);
    }
  }

  void _generateAdvancedPattern(int colorCount, int minLength, int maxLength) {
    final patternLength = random.nextInt(maxLength - minLength + 1) + minLength;
    // Randomly select from full color palette
    final shuffledColors = List<Color>.from(availableColors)..shuffle();
    final colors = shuffledColors.take(colorCount + 2).toList();

    // Most complex patterns
    final advancedPatterns = [
      [0, 1, 2, 3, 4, 0, 1], // ABCDEAB
      [0, 1, 0, 2, 1, 0, 3], // ABABCAD
      [0, 1, 2, 1, 3, 2, 1], // ABCBDCB
      [0, 1, 1, 2, 2, 3, 3], // ABBCCDD
    ];

    final selectedPattern = advancedPatterns[random.nextInt(advancedPatterns.length)];

    for (int i = 0; i < patternLength; i++) {
      final colorIndex = selectedPattern[i % selectedPattern.length];
      currentPattern.add(colors[colorIndex % colors.length]);
    }
  }

  void _createPatternBlocks() {
    // Choose which block to make missing (not the first one)
    missingIndex = random.nextInt(currentPattern.length - 1) + 1;
    missingColor = currentPattern[missingIndex];

    // Create pattern blocks
    const blockSize = 45.0;
    const spacing = 8.0;
    final totalWidth = currentPattern.length * blockSize + (currentPattern.length - 1) * spacing;
    final startX = (size.x - totalWidth) / 2;
    final blockY = 200.0;

    for (int i = 0; i < currentPattern.length; i++) {
      final block = PatternBlock(
        color: i == missingIndex ? null : currentPattern[i],
        isMissing: i == missingIndex,
        size: Vector2.all(blockSize),
        position: Vector2(startX + i * (blockSize + spacing), blockY),
      );

      patternBlocks.add(block);
      add(block);
    }
  }

  void _updateChoiceButtons() {
    // Clear existing buttons
    for (final button in choiceButtons) {
      button.removeFromParent();
    }
    choiceButtons.clear();

    // Setup new buttons with current difficulty
    _setupChoiceButtons();

    // Setup choice buttons with correct answer and wrong answers
    final choiceCount = _getChoiceButtonCount();
    List<Color> choices = [missingColor];

    // Add wrong choices from available colors
    final availableWrongColors = availableColors.where((color) =>
    color != missingColor && !currentPattern.contains(color)).toList();

    while (choices.length < choiceCount && availableWrongColors.isNotEmpty) {
      final wrongColor = availableWrongColors[random.nextInt(availableWrongColors.length)];
      if (!choices.contains(wrongColor)) {
        choices.add(wrongColor);
        availableWrongColors.remove(wrongColor);
      }
    }

    // Fill with colors from pattern if needed
    if (choices.length < choiceCount) {
      final patternColors = currentPattern.toSet().toList();
      for (final color in patternColors) {
        if (choices.length >= choiceCount) break;
        if (!choices.contains(color)) {
          choices.add(color);
        }
      }
    }

    // Shuffle choices
    choices.shuffle();

    // Update choice buttons
    for (int i = 0; i < choiceButtons.length && i < choices.length; i++) {
      choiceButtons[i].updateColor(choices[i]);
    }
  }

  void onColorSelected(Color selectedColor) {
    if (selectedColor == missingColor) {
      // Correct choice!
      correctAnswers++;
      final points = 10 + (currentLevel * 5); // More points for higher levels
      score += points;
      scoreText.text = 'Score: $score';

      // Fill in the missing block
      patternBlocks[missingIndex].fillColor(selectedColor);

      // Show success feedback
      final successText = TextComponent(
        text: 'Perfect! Pattern complete! +$points',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white, // Changed to white as requested
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2, 280),
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
      // Wrong choice - don't change the pattern, let them try again
      final wrongText = TextComponent(
        text: 'Look at the pattern more carefully!',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2, 280),
        anchor: Anchor.center,
      );
      add(wrongText);

      Future.delayed(const Duration(seconds: 1), () {
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