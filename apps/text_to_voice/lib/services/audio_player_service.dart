import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  factory AudioPlayerService() {
    return _instance;
  }

  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  
  bool get isPlaying => _player.playing;

  Future<void> playFile(String path) async {
    try {
      await _player.setFilePath(path);
      await _player.play();
    } catch (e) {
      debugPrint('[AudioPlayer] Error playing file: $e');
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }
  
  Future<void> dispose() async {
    await _player.dispose();
  }
}
