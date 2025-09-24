import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class ColorMatchingGame extends FlameGame with TapCallbacks {
  List<ColorButton> colorButtons = [];
  Color currentTargetColor = Colors.red;
  int score = 0;
  late TextComponent scoreText;
  late TextComponent instructionText;
  late ColorDisplay colorDisplay;

  final List<Color> gameColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
  ];

  final List<String> colorNames = [
    'RED',
    'BLUE',
    'GREEN',
    'YELLOW',
    'ORANGE',
    'PURPLE',
    'PINK',
    'CYAN',
  ];

  @override
  Color backgroundColor() => const Color(0xFF6A4C93);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add instruction text
    instructionText = TextComponent(
      text: 'Tap the matching color!',
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

    // Add color display (shows the color to match)
    colorDisplay = ColorDisplay(
      displayColor: currentTargetColor,
      size: Vector2(120, 80),
      position: Vector2(size.x / 2, 140),
    );
    add(colorDisplay);

    _setupGame();
    _newRound();
  }

  void _setupGame() {
    // Create color buttons in a grid
    const buttonSize = 60.0;
    const spacing = 20.0;
    final buttonsPerRow = 4;
    final totalWidth = buttonsPerRow * buttonSize + (buttonsPerRow - 1) * spacing;
    final startX = (size.x - totalWidth) / 2;
    final startY = 250.0;

    for (int i = 0; i < 8; i++) {
      final row = i ~/ buttonsPerRow;
      final col = i % buttonsPerRow;

      final button = ColorButton(
        color: gameColors[i],
        colorName: colorNames[i],
        game: this,
        size: Vector2.all(buttonSize),
        position: Vector2(
          startX + col * (buttonSize + spacing),
          startY + row * (buttonSize + spacing),
        ),
      );

      colorButtons.add(button);
      add(button);
    }
  }

  void _newRound() {
    final random = Random();
    currentTargetColor = gameColors[random.nextInt(gameColors.length)];
    colorDisplay.updateColor(currentTargetColor);
  }

  void onColorSelected(Color selectedColor) {
    if (selectedColor == currentTargetColor) {
      // Correct match!
      score += 10;
      scoreText.text = 'Score: $score';

      // Show success feedback
      final successText = TextComponent(
        text: 'Correct! +10',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2, size.y / 2 + 50),
        anchor: Anchor.center,
      );
      add(successText);

      Future.delayed(const Duration(seconds: 1), () {
        successText.removeFromParent();
        _newRound();
      });
    } else {
      // Wrong choice
      final wrongText = TextComponent(
        text: 'Try again!',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2, size.y / 2 + 50),
        anchor: Anchor.center,
      );
      add(wrongText);

      Future.delayed(const Duration(seconds: 1), () {
        wrongText.removeFromParent();
      });
    }
  }
}

class ColorDisplay extends PositionComponent {
  Color displayColor;

  ColorDisplay({
    required this.displayColor,
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    // Draw main color area
    final rect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2),
      width: size.x - 10,
      height: size.y - 10,
    );

    final paint = Paint()..color = displayColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      paint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      borderPaint,
    );
  }

  void updateColor(Color newColor) {
    displayColor = newColor;
  }
}

class ColorButton extends PositionComponent with TapCallbacks {
  final Color color;
  final String colorName;
  final ColorMatchingGame game;
  bool isPressed = false;

  ColorButton({
    required this.color,
    required this.colorName,
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
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 2, borderPaint);

    // Add subtle gradient effect
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.8),
          color,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 2));
    canvas.drawCircle(center, radius - 2, gradientPaint);
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
}