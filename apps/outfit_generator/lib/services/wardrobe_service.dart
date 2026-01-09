import 'dart:io';
import 'dart:math';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../data/schema.dart';

class WardrobeService {
  static final WardrobeService _instance = WardrobeService._internal();

  factory WardrobeService() {
    return _instance;
  }

  WardrobeService._internal();

  Isar? _isar;

  Future<void> init() async {
    if (_isar != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [ClothingItemSchema],
      directory: dir.path,
    );
  }

  Future<void> addItem(File imageFile, ClothingType type) async {
    await init();
    
    // Save image to local app storage
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${Uuid().v4()}.jpg';
    final savedImage = await imageFile.copy('${appDir.path}/$fileName');

    final item = ClothingItem()
      ..createdAt = DateTime.now()
      ..imagePath = savedImage.path
      ..type = type;

    await _isar!.writeTxn(() async {
      await _isar!.clothingItems.put(item);
    });
  }

  Future<List<ClothingItem>> getItemsByType(ClothingType type) async {
    await init();
    return await _isar!.clothingItems.filter().typeEqualTo(type).findAll();
  }
  
  Future<List<ClothingItem>> getAllItems() async {
    await init();
    return await _isar!.clothingItems.where().sortByCreatedAtDesc().findAll();
  }

  Future<Map<ClothingType, ClothingItem?>> generateOutfit() async {
    await init();
    final rng = Random();
    Map<ClothingType, ClothingItem?> outfit = {};

    for (var type in [ClothingType.top, ClothingType.bottom, ClothingType.shoes]) {
      final items = await getItemsByType(type);
      if (items.isNotEmpty) {
        outfit[type] = items[rng.nextInt(items.length)];
      } else {
        outfit[type] = null;
      }
    }
    return outfit;
  }
}
