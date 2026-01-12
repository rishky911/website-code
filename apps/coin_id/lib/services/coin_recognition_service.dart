import 'dart:io';
// import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class CoinPrediction {
  final String label;
  final double confidence;

  CoinPrediction({required this.label, required this.confidence});
}

class CoinRecognitionService {
  static final CoinRecognitionService _instance =
      CoinRecognitionService._internal();

  factory CoinRecognitionService() {
    return _instance;
  }

  CoinRecognitionService._internal();

  bool _isInitialized = false;
  Interpreter? _interpreter;
  List<String> _labels = [];

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint("Loading TFLite model...");
      _interpreter = await Interpreter.fromAsset('assets/models/coins.tflite');
      // Load labels if available, otherwise use generic list
      // _labels = await FileUtil.loadLabels('assets/models/labels.txt');
      _labels = [
        "Penny",
        "Nickel",
        "Dime",
        "Quarter",
        "Half Dollar",
        "Silver Dollar"
      ];
      debugPrint("TFLite model loaded successfully.");
    } catch (e) {
      debugPrint(
          "WARNING: TFLite model not found or failed to load. Using Mock Mode. Error: $e");
      // Fallback is implicit: _interpreter remains null
    }
    _isInitialized = true;
  }

  Future<CoinPrediction> identifyCoin(InputImage image) async {
    if (!_isInitialized) await initialize();

    // 1. Mock Mode (Fallback)
    if (_interpreter == null) {
      await Future.delayed(
          const Duration(milliseconds: 800)); // Simulate processing
      return CoinPrediction(label: "1943 Steel Penny (Mock)", confidence: 0.98);
    }

    // 2. Real Inference
    try {
      // Preprocess image
      final img.Image? capturedImage =
          img.decodeImage(File(image.path).readAsBytesSync());
      if (capturedImage == null) throw Exception("Failed to decode image");

      // Resize to model header (assuming 224x224 standard)
      final img.Image resizedImage =
          img.copyResize(capturedImage, width: 224, height: 224);

      // Convert to input array [1, 224, 224, 3]
      var input = _imageToByteListFloat32(resizedImage, 224, 127.5, 127.5);

      // Output buffer [1, num_classes]
      var output =
          List<double>.filled(_labels.length, 0).reshape([1, _labels.length]);

      // Run inference
      _interpreter!.run(input, output);

      // Parse output
      var outputList = output[0] as List<double>;
      var maxScore = -1.0;
      var maxIndex = -1;

      for (var i = 0; i < outputList.length; i++) {
        if (outputList[i] > maxScore) {
          maxScore = outputList[i];
          maxIndex = i;
        }
      }

      String label = (maxIndex != -1 && maxIndex < _labels.length)
          ? _labels[maxIndex]
          : "Unknown";

      return CoinPrediction(label: label, confidence: maxScore);
    } catch (e) {
      debugPrint("Error running inference: $e");
      return CoinPrediction(label: "Error: ${e.toString()}", confidence: 0.0);
    }
  }

  // Helper: Convert Image to Float32 List for TFLite
  List<dynamic> _imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        // RGB
        buffer[pixelIndex++] = (pixel.r - mean) / std; // R
        buffer[pixelIndex++] = (pixel.g - mean) / std; // G
        buffer[pixelIndex++] = (pixel.b - mean) / std; // B
      }
    }
    return convertedBytes.reshape([1, inputSize, inputSize, 3]);
  }
}

// Helper to keep types consistent with previous VisionService if needed,
// though TFLite usually works with raw bytes or image paths.
class InputImage {
  final String path;
  InputImage.fromFilePath(this.path);
}
