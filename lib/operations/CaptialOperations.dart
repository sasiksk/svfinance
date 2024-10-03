import 'package:sqflite/sqflite.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';
import 'package:uuid/uuid.dart';

class CapitalOperations {
  // Insert a new record into the Capital table
  // Insert a new record into the Capital table
  static Future<bool> insertCapital({
    required String capitalId,
    required String dateOfParticulars,
    required double amountInvested,
    required String note,
  }) async {
    final db = await DatabaseHelper.getDatabase();
    final uuid = Uuid();

    try {
      await db.transaction((txn) async {
        await txn.insert(
          'Capital',
          {
            'Capital_id': capitalId,
            'Date_of_Particulars': dateOfParticulars,
            'Amt_Inv': amountInvested,
            'Note': note,
          },
          conflictAlgorithm: ConflictAlgorithm.abort,
        );

        final List<Map<String, dynamic>> existingEntries =
            await txn.query('Capital_Total');

        if (existingEntries.isEmpty) {
          await txn.insert(
            'Capital_Total',
            {
              'cTotal_id': uuid.v4().substring(0, 8),
              'cTotal_Amt_Inv': amountInvested,
              'cTotal_Amt_Rem': amountInvested,
            },
            conflictAlgorithm: ConflictAlgorithm.abort,
          );
        } else {
          final existingEntry = existingEntries.first;
          final newTotalAmtInv =
              existingEntry['cTotal_Amt_Inv'] + amountInvested;
          final newTotalAmtRem =
              existingEntry['cTotal_Amt_Rem'] + amountInvested;

          await txn.update(
            'Capital_Total',
            {
              'cTotal_Amt_Inv': newTotalAmtInv,
              'cTotal_Amt_Rem': newTotalAmtRem,
            },
            where: 'cTotal_id = ?',
            whereArgs: [existingEntry['cTotal_id']],
          );
        }
      });

      return true;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        return false;
      } else {
        throw e;
      }
    } catch (e) {
      throw e;
    }
  }

// Update an existing record in the Capital table
  static Future<bool> updateCapital({
    required String capitalId,
    required String dateOfParticulars,
    required double amountInvested,
    required String note,
  }) async {
    final db = await DatabaseHelper.getDatabase();

    try {
      await db.update(
        'Capital',
        {
          'Date_of_Particulars': dateOfParticulars,
          'Amt_Inv': amountInvested,
          'Note': note,
        },
        where: 'Capital_id = ?',
        whereArgs: [capitalId],
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  // Fetch total amounts from Capital_Total table
  static Future<Map<String, dynamic>> getTotalAmounts() async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> result = await db.query('Capital_Total');

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {
        'cTotal_Amt_Inv': 0.0,
        'cTotal_Amt_Rem': 0.0,
      };
    }
  }

  // Update an existing record in the Capital table
  // Update an existing record in the Capital table
}
