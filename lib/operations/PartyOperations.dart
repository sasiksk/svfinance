import 'package:sqflite/sqflite.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';

class PartyOperations {
  static Future<void> insertParty(String partyId, String lineId,
      String partyName, String partyPhoneNumber, String address) async {
    final db = await DatabaseHelper.getDatabase();

    // Check if the entry already exists with the composite key
    final List<Map<String, dynamic>> existingEntries = await db.query(
      'party',
      where: 'P_id = ? AND Line_id = ?',
      whereArgs: [partyId, lineId],
    );

    if (existingEntries.isNotEmpty) {
      // Entry already exists
      throw Exception(
          'Cannot insert: Party ID and Line ID combination already exists.');
    } else {
      // Insert the new entry
      await db.insert(
        'party',
        {
          'P_id': partyId,
          'Line_id': lineId,
          'P_Name': partyName,
          'P_phone': partyPhoneNumber,
          'P_Address': address,
        },
        conflictAlgorithm:
            ConflictAlgorithm.abort, // Use abort instead of replace
      );
    }
  }

  static Future<Map<String, dynamic>> getPartyById(
      String partyId, String lineId) async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'Party',
      where: 'P_id = ? AND Line_id = ?',
      whereArgs: [partyId, lineId],
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception('Party not found');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllParties() async {
    final db = await DatabaseHelper.getDatabase();
    return await db.query('party');
  }

  static Future<List<Map<String, dynamic>>> getPartiesByLineId(
      String lineId) async {
    final db = await DatabaseHelper.getDatabase();
    return await db.query(
      'party',
      where: 'Line_id = ?',
      whereArgs: [lineId],
    );
  }
}
