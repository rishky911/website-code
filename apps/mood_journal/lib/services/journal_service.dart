import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../data/schema.dart';

class JournalService {
  static final JournalService _instance = JournalService._internal();

  factory JournalService() {
    return _instance;
  }

  JournalService._internal();

  Isar? _isar;

  Future<void> init() async {
    if (_isar != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [JournalEntrySchema],
      directory: dir.path,
    );
  }

  Future<void> addEntry(JournalEntry entry) async {
    await init();
    await _isar!.writeTxn(() async {
      await _isar!.journalEntrys.put(entry);
    });
  }

  Future<List<JournalEntry>> getAllEntries() async {
    await init();
    return await _isar!.journalEntrys.where().sortByDateDesc().findAll();
  }
}
