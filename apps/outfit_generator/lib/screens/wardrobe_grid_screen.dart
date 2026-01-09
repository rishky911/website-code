import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ui_shell/ui_shell.dart';
import '../services/wardrobe_service.dart';
import '../data/schema.dart';

class WardrobeGridScreen extends StatefulWidget {
  const WardrobeGridScreen({super.key});

  @override
  State<WardrobeGridScreen> createState() => _WardrobeGridScreenState();
}

class _WardrobeGridScreenState extends State<WardrobeGridScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  List<ClothingItem> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_loadItems);
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    List<ClothingItem> items;
    if (_tabController.index == 0) {
      items = await WardrobeService().getAllItems();
    } else {
      // Index 1 = Top (0), 2 = Bottom (1), 3 = Shoes (2)
      // Mapping index to enum
      final type = ClothingType.values[_tabController.index - 1];
      items = await WardrobeService().getItemsByType(type);
    }
    
    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _addItem() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    // Show dialog to select type
    ClothingType? selectedType = await showDialog<ClothingType>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('What is this?'),
        children: [
          SimpleDialogOption(child: Padding(padding: EdgeInsets.all(8), child: Text("Top")), onPressed: () => Navigator.pop(context, ClothingType.top)),
          SimpleDialogOption(child: Padding(padding: EdgeInsets.all(8), child: Text("Bottom")), onPressed: () => Navigator.pop(context, ClothingType.bottom)),
          SimpleDialogOption(child: Padding(padding: EdgeInsets.all(8), child: Text("Shoes")), onPressed: () => Navigator.pop(context, ClothingType.shoes)),
        ],
      ),
    );

    if (selectedType != null) {
      await WardrobeService().addItem(File(photo.path), selectedType);
      _loadItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FactoryScaffold(
      title: 'My Wardrobe',
      floatingActionButton: FloatingActionButton(
        backgroundColor: FactoryColors.primary,
        child: Icon(Icons.add_a_photo),
        onPressed: _addItem,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: FactoryColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "All"),
              Tab(text: "Tops"),
              Tab(text: "Bottoms"),
              Tab(text: "Shoes"),
            ],
          ),
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator())
              : _items.isEmpty 
                ? Center(child: Text("Closet is empty. Add items!"))
                : GridView.builder(
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(item.imagePath),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
