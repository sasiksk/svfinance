import 'package:sqflite/sqflite.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';

class CollectionOperations {
  static Future<void> insertCollection(String collectionId, String lendingId,
      String dateOfPayment, double amountCollected) async {
    final db = await DatabaseHelper.getDatabase();

    // Check if the entry already exists
    final List<Map<String, dynamic>> existingEntries = await db.query(
      'Collection',
      where: 'Collection_id = ?',
      whereArgs: [collectionId],
    );

    if (existingEntries.isNotEmpty) {
      // Entry already exists
      throw Exception('Cannot insert: Collection ID already exists.');
    } else {
      // Insert the new entry
      await db.insert(
        'Collection',
        {
          'Collection_id': collectionId,
          'Len_id': lendingId,
          'Date_of_Payment': dateOfPayment,
          'Amt_Collected': amountCollected,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
