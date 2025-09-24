import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class SimpleMathGame extends FlameGame with TapCallbacks {
  List<AnswerButton> answerButtons = [];
  int num1 = 0;
  int num2 = 0;
  String operation = '+';
  int correctAnswer = 0;
  int score = 0;
  late TextComponent scoreText;
  late TextComponent instructionText;
  late TextComponent problemText;

  final Random random = Random();

  @override
  Color backgroundColor() => const Color(0xFFE74C3C);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add instruction text
    instructionText = TextComponent(
      text: 'Solve the math problem!',
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

    // Add problem text
    problemText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, 200),
      anchor: Anchor.center,
    );
    add(problemText);

    _setupAnswerButtons();
    _newProblem();
  }

  void _setupAnswerButtons() {
    const buttonWidth = 80.0;
    const buttonHeight = 60.0;
    const spacing = 20.0;

    final totalWidth = 3 * buttonWidth + 2 * spacing;
    final startX = (size.x - totalWidth) / 2;
    final buttonY = 320.0;

    // Create 3 answer buttons
    for (int i = 0; i < 3; i++) {
      final button = AnswerButton(
        answer: 0, // Will be set in _newProblem()
        game: this,
        size: Vector2(buttonWidth, buttonHeight),
        position: Vector2(startX + i * (buttonWidth + spacing), buttonY),
      );

      answerButtons.add(button);
      add(button);
    }
  }

  void _newProblem() {
    // Generate simple addition or subtraction problem
    if (random.nextBool()) {
      // Addition: numbers 1-9
      operation = '+';
      num1 = random.nextInt(9) + 1;
      num2 = random.nextInt(9) + 1;
      correctAnswer = num1 + num2;
    } else {
      // Subtraction: ensure positive result
      operation = '-';
      num1 = random.nextInt(9) + 2; // 2-10
      num2 = random.nextInt(num1 - 1) + 1; // 1 to num1-1
      correctAnswer = num1 - num2;
    }

    // Update problem text
    problemText.text = '$num1 $operation $num2 = ?';

    // Generate answer options
    List<int> answers = [correctAnswer];

    // Add 2 wrong answers
    while (answers.length < 3) {
      int wrongAnswer;
      if (operation == '+') {
        wrongAnswer = correctAnswer + random.nextInt(5) - 2;
      } else {
        wrongAnswer = correctAnswer + random.nextInt(3) - 1;
      }

      if (wrongAnswer > 0 && wrongAnswer <= 20 && !answers.contains(wrongAnswer)) {
        answers.add(wrongAnswer);
      }
    }

    // Shuffle answers
    answers.shuffle();

    // Update buttons
    for (int i = 0; i < answerButtons.length; i++) {
      answerButtons[i].updateAnswer(answers[i]);
    }
  }

  void onAnswerSelected(int selectedAnswer) {
    if (selectedAnswer == correctAnswer) {
      // Correct answer!
      score += 15;
      scoreText.text = 'Score: $score';

      // Show success feedback
      final successText = TextComponent(
        text: 'Excellent! +15',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2, size.y / 2 + 50),
        anchor: Anchor.center,
      );
      add(successText);

      // Add celebration effect
      _addCelebrationStars();

      Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
        successText.removeFromParent();
        _newProblem();
      });
    } else {
      // Wrong answer
      final wrongText = TextComponent(
        text: 'Try again! The answer is $correctAnswer',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2, size.y / 2 + 50),
        anchor: Anchor.center,
      );
      add(wrongText);

      Future.delayed(const Duration(seconds: 2), () {
        wrongText.removeFromParent();
        _newProblem();
      });
    }
  }

  void _addCelebrationStars() {
    for (int i = 0; i < 5; i++) {
      final star = CelebrationStar(
        position: Vector2(
          size.x / 2 + (random.nextDouble() - 0.5) * 100,
          size.y / 2 + (random.nextDouble() - 0.5) * 100,
        ),
      );
      add(star);
    }
  }
}

class AnswerButton extends PositionComponent with TapCallbacks {
  int answer;
  final SimpleMathGame game;
  bool isPressed = false;

  AnswerButton({
    required this.answer,
    required this.game,
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

    // Draw button background
    final bgColor = isPressed ? const Color(0xFFD35400) : const Color(0xFFF39C12);
    final paint = Paint()..color = bgColor;
    canvas.drawRRect(rrect, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, borderPaint);

    // Draw answer text
    final textPainter = TextPainter(
      text: TextSpan(
        text: answer.toString(),
        style: const TextStyle(
          fontSize: 32,
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
    game.onAnswerSelected(answer);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isPressed = false;
  }

  void updateAnswer(int newAnswer) {
    answer = newAnswer;
  }
}

class CelebrationStar extends PositionComponent {
  double lifetime = 0;
  final double maxLifetime = 1.5;
  late Vector2 velocity;
  final Random random = Random();

  CelebrationStar({required Vector2 position})
      : super(position: position, size: Vector2.all(30), anchor: Anchor.center) {
    velocity = Vector2(
      (random.nextDouble() - 0.5) * 100,
      -random.nextDouble() * 50 - 25,
    );
  }

  @override
  void render(Canvas canvas) {
    final opacity = (1.0 - lifetime / maxLifetime).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = Colors.yellow.withOpacity(opacity);

    // Draw star shape
    final center = size / 2;
    final radius = size.x / 2 * (1.0 + sin(lifetime * 10) * 0.2);

    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = i * 2 * pi / 5 - pi / 2;
      final outerX = center.x + cos(angle) * radius;
      final outerY = center.y + sin(angle) * radius;

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }

      final innerAngle = angle + pi / 5;
      final innerX = center.x + cos(innerAngle) * radius * 0.5;
      final innerY = center.y + sin(innerAngle) * radius * 0.5;
      path.lineTo(innerX, innerY);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifetime += dt;

    position += velocity * dt;
    velocity.y += 100 * dt; // Gravity

    if (lifetime >= maxLifetime) {
      removeFromParent();
    }
  }
}