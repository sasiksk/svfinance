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

  static Future<String?> getLineIdByName(String lineName) async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'Line',
      columns: ['Line_id'],
      where: 'Line_Name = ?',
      whereArgs: [lineName],
    );

    if (result.isNotEmpty) {
      return result.first['Line_id'] as String?;
    } else {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllLines() async {
    final db = await DatabaseHelper.getDatabase();
    return db.query('Line');
  }

  static Future<Map<String, dynamic>> getTotalAmounts() async {
    final db = await DatabaseHelper.getDatabase();

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        COUNT(Line_id) as totalLines
      FROM Line
    ''');

    if (result.isNotEmpty) {
      return {
        'totalLines': result.first['totalLines'] ?? 0,
      };
    } else {
      return {
        'totalLines': 0,
      };
    }
  }

  static Future<Map<String, dynamic>?> getInvestmentDetailsByLineId(
      String lineId) async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'InvestmentTotal',
      columns: [
        'Inv_Total',
        'Inv_Remaing',
        'Lentamt',
        'Returnamt',
        'profit',
        'expense',
        'totallineamt'
      ],
      where: 'Line_id = ?',
      whereArgs: [lineId],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getPartyNamesByLineId(
      String lineId) async {
    final db = await DatabaseHelper.getDatabase();
    return db.query(
      'party',
      columns: ['P_Name'],
      where: 'Line_id = ?',
      whereArgs: [lineId],
    );
  }
}
