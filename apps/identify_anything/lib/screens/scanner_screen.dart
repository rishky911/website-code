import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ui_shell/ui_shell.dart';
import '../services/vision_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_manager/subscription_manager.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  ScanMode _currentMode = ScanMode.object;

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
          ResolutionPreset.high,
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

  int _scanCount = 0;

  Future<void> _snapAndAnalyze() async {
    if (!_isCameraInitialized || _isProcessing) return;

    // Factory Gate: Check Limits
    final isPro = ref.read(subscriptionServiceProvider).isPro;
    if (!isPro && _scanCount >= 3) {
      _showPaywall();
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      _scanCount++; // Increment usage

      final inputImage = InputImage.fromFilePath(image.path);

      final result =
          await VisionService().processImage(inputImage, _currentMode);

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _showResultSheet(result);
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isProcessing = false);
    }
  }

  void _showPaywall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaywallScreen(
          featureName: "Unlimited Scans",
          onSuccess: () {
            Navigator.pop(context); // Close paywall
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("You are now Pro! scanning...")));
            _snapAndAnalyze(); // Retrieve the scan they tried to do? Or just let them click again.
          },
        ),
      ),
    );
  }

  Widget _buildModeBtn(String label, ScanMode mode) {
    final isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _currentMode = mode),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? FactoryColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showResultSheet(String result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FactoryCard(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 24),
              Icon(Icons.auto_awesome,
                  color: FactoryColors.secondary, size: 32),
              SizedBox(height: 16),
              Text(
                "Analysis Complete",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                result,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: FactoryColors.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              FactoryButton(
                label: "Scan Another",
                icon: Icons.camera,
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return FactoryScaffold(
        title: 'Scanner',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isPro = ref.watch(subscriptionServiceProvider).isPro;
    final remaining = 3 - _scanCount;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Layer
          SizedBox.expand(child: CameraPreview(_controller!)),

          // Overlay Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black87,
                  ],
                ),
              ),
            ),
          ),

          // UI Layer
          SafeArea(
            child: Column(
              children: [
                // Top Bar: Back + Pro Status
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Spacer(),
                      if (!isPro)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: remaining > 0 ? Colors.black54 : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.bolt,
                                  color: FactoryColors.tertiary, size: 16),
                              SizedBox(width: 4),
                              Text(
                                "$remaining Free Scans",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Mode Switcher
                Container(
                  margin: EdgeInsets.only(top: 16),
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModeBtn("Identify", ScanMode.object),
                      _buildModeBtn("Read Text", ScanMode.text),
                    ],
                  ),
                ),

                Spacer(),

                // Shutter Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 48.0),
                  child: GestureDetector(
                    onTap: _snapAndAnalyze,
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
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
