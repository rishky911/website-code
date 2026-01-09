import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Voice {
  final String id;
  final String name;
  
  Voice({required this.id, required this.name});
}

class ElevenLabsService {
  static final ElevenLabsService _instance = ElevenLabsService._internal();

  factory ElevenLabsService() {
    return _instance;
  }

  ElevenLabsService._internal();

  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  
  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('eleven_api_key');
  }

  Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('eleven_api_key', key);
  }

  Future<List<Voice>> getVoices() async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return [Voice(id: 'demo', name: 'Demo Voice (Adam)')];
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/voices'),
        headers: {'xi-api-key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final voices = (data['voices'] as List).map((v) => Voice(
          id: v['voice_id'],
          name: v['name'],
        )).toList();
        return voices;
      }
    } catch (e) {
      debugPrint('[ElevenLabs] Error fetching voices: $e');
    }
    return [Voice(id: 'err', name: 'Error fetching voices')]; 
  }

  /// Synthesizes text and returns the path to the saved MP3 file.
  Future<String?> synthesize(String text, String voiceId) async {
    final apiKey = await getApiKey();
    
    // DEMO MODE
    if (apiKey == null || apiKey.isEmpty) {
      await Future.delayed(Duration(seconds: 1)); // Simulate work
      // Return null or a path to a dummy local asset if we had one.
      // For now we'll throw to handle it in UI
      throw Exception('API Key missing. Please set it in Settings.');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/text-to-speech/$voiceId'),
        headers: {
          'xi-api-key': apiKey,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: json.encode({
          "text": text,
          "model_id": "eleven_monolingual_v1",
          "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.75
          }
        }),
      );

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/speech_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        debugPrint('ElevenLabs API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('[ElevenLabs] Synthesis error: $e');
      return null;
    }
  }
}
