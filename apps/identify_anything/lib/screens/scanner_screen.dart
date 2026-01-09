import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ui_shell/ui_shell.dart';
import '../services/vision_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String _resultText = "Point at something...";
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

  Future<void> _snapAndAnalyze() async {
    if (!_isCameraInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      
      final result = await VisionService().processImage(inputImage, _currentMode);
      
      if (mounted) {
        setState(() {
          _resultText = result;
          _isProcessing = false;
        });
        _showResultSheet(result);
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isProcessing = false);
    }
  }

  void _showResultSheet(String result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FactoryCard(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "I see:",
                style:  Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              Text(
                result,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              FactoryButton(
                label: "Scan Again",
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    VisionService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return FactoryScaffold(
        title: 'Scanner',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Camera Layer
          SizedBox.expand(child: CameraPreview(_controller!)),
          
          // UI Layer
          SafeArea(
            child: Column(
              children: [
                // Mode Switcher
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModeBtn("Object", ScanMode.object),
                      SizedBox(width: 16),
                      _buildModeBtn("Text", ScanMode.text),
                    ],
                  ),
                ),
                Spacer(),
                // Shutter Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: GestureDetector(
                    onTap: _snapAndAnalyze,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: FactoryColors.primary, width: 4),
                      ),
                      child: _isProcessing 
                        ? CircularProgressIndicator()
                        : Icon(Icons.camera_alt, color: FactoryColors.primary, size: 40),
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

  Widget _buildModeBtn(String label, ScanMode mode) {
    final isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _currentMode = mode),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? FactoryColors.secondary : Colors.white60,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }
}
