import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../utils/audio_manager.dart';

class AlphabetTile extends PositionComponent with TapCallbacks, HasGameRef {
  final String letter;
  // final AudioManager audioManager;
  late TextPaint _textPaint;
  late TextPainter _textPainter;

  AlphabetTile({
    required this.letter,
    required Vector2 position,
    required Vector2 size,
    // required this.audioManager,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _textPaint = TextPaint(
      style: TextStyle(
        fontFamily: 'Roboto',
        color: Colors.brown[800],
        fontSize: size.y * 0.5,
        fontWeight: FontWeight.w900,
      ),
    );

    // Initialize TextPainter for measuring text
    _textPainter = TextPainter(
      text: TextSpan(text: letter, style: _textPaint.style),
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout();
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = _bgColorForLetter(letter);
    final borderPaint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(12),
    );

    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(rrect, borderPaint);

    // Use TextPainter to get text dimensions
    final textWidth = _textPainter.width;
    final textHeight = _textPainter.height;

    _textPaint.render(
      canvas,
      letter,
      Vector2(size.x / 2 - textWidth / 2, size.y / 2 - textHeight / 2),
    );
  }

  Color _bgColorForLetter(String l) {
    final palette = [
      const Color(0xFFFF6F61),
      const Color(0xFFFFD54F),
      const Color(0xFF81C784),
      const Color(0xFF4FC3F7),
      const Color(0xFFBA68C8),
    ];
    return palette[(l.codeUnitAt(0) - 65) % palette.length];
  }

  @override
  void onTapDown(TapDownEvent event) {
    // audioManager.playLetter(letter);
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
  }
}
