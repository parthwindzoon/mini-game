import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/alphabet_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final game = AlphabetGame();
  runApp(GameWidget(game: game));
}
