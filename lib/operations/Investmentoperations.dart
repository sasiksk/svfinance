import 'package:sqflite/sqflite.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';

class InvestmentOperations {
  static Future<void> insertInvestment(String invId, String lineId,
      String dateOfInvestment, double amountInvested) async {
    final db = await DatabaseHelper.getDatabase();

    // Start a transaction
    await db.transaction((txn) async {
      // Check if the entry already exists
      final List<Map<String, dynamic>> existingEntries = await txn.query(
        'InvestmentScreen',
        where: 'Inv_id = ?',
        whereArgs: [invId],
      );

      if (existingEntries.isNotEmpty) {
        // Entry already exists
        throw Exception('Cannot insert: Investment ID already exists.');
      } else {
        // Insert the new entry into InvestmentScreen
        await txn.insert(
          'InvestmentScreen',
          {
            'Inv_id': invId,
            'Line_id': lineId,
            'Date_of_Investment': dateOfInvestment,
            'Amount_invested': amountInvested,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Check if there are existing entries in InvestmentTotal for the line
        final List<Map<String, dynamic>> existingInvestmentTotalEntries =
            await txn.query(
          'InvestmentTotal',
          where: 'Line_id = ?',
          whereArgs: [lineId],
        );

        if (existingInvestmentTotalEntries.isEmpty) {
          // First entry for the line, insert a new record
          await txn.insert(
            'InvestmentTotal',
            {
              'InvtotalID': lineId,
              'Line_id': lineId,
              'Inv_Total': amountInvested,
              'Inv_Remaing': amountInvested,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } else {
          // Update the existing record
          final existingEntry = existingInvestmentTotalEntries.first;
          final newInvTotal = existingEntry['Inv_Total'] + amountInvested;
          final newInvRemaining = existingEntry['Inv_Remaing'] + amountInvested;

          await txn.update(
            'InvestmentTotal',
            {
              'Inv_Total': newInvTotal,
              'Inv_Remaing': newInvRemaining,
            },
            where: 'InvtotalID = ?',
            whereArgs: [existingEntry['InvtotalID']],
          );
        }

        // Update the Capital_Total table
        final List<Map<String, dynamic>> capitalTotalEntries =
            await txn.query('Capital_Total');

        if (capitalTotalEntries.isNotEmpty) {
          final capitalTotalEntry = capitalTotalEntries.first;
          final newCapitalTotalAmtRem =
              capitalTotalEntry['cTotal_Amt_Rem'] - amountInvested;

          await txn.update(
            'Capital_Total',
            {
              'cTotal_Amt_Rem': newCapitalTotalAmtRem,
            },
            where: 'cTotal_id = ?',
            whereArgs: [capitalTotalEntry['cTotal_id']],
          );
        }
      }
    });
  }
}
