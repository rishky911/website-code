import 'package:isar/isar.dart';

part 'schema.g.dart';

@collection
class JournalEntry {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  int moodScore = 3; // 1 to 5
  
  String? text;
  
  String? sentimentAnalysis; // AI Feedback
}
