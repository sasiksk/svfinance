import 'package:sqflite/sqflite.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';

class LineOperations {
  static Future<void> insertLine(String lineId, String lineName) async {
    final db = await DatabaseHelper.getDatabase();

    // Check if the entry already exists
    final List<Map<String, dynamic>> existingEntries = await db.query(
      'Line',
      where: 'Line_id = ?',
      whereArgs: [lineId],
    );

    if (existingEntries.isNotEmpty) {
      // Entry already exists
      throw Exception('Cannot insert: Line ID already exists.');
    } else {
      // Insert the new entry
      await db.insert(
        'Line',
        {
          'Line_id': lineId,
          'Line_Name': lineName,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<Map<String, dynamic>>> getAllLines() async {
    final db = await DatabaseHelper.getDatabase();
    return db.query('Line');
  }
}
