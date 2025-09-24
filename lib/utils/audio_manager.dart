// import 'package:flame_audio/flame_audio.dart';

// class AudioManager {
//   Future<void> init() async {
//     // Pre-cache all letter sounds for faster playback
//     for (int i = 0; i < 26; i++) {
//       final l = String.fromCharCode(65 + i);
//       try {
//         await FlameAudio.audioCache.load('letters/$l.mp3');
//       } catch (_) {}
//     }
//   }

//   Future<void> playLetter(String letter) async {
//     try {
//       FlameAudio.play('letters/$letter.mp3');
//     } catch (e) {
//       print('Audio play failed for $letter: $e');
//     }
//   }
// }
