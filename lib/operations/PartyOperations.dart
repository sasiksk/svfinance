import 'package:sqflite/sqflite.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';

class PartyOperations {
  static Future<void> insertParty(String partyId, String lineId,
      String partyName, String partyPhoneNumber, String address) async {
    final db = await DatabaseHelper.getDatabase();
    await db.insert(
      'party',
      {
        'P_id': partyId,
        'Line_id': lineId,
        'P_Name': partyName,
        'P_phone': partyPhoneNumber,
        'P_Address': address,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, List<Map<String, dynamic>>>>
      getGroupedPartyEntries() async {
    final db = await DatabaseHelper.getDatabase();
    final result = await db.rawQuery('''
    SELECT 
      party.Line_id, 
      Line.Line_Name,
      party.P_Name, 
      party.P_phone,
      party.P_Address,
      party.P_id
    FROM party
    JOIN Line ON party.Line_id = Line.Line_id
  ''');

    final Map<String, List<Map<String, dynamic>>> groupedEntries = {};

    for (var entry in result) {
      final String lineId =
          entry['Line_id'].toString(); // Ensure lineId is a String
      if (!groupedEntries.containsKey(lineId)) {
        groupedEntries[lineId] = [];
      }
      groupedEntries[lineId]!.add(Map<String, dynamic>.from(
          entry)); // Ensure entry is a Map<String, dynamic>
    }

    return groupedEntries;
  }

  static Future<void> updateParty(String partyId, String lineId,
      String partyName, String partyPhoneNumber, String address) async {
    final db = await DatabaseHelper.getDatabase();
    await db.update(
      'party',
      {
        'P_Name': partyName,
        'P_phone': partyPhoneNumber,
        'P_Address': address,
      },
      where: 'P_id = ? AND Line_id = ?',
      whereArgs: [partyId, lineId],
    );
  }

  static Future<void> deleteParty(String partyId, String lineId) async {
    final db = await DatabaseHelper.getDatabase();
    await db.delete(
      'party',
      where: 'P_id = ? AND Line_id = ?',
      whereArgs: [partyId, lineId],
    );
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

  static Future<Map<String, dynamic>?> getPartyByIdAlone(String partyId) async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'party',
      where: 'P_id = ?',
      whereArgs: [partyId],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
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

  static Future<String?> getLenIdByPartyId(String partyId) async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'party',
      columns: ['Len_id'],
      where: 'P_id = ?',
      whereArgs: [partyId],
    );

    if (result.isNotEmpty) {
      return result.first['Len_id'] as String?;
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getLentAmtDetailsByLenId(
      String lenId) async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'LentAmt',
      where: 'Len_id = ?',
      whereArgs: [lenId],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getCollectionDetailsByLenId(
      String lenId) async {
    final db = await DatabaseHelper.getDatabase();
    return db.query(
      'Collection',
      where: 'Len_id = ?',
      whereArgs: [lenId],
    );
  }
}
