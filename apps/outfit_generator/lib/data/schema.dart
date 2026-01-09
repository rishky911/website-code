import 'package:isar/isar.dart';

part 'schema.g.dart';

enum ClothingType { top, bottom, shoes, other }

@collection
class ClothingItem {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime createdAt;

  late String imagePath;
  
  @Enumerated(EnumType.ordinal)
  late ClothingType type;
}
