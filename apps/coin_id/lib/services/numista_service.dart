import 'dart:convert';
import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;

class CoinData {
  final String title;
  final String year;
  final String composition;
  final String value;
  final String description;

  CoinData({
    required this.title,
    required this.year,
    required this.composition,
    required this.value,
    required this.description,
  });
}

class NumistaService {
  static final NumistaService _instance = NumistaService._internal();

  factory NumistaService() {
    return _instance;
  }

  NumistaService._internal();

  /// Fetches coin details based on the recognized label.
  /// Uses a mock DB for now to simulate the API response.
  Future<CoinData> getCoinDetails(String label) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800));
    
    // Mock Data based on label
    if (label.contains("Penny")) {
      return CoinData(
        title: "Lincoln Wheat Penny",
        year: "1943",
        composition: "Zinc-coated Steel",
        value: "\$0.15 - \$0.50",
        description: "Strike during WWII, copper was needed for the war effort so these were made of steel. Highly magnetic.",
      );
    } else {
      return CoinData(
        title: "Unknown Coin",
        year: "????",
        composition: "Unknown",
        value: "???",
        description: "We couldn't match this coin in the database specifically.",
      );
    }
  }
}
