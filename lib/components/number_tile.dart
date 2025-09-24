import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class NumberTile extends PositionComponent with TapCallbacks, HasGameRef {
  final String number;
  late TextPaint _textPaint;
  late TextPainter _textPainter;

  NumberTile({
    required this.number,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Adjust font size based on number length
    double fontSize;
    if (number.length == 1) {
      fontSize = size.y * 0.5; // Single digit
    } else if (number.length == 2) {
      fontSize = size.y * 0.4; // Double digit
    } else {
      fontSize = size.y * 0.3; // Triple digit (100)
    }

    _textPaint = TextPaint(
      style: TextStyle(
        fontFamily: 'Roboto',
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
      ),
    );

    // Initialize TextPainter for measuring text
    _textPainter = TextPainter(
      text: TextSpan(text: number, style: _textPaint.style),
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout();
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = _bgColorForNumber(number);
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(12),
    );

    // Draw background
    canvas.drawRRect(rrect, paint);

    // Draw border
    canvas.drawRRect(rrect, borderPaint);

    // Add subtle gradient effect
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          paint.color.withOpacity(0.8),
          paint.color,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawRRect(rrect, gradientPaint);

    // Use TextPainter to get text dimensions
    final textWidth = _textPainter.width;
    final textHeight = _textPainter.height;

    // Draw the number centered
    _textPaint.render(
      canvas,
      number,
      Vector2(size.x / 2 - textWidth / 2, size.y / 2 - textHeight / 2),
    );
  }

  Color _bgColorForNumber(String num) {
    final palette = [
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

    // Use the number value to determine color
    final numberValue = int.parse(num);
    return palette[(numberValue - 1) % palette.length];
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Play number pronunciation (commented out until audio is set up)
    // audioManager.playNumber(number);

    // Add visual feedback
    add(
      ScaleEffect.to(
        Vector2.all(1.1),
        EffectController(
          duration: 0.1,
          reverseDuration: 0.1,
          curve: Curves.easeOut,
        ),
      ),
    );

    // Add a subtle bounce effect
    add(
      MoveEffect.by(
        Vector2(0, -5),
        EffectController(
          duration: 0.1,
          reverseDuration: 0.1,
          curve: Curves.easeOut,
        ),
      ),
    );
  }
}