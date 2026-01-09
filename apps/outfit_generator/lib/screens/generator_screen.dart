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

class _GeneratorScreenState extends State<GeneratorScreen> {
  Map<ClothingType, ClothingItem?> _currentOutfit = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  Future<void> _shuffle() async {
    setState(() => _isLoading = true);
    final outfit = await WardrobeService().generateOutfit();
    // Simulate thinking time for effect
    await Future.delayed(Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _currentOutfit = outfit;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FactoryScaffold(
      title: 'Outfit Generator',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _shuffle,
        label: Text("Shuffle Look"),
        icon: Icon(Icons.shuffle),
        backgroundColor: FactoryColors.tertiary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: _buildSlot(ClothingType.top, "Top")),
            SizedBox(height: 8),
            Expanded(child: _buildSlot(ClothingType.bottom, "Bottom")),
            SizedBox(height: 8),
            Expanded(child: _buildSlot(ClothingType.shoes, "Shoes")),
          ],
        ),
      ),
    );
  }

  Widget _buildSlot(ClothingType type, String placeholder) {
    final item = _currentOutfit[type];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: item == null
          ? Center(child: Text(placeholder, style: TextStyle(color: Colors.grey, fontSize: 24, fontWeight: FontWeight.bold)))
          : ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(item.imagePath),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
    );
  }
}
