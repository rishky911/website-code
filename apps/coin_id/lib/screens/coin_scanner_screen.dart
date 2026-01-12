import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ui_shell/ui_shell.dart';
import '../services/coin_recognition_service.dart';
import '../services/numista_service.dart';

class CoinScannerScreen extends StatefulWidget {
  const CoinScannerScreen({super.key});

  @override
  State<CoinScannerScreen> createState() => _CoinScannerScreenState();
}

class _CoinScannerScreenState extends State<CoinScannerScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(
          cameras.first,
          ResolutionPreset.veryHigh, // Higher res for macro details
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    }
  }

  Future<void> _snapAndIdentify() async {
    if (!_isCameraInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);

      // 1. Identify Coin
      final prediction =
          await CoinRecognitionService().identifyCoin(inputImage);

      // 2. Get Valuation
      final details = await NumistaService().getCoinDetails(prediction.label);

      if (mounted) {
        setState(() => _isProcessing = false);
        _showCoinDetails(prediction, details);
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isProcessing = false);
    }
  }

  void _showCoinDetails(CoinPrediction prediction, CoinData details) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => FactoryCard(
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3)),
                ),
              ),
              SizedBox(height: 24),
              Text(
                details.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "Confidence: ${(prediction.confidence * 100).toStringAsFixed(0)}%",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              Divider(height: 32),
              _buildDetailRow("Year", details.year),
              _buildDetailRow("Composition", details.composition),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FactoryColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    Text("Estimated Value",
                        style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(details.value,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900])),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text("Description",
                  style: Theme.of(context).textTheme.titleSmall),
              SizedBox(height: 8),
              Text(details.description,
                  style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 32),
              FactoryButton(
                label: "Scan Another",
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return FactoryScaffold(
        title: 'Coin Scanner',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera
          SizedBox.expand(child: CameraPreview(_controller!)),

          // Reference Overlay (Coin Circle) with pulse effect (simulated via simple transparency for now)
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.black.withValues(alpha: 0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black45,
                        spreadRadius: 1000) // Vignette effect mask
                  ]),
            ),
          ),

          // UI Layer
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      "Align coin within circle",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Spacer(),
                // Shutter Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 48.0),
                  child: GestureDetector(
                    onTap: _snapAndIdentify,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color:
                            _isProcessing ? Colors.white : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: _isProcessing
                            ? Padding(
                                padding: EdgeInsets.all(20),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.search, color: Colors.black),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Back Button
          Positioned(
            top: 48,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
