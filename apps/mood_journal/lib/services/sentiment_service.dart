import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SentimentService {
  static final SentimentService _instance = SentimentService._internal();

  factory SentimentService() {
    return _instance;
  }

  SentimentService._internal();

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    // Return saved key or default to injected key
    return prefs.getString('gemini_api_key') ?? "AIzaSyBkvwclQeQebTefRC88_rJ7jE3e3EAdfJ4";
  }

  Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key);
  }

  /// Returns a brief sentiment analysis/encouragement
  Future<String> analyze(String text) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      // Demo fallback
      await Future.delayed(Duration(seconds: 1)); 
      return "That sounds like an important moment. (Demo Mode - Set API Key in Settings)";
    }

    try {
      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      final prompt = 'Analyze the sentiment of this journal entry and provide a single sentence of wise, comforting, or validating feedback. Do not be overly clinical. Text: "$text"';
      
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      return response.text ?? "Could not analyze.";
    } catch (e) {
      debugPrint("Gemini Error: $e");
      return "Error connecting to AI.";
    }
  }
}
