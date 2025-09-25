import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

enum BalloonType { number, letter, color }
enum GameMode { numbers, letters, colors }

class BalloonPopGame extends FlameGame with TapCallbacks {
  List<FloatingBalloon> balloons = [];
  int score = 0;
  int correctBalloonsPoppedThisRound = 0;
  int totalCorrectBalloonsThisRound = 0;
  late TextComponent scoreText;
  late TextComponent instructionText;
  late TextComponent progressText;

  GameMode currentMode = GameMode.numbers;
  String currentTarget = "";
  Color? currentTargetColor;

  final Random random = Random();

  // Game content
  final List<String> numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  final List<String> letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'];
  final List<Color> balloonColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.cyan,
  ];

  final Map<Color, String> colorNames = {
    Colors.red: 'RED',
    Colors.blue: 'BLUE',
    Colors.green: 'GREEN',
    Colors.yellow: 'YELLOW',
    Colors.purple: 'PURPLE',
    Colors.orange: 'ORANGE',
    Colors.pink: 'PINK',
    Colors.cyan: 'CYAN',
  };

  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // Sky blue

  @override
  Future<void> onLoad() async {
    await super.onLoad();

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

    // Add instruction text
    instructionText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, 60),
      anchor: Anchor.center,
    );
    add(instructionText);

    // Add progress text
    progressText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      position: Vector2(size.x / 2, 90),
      anchor: Anchor.center,
    );
    add(progressText);

    _startNewRound();
  }

  void _startNewRound() {
    // Clear existing balloons
    for (final balloon in balloons) {
      balloon.removeFromParent();
    }
    balloons.clear();

    correctBalloonsPoppedThisRound = 0;

    // Cycle through game modes
    currentMode = GameMode.values[random.nextInt(GameMode.values.length)];

    _generateBalloons();
    _updateInstructions();
  }

  void _generateBalloons() {
    const balloonCount = 12;
    List<String> contentList = [];
    String correctContent = '';

    switch (currentMode) {
      case GameMode.numbers:
      // Pick a target number
        currentTarget = numbers[random.nextInt(numbers.length)];
        correctContent = currentTarget;

        // Create balloons: some with target number, others with different numbers
        final correctCount = random.nextInt(3) + 2; // 2-4 correct balloons
        totalCorrectBalloonsThisRound = correctCount;

        for (int i = 0; i < correctCount; i++) {
          contentList.add(correctContent);
        }

        // Fill rest with wrong numbers
        while (contentList.length < balloonCount) {
          String wrongNumber;
          do {
            wrongNumber = numbers[random.nextInt(numbers.length)];
          } while (wrongNumber == correctContent);
          contentList.add(wrongNumber);
        }
        break;

      case GameMode.letters:
      // Pick a target letter
        currentTarget = letters[random.nextInt(letters.length)];
        correctContent = currentTarget;

        final correctCount = random.nextInt(3) + 2; // 2-4 correct balloons
        totalCorrectBalloonsThisRound = correctCount;

        for (int i = 0; i < correctCount; i++) {
          contentList.add(correctContent);
        }

        // Fill rest with wrong letters
        while (contentList.length < balloonCount) {
          String wrongLetter;
          do {
            wrongLetter = letters[random.nextInt(letters.length)];
          } while (wrongLetter == correctContent);
          contentList.add(wrongLetter);
        }
        break;

      case GameMode.colors:
      // Pick a target color
        currentTargetColor = balloonColors[random.nextInt(balloonColors.length)];
        currentTarget = colorNames[currentTargetColor]!;

        final correctCount = random.nextInt(3) + 2; // 2-4 correct balloons
        totalCorrectBalloonsThisRound = correctCount;

        // For color mode, we'll use empty content and rely on balloon color
        for (int i = 0; i < balloonCount; i++) {
          contentList.add(''); // No text content for color balloons
        }
        break;
    }

    // Shuffle the content
    contentList.shuffle();

    // Create balloons at random positions
    for (int i = 0; i < balloonCount; i++) {
      final balloon = FloatingBalloon(
        content: contentList[i],
        balloonColor: currentMode == GameMode.colors ?
        (i < totalCorrectBalloonsThisRound ? currentTargetColor! : balloonColors[random.nextInt(balloonColors.length)]) :
        balloonColors[random.nextInt(balloonColors.length)],
        isCorrect: currentMode == GameMode.colors ?
        (i < totalCorrectBalloonsThisRound) :
        contentList[i] == correctContent,
        game: this,
        position: Vector2(
          50 + random.nextDouble() * (size.x - 100),
          150 + random.nextDouble() * (size.y - 250),
        ),
      );

      balloons.add(balloon);
      add(balloon);
    }
  }

  void _updateInstructions() {
    switch (currentMode) {
      case GameMode.numbers:
        instructionText.text = 'Pop all balloons with number $currentTarget!';
        break;
      case GameMode.letters:
        instructionText.text = 'Pop all balloons with letter $currentTarget!';
        break;
      case GameMode.colors:
        instructionText.text = 'Pop all $currentTarget balloons!';
        break;
    }

    progressText.text = 'Found: $correctBalloonsPoppedThisRound / $totalCorrectBalloonsThisRound';
  }

  void onBalloonPopped(FloatingBalloon balloon) {
    if (balloon.isCorrect) {
      correctBalloonsPoppedThisRound++;
      score += 10;

      // Show success effect
      _showPopEffect(balloon.position, Colors.yellow);

      // Update progress
      progressText.text = 'Found: $correctBalloonsPoppedThisRound / $totalCorrectBalloonsThisRound';

      // Check if round is complete
      if (correctBalloonsPoppedThisRound >= totalCorrectBalloonsThisRound) {
        score += 20; // Bonus for completing round

        final completeText = TextComponent(
          text: 'Great Job! Round Complete! +20 Bonus',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          position: Vector2(size.x / 2, size.y / 2),
          anchor: Anchor.center,
        );
        add(completeText);

        Future.delayed(const Duration(seconds: 2), () {
          completeText.removeFromParent();
          _startNewRound();
        });
      }
    } else {
      // Wrong balloon popped
      _showPopEffect(balloon.position, Colors.red);

      final wrongText = TextComponent(
        text: 'Oops! That\'s not the right one!',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.red,
            fontSize: 18,
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

    // Remove balloon
    balloon.removeFromParent();
    balloons.remove(balloon);

    // Update score
    scoreText.text = 'Score: $score';
  }

  void _showPopEffect(Vector2 position, Color color) {
    for (int i = 0; i < 6; i++) {
      final particle = PopParticle(
        position: position.clone(),
        velocity: Vector2(
          (random.nextDouble() - 0.5) * 200,
          (random.nextDouble() - 0.5) * 200,
        ),
        color: color,
      );
      add(particle);
    }
  }
}

class FloatingBalloon extends PositionComponent with TapCallbacks {
  final String content;
  final Color balloonColor;
  final bool isCorrect;
  final BalloonPopGame game;

  late Vector2 velocity;
  double floatTime = 0;
  final Random random = Random();

  FloatingBalloon({
    required this.content,
    required this.balloonColor,
    required this.isCorrect,
    required this.game,
    required Vector2 position,
  }) : super(position: position, size: Vector2.all(80), anchor: Anchor.center) {
    // Random floating motion
    velocity = Vector2(
      (random.nextDouble() - 0.5) * 30,
      -random.nextDouble() * 20 - 10,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    floatTime += dt;

    // Gentle floating motion
    position += velocity * dt;

    // Add sine wave motion for realistic floating
    position.x += sin(floatTime * 2) * 0.5;
    position.y += cos(floatTime * 1.5) * 0.3;

    // Keep balloons on screen
    if (position.x < 40) {
      position.x = 40;
      velocity.x = velocity.x.abs();
    }
    if (position.x > game.size.x - 40) {
      position.x = game.size.x - 40;
      velocity.x = -velocity.x.abs();
    }
    if (position.y < 120) {
      position.y = 120;
      velocity.y = velocity.y.abs();
    }
    if (position.y > game.size.y - 40) {
      position.y = game.size.y - 40;
      velocity.y = -velocity.y.abs();
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw balloon shadow
    final shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.x / 2 + 2, size.y / 2 + 2), width: size.x - 10, height: size.y - 5),
      shadowPaint,
    );

    // Draw balloon body
    final balloonPaint = Paint()..color = balloonColor;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.x / 2, size.y / 2), width: size.x - 10, height: size.y - 5),
      balloonPaint,
    );

    // Draw balloon highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.x / 2 - 8, size.y / 2 - 8), width: 20, height: 15),
      highlightPaint,
    );

    // Draw balloon border
    final borderPaint = Paint()
      ..color = balloonColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.x / 2, size.y / 2), width: size.x - 10, height: size.y - 5),
      borderPaint,
    );

    // Draw balloon string
    final stringPaint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.x / 2, size.y - 5),
      Offset(size.x / 2, size.y + 15),
      stringPaint,
    );

    // Draw content (number/letter) - only if there's content
    if (content.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: content,
          style: const TextStyle(
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
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.onBalloonPopped(this);
  }
}

class PopParticle extends PositionComponent {
  final Vector2 velocity;
  final Color color;
  double life = 1.0;

  PopParticle({
    required Vector2 position,
    required this.velocity,
    required this.color,
  }) : super(position: position, size: Vector2.all(8));

  @override
  void update(double dt) {
    super.update(dt);

    position += velocity * dt;
    velocity.y += 200 * dt; // Gravity
    life -= dt * 2;

    // Remove particle when life expires
    if (life <= 0) {
      life = 0; // Ensure life doesn't go negative
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // Clamp life between 0.0 and 1.0 to prevent withOpacity errors
    final clampedLife = life.clamp(0.0, 1.0);

    final paint = Paint()
      ..color = color.withOpacity(clampedLife)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2 * clampedLife,
      paint,
    );
  }
}