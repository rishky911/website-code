import 'package:isar/isar.dart';

part 'schema.g.dart';

@collection
class CycleEntry {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  String? flowIntensity; // Low, Medium, High
  
  List<String>? symptoms; // Cramps, Headache, etc.
  
  String? note;
}
