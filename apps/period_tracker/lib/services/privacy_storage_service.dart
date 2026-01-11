import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../data/schema.dart';

class PrivacyStorageService {
  static final PrivacyStorageService _instance =
      PrivacyStorageService._internal();

  factory PrivacyStorageService() {
    return _instance;
  }

  PrivacyStorageService._internal();

  Isar? _isar;
  final _secureStorage = const FlutterSecureStorage();

  Future<void> init() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [CycleEntrySchema],
      directory: dir.path,

      inspector: kDebugMode, // Only allow inspection in debug
    );
  }

  /// Retrieves or generates a secure encryption key from the keystore.
  /*
  Future<List<int>> _getEncryptionKey() async {
    String? keyString = await _secureStorage.read(key: 'isar_db_key');
    
    if (keyString == null) {
      // final key = Isar.generateSecureKey(); // Not available in Isar 3.x yet
      // keyString = base64Url.encode(key);
      // await _secureStorage.write(key: 'isar_db_key', value: keyString);
      return []; 
    } else {
      return base64Url.decode(keyString);
    }
  }
  */

  // --- CRUD Operations ---

  Future<void> logEntry(CycleEntry entry) async {
    await init();
    await _isar!.writeTxn(() async {
      await _isar!.cycleEntrys.put(entry);
    });
  }

  Future<List<CycleEntry>> getEntriesForMonth(DateTime month) async {
    await init();
    // Simple query: Get all and filter locally for now,
    // or use Isar queries if generated code was ready (requires build_runner).
    // For scaffolding, we rely on basic access.
    final all = await _isar!.cycleEntrys.where().findAll();
    return all
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .toList();
  }

  Future<CycleEntry?> getEntryByDate(DateTime date) async {
    await init();
    final all = await _isar!.cycleEntrys.where().findAll();
    try {
      return all.firstWhere((e) =>
          e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day);
    } catch (e) {
      return null;
    }
  }
}
