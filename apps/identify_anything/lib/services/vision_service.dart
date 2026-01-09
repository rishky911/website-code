import 'package:camera/camera.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';

enum ScanMode { object, text }

class VisionService {
  static final VisionService _instance = VisionService._internal();

  factory VisionService() {
    return _instance;
  }

  VisionService._internal();

  late final ImageLabeler _imageLabeler;
  late final TextRecognizer _textRecognizer;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.5);
    _imageLabeler = ImageLabeler(options: options);
    _textRecognizer = TextRecognizer();
    
    _isInitialized = true;
    debugPrint('[VisionService] Initialized ML Models');
  }

  Future<String> processImage(InputImage inputImage, ScanMode mode) async {
    if (!_isInitialized) await initialize();

    try {
      if (mode == ScanMode.object) {
        final labels = await _imageLabeler.processImage(inputImage);
        if (labels.isEmpty) return "No object detected";
        return labels.map((l) => "${l.label} (${(l.confidence * 100).toStringAsFixed(0)}%)").join(", ");
      } else {
        final recognizedText = await _textRecognizer.processImage(inputImage);
        if (recognizedText.text.isEmpty) return "No text found";
        return recognizedText.text;
      }
    } catch (e) {
      debugPrint('[VisionService] Error: $e');
      return "Error processing image";
    }
  }

  void dispose() {
    _imageLabeler.close();
    _textRecognizer.close();
  }
}
