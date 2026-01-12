import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ui_shell/ui_shell.dart';
import '../services/wardrobe_service.dart';
import '../data/schema.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen>
    with TickerProviderStateMixin {
  Map<ClothingType, ClothingItem?> _currentOutfit = {};
  bool _isLoading = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _shuffle(); // Initial load
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _shuffle() async {
    setState(() => _isLoading = true);
    _controller.forward(from: 0); // Start spin animation

    final outfit = await WardrobeService().generateOutfit();

    // Wait for animation
    await Future.delayed(Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _currentOutfit = outfit;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if empty
    // We can't easily check total inventory count here without a service call,
    // but if outfit is all null after a shuffle, it's likely empty.

    return FactoryScaffold(
      title: 'Stylist',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _shuffle,
        label: Text(_isLoading ? "Spinning..." : "Shuffle Look"),
        icon: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Icon(Icons.shuffle),
        backgroundColor: FactoryColors.tertiary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(flex: 3, child: _buildSlot(ClothingType.top, "Top", 0)),
            SizedBox(height: 12),
            Expanded(
                flex: 3, child: _buildSlot(ClothingType.bottom, "Bottom", 1)),
            SizedBox(height: 12),
            Expanded(
                flex: 2, child: _buildSlot(ClothingType.shoes, "Shoes", 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildSlot(ClothingType type, String placeholder, int index) {
    final item = _currentOutfit[type];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Slot machine effect:
        // If loading, vertical offset moves rapidly.
        // For simple MVP usage, we'll just blur/fade or slide in.

        final isSpinning = _controller.isAnimating;
        final offset = isSpinning
            ? (index % 2 == 0 ? 50.0 : -50.0) * _controller.value
            : 0.0;
        final opacity = isSpinning ? 0.5 : 1.0;

        return Transform.translate(
          offset: Offset(0, offset),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4)),
                ],
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: item == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 48, color: Colors.grey[300]),
                            Text(placeholder,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    : Image.file(
                        File(item.imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
