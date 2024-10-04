import 'package:sqflite/sqflite.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';

class LendingOperations {
  static Future<void> insertLending(
      String lendingId,
      String lineId,
      String partyId,
      String type,
      double amountLent,
      double totalAmountPayable,
      String dateOfLent,
      int dueLength,
      String dueDate) async {
    final db = await DatabaseHelper.getDatabase();

    await db.transaction((txn) async {
      // Check if the entry already exists
      final List<Map<String, dynamic>> existingEntries = await txn.query(
        'Lending',
        where: 'Len_id = ?',
        whereArgs: [lendingId],
      );

      if (existingEntries.isNotEmpty) {
        // Entry already exists
        throw Exception('Cannot insert: Lending ID already exists.');
      }

      // Get the remaining investment amount for the corresponding line ID
      final List<Map<String, dynamic>> investmentTotalEntries = await txn.query(
        'InvestmentTotal',
        where: 'Line_id = ?',
        whereArgs: [lineId],
      );

      if (investmentTotalEntries.isEmpty) {
        throw Exception('No investment found for the selected line.');
      }

      final investmentTotalEntry = investmentTotalEntries.first;
      final double invRemaining = investmentTotalEntry['Inv_Remaing'];

      // Check if the remaining investment amount is sufficient
      if (invRemaining < amountLent) {
        throw Exception('Insufficient funds in the line.');
      }

      // Update the remaining investment amount
      final double newInvRemaining = invRemaining - amountLent;
      await txn.update(
        'InvestmentTotal',
        {'Inv_Remaing': newInvRemaining},
        where: 'InvtotalID = ?',
        whereArgs: [investmentTotalEntry['InvtotalID']],
      );

      // Insert the new lending entry
      await txn.insert(
        'Lending',
        {
          'Len_id': lendingId,
          'Line_id': lineId,
          'P_id': partyId,
          'Type': type,
          'Amt_lent': amountLent,
          'Total_Payable_amt': totalAmountPayable,
          'Due_length': dueLength,
          'Date_of_lent': dateOfLent,
          'Due_date': dueDate,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert the corresponding entry into the LentAmt table
      await txn.insert(
        'LentAmt',
        {
          'Len_id': lendingId,
          'TotalAmt': totalAmountPayable,
          'PaidAmt': 0.0,
          'PayableAmt': totalAmountPayable,
          'DaysRemaining': dueLength,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Calculate profit and insert into the Profit table
      final double profit = totalAmountPayable - amountLent;
      await txn.insert(
        'Profit',
        {
          'Len_id': lendingId,
          'Profit': profit,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  static Future<List<Map<String, dynamic>>> getAllLendings() async {
    final db = await DatabaseHelper.getDatabase();
    return await db.query('Lending');
  }

  static Future<void> updateDaysRemaining() async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> lentAmtEntries = await db.query('LentAmt');

    for (var entry in lentAmtEntries) {
      final dueDateStr = entry['Due_date'];
      if (dueDateStr != null) {
        final dueDate = DateTime.parse(dueDateStr);
        final today = DateTime.now();
        final daysRemaining = dueDate.difference(today).inDays;

        await db.update(
          'LentAmt',
          {'DaysRemaining': daysRemaining},
          where: 'Len_id = ?',
          whereArgs: [entry['Len_id']],
        );
      }
    }
  }
}
