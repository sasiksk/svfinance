import 'package:sqflite/sqflite.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';

class CollectionOperations {
  static Future<void> insertCollection(String collectionId, String lendingId,
      String dateOfPayment, double amountCollected) async {
    final db = await DatabaseHelper.getDatabase();

    await db.transaction((txn) async {
      // Check if the entry already exists
      final List<Map<String, dynamic>> existingEntries = await txn.query(
        'Collection',
        where: 'Collection_id = ?',
        whereArgs: [collectionId],
      );

      if (existingEntries.isNotEmpty) {
        // Entry already exists
        throw Exception('Cannot insert: Collection ID already exists.');
      } else {
        // Insert the new entry
        await txn.insert(
          'Collection',
          {
            'Collection_id': collectionId,
            'Len_id': lendingId,
            'Date_of_Payment': dateOfPayment,
            'Amt_Collected': amountCollected,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Update the LentAmt table
        await txn.rawUpdate('''
          UPDATE LentAmt
          SET PaidAmt = PaidAmt + ?,
              PayableAmt = PayableAmt - ?
          WHERE Len_id = ?
        ''', [amountCollected, amountCollected, lendingId]);
      }
    });
  }

  static Future<Map<String, double>> getTotalAmounts() async {
    final db = await DatabaseHelper.getDatabase();

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        SUM(PayableAmt) as givenAmount, 
        SUM(PaidAmt) as collectedAmount 
      FROM LentAmt
    ''');

    if (result.isNotEmpty) {
      return {
        'givenAmount': result.first['givenAmount'] ?? 0.0,
        'collectedAmount': result.first['collectedAmount'] ?? 0.0,
      };
    } else {
      return {
        'givenAmount': 0.0,
        'collectedAmount': 0.0,
      };
    }
  }
}
