import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/alphabet_tile.dart';
import '../utils/audio_manager.dart';

class AlphabetGame extends FlameGame with TapCallbacks {
  // late AudioManager audioManager;
  final letters = List.generate(26, (i) => String.fromCharCode(65 + i));

  @override
  Color backgroundColor() => const Color(0xFF87CEFA);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // audioManager = AudioManager();
    //Test Commit
    // await audioManager.init();

    const columns = 5;
    final padding = 20.0;
    final tileSize = (size.x - padding * 2) / columns;
    double y = 100;

    for (int i = 0; i < letters.length; i++) {
      final l = letters[i];
      final col = i % columns;
      final row = i ~/ columns;
      final posX = padding + col * tileSize;
      final posY = y + row * tileSize;

      final tile = AlphabetTile(
        letter: l,
        position: Vector2(posX, posY),
        size: Vector2(tileSize - 12, tileSize - 12),
        // audioManager: audioManager,
      );
      add(tile);
    }

    add(
      TextComponent(
        text: 'ALPHABET',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2 - 70, 40),
      ),
    );
  }
}
