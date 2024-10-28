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
              'Lentamt': 0,
              'Returnamt': 0, // Set Returnamt to 0
              'profit': 0,
              'expense': 0, // Set expense to 0
              'totallineamt': 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } else {
          // Update the existing record
          final existingEntry = existingInvestmentTotalEntries.first;
          final newInvTotal = existingEntry['Inv_Total'] + amountInvested;
          final newInvRemaining = existingEntry['Inv_Remaing'] + amountInvested;
          final newTotalLineAmt =
              existingEntry['totallineamt'] + amountInvested;

          await txn.update(
            'InvestmentTotal',
            {
              'Inv_Total': newInvTotal,
              'Inv_Remaing': newInvRemaining,
              'totallineamt': newTotalLineAmt,
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

  static Future<Map<String, dynamic>> getInvestmentTotals() async {
    final db = await DatabaseHelper.getDatabase();
    final result = await db.rawQuery('''
    SELECT 
      SUM(Inv_Total) as inv_total, 
      SUM(Inv_Remaing) as inv_remaining 
    FROM InvestmentTotal
  ''');
    if (result.isNotEmpty) {
      return {
        'inv_total': result.first['inv_total'],
        'inv_remaining': result.first['inv_remaining'],
      };
    } else {
      return {
        'inv_total': 0,
        'inv_remaining': 0,
      };
    }
  }

  static Future<Map<String, List<Map<String, dynamic>>>>
      getGroupedInvestmentEntries() async {
    final db = await DatabaseHelper.getDatabase();
    final result = await db.rawQuery('''
    SELECT 
      InvestmentScreen.Line_id, 
      Line.Line_Name,
      InvestmentScreen.Date_of_Investment, 
      InvestmentScreen.Amount_invested,
      InvestmentTotal.Inv_Remaing
    FROM InvestmentScreen
    JOIN InvestmentTotal ON InvestmentScreen.Line_id = InvestmentTotal.Line_id
    JOIN Line ON InvestmentScreen.Line_id = Line.Line_id
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

  static Future<List<Map<String, dynamic>>> getInvestmentEntries() async {
    final db = await DatabaseHelper.getDatabase();
    final result = await db.query('InvestmentScreen');
    final List<Map<String, dynamic>> entries = result;

    for (var entry in entries) {
      final sumResult = await db.rawQuery('''
        SELECT SUM(Inv_Remaing) as sum_remaining
        FROM InvestmentTotal
        WHERE Line_id = ?
      ''', [entry['Line_id']]);
      if (sumResult.isNotEmpty) {
        entry['sum_remaining'] = sumResult.first['sum_remaining'];
      }
    }

    return entries;
  }
}
