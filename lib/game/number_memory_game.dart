import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class NumberMemoryGame extends FlameGame with TapCallbacks {
  List<NumberCard> cards = [];
  List<int> flippedCards = [];
  int matches = 0;
  int score = 0;
  late TextComponent scoreText;
  late TextComponent instructionText;
  bool canFlip = true;

  @override
  Color backgroundColor() => const Color(0xFF4A90E2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add instruction text
    instructionText = TextComponent(
      text: 'Match the number pairs!',
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

    _initializeGame();
  }

  void _initializeGame() {
    // Clear existing cards
    for (final card in cards) {
      card.removeFromParent();
    }
    cards.clear();
    flippedCards.clear();
    matches = 0;

    // Create pairs of numbers 1-6
    List<int> numbers = [];
    for (int i = 1; i <= 6; i++) {
      numbers.add(i);
      numbers.add(i);
    }
    numbers.shuffle();

    // Create card grid 4x3
    const cardWidth = 70.0;
    const cardHeight = 90.0;
    const spacing = 10.0;

    final startX = (size.x - (4 * cardWidth + 3 * spacing)) / 2;
    final startY = 120.0;

    for (int i = 0; i < 12; i++) {
      final row = i ~/ 4;
      final col = i % 4;

      final card = NumberCard(
        number: numbers[i],
        cardIndex: i,
        game: this,
        size: Vector2(cardWidth, cardHeight),
        position: Vector2(
          startX + col * (cardWidth + spacing),
          startY + row * (cardHeight + spacing),
        ),
      );

      cards.add(card);
      add(card);
    }
  }

  void onCardTapped(int cardIndex) {
    if (!canFlip || cards[cardIndex].isFlipped || flippedCards.contains(cardIndex)) {
      return;
    }

    cards[cardIndex].flip();
    flippedCards.add(cardIndex);

    if (flippedCards.length == 2) {
      canFlip = false;

      Future.delayed(const Duration(milliseconds: 1000), () {
        _checkMatch();
      });
    }
  }

  void _checkMatch() {
    final firstCard = cards[flippedCards[0]];
    final secondCard = cards[flippedCards[1]];

    if (firstCard.number == secondCard.number) {
      // Match found!
      matches++;
      score += 20;
      scoreText.text = 'Score: $score';

      // Show success message
      final successText = TextComponent(
        text: 'Great Match! +20',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
      );
      add(successText);

      Future.delayed(const Duration(seconds: 1), () {
        successText.removeFromParent();
      });

      // Check if game is complete
      if (matches == 6) {
        _gameComplete();
      }
    } else {
      // No match - flip cards back
      firstCard.flip();
      secondCard.flip();
    }

    flippedCards.clear();
    canFlip = true;
  }

  void _gameComplete() {
    final congratsText = TextComponent(
      text: 'Congratulations!\nYou found all pairs!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
    add(congratsText);

    Future.delayed(const Duration(seconds: 3), () {
      congratsText.removeFromParent();
      _initializeGame();
    });
  }
}

class NumberCard extends PositionComponent with TapCallbacks {
  final int number;
  final int cardIndex;
  final NumberMemoryGame game;
  bool isFlipped = false;

  NumberCard({
    required this.number,
    required this.cardIndex,
    required this.game,
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position, anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

    if (isFlipped) {
      // Show number side
      final paint = Paint()..color = Colors.white;
      canvas.drawRRect(rrect, paint);

      final borderPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(rrect, borderPaint);

      // Draw number
      final textPainter = TextPainter(
        text: TextSpan(
          text: number.toString(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
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
    } else {
      // Show card back
      final paint = Paint()..color = const Color(0xFF2196F3);
      canvas.drawRRect(rrect, paint);

      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(rrect, borderPaint);

      // Draw question mark
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '?',
          style: TextStyle(
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
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.onCardTapped(cardIndex);
  }

  void flip() {
    isFlipped = !isFlipped;
  }
}