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
      final double currentLentamt = investmentTotalEntry['Lentamt'];
      final double currentProfit = investmentTotalEntry['profit'];
      final double currentTotallineamt = investmentTotalEntry['totallineamt'];

      // Check if the remaining investment amount is sufficient
      if (invRemaining < amountLent) {
        throw Exception('Insufficient funds in the line.');
      }

      // Calculate new values
      final double newInvRemaining = invRemaining - amountLent;
      final double newLentamt = currentLentamt + amountLent;
      final double profit = totalAmountPayable - amountLent;
      final double newProfit = currentProfit + profit;
      final double newTotallineamt = newInvRemaining + newLentamt + newProfit;

      // Update the remaining investment amount and other values
      await txn.update(
        'InvestmentTotal',
        {
          'Inv_Remaing': newInvRemaining,
          'Lentamt': newLentamt,
          'profit': newProfit,
          'totallineamt': newTotallineamt,
        },
        where: 'InvtotalID = ?',
        whereArgs: [investmentTotalEntry['InvtotalID']],
      );

      // Check if the party's Len_id is NULL
      final List<Map<String, dynamic>> partyResult = await txn.query(
        'party',
        where: 'P_id = ? AND Len_id IS NULL',
        whereArgs: [partyId],
      );

      if (partyResult.isNotEmpty) {
        // Insert into Lending table
        await txn.insert(
          'Lending',
          {
            'Len_id': lendingId,
            'Line_id': lineId,
            'P_id': partyId,
            'Type': type,
            'Amt_lent': amountLent,
            'Total_Payable_amt': totalAmountPayable,
            'Profit': profit, // Include profit here
            'Due_length': dueLength,
            'Date_of_lent': dateOfLent,
            'Due_date': dueDate,
            'status': 'active', // Set status to active
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Update the party's Len_id
        await txn.update(
          'party',
          {'Len_id': lendingId},
          where: 'P_id = ?',
          whereArgs: [partyId],
        );
      } else {
        throw Exception('Party already has an active lending.');
      }

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

      // Insert the profit into the Profit table
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

  static Future<List<Map<String, dynamic>>> getLendingDetailsByLineId(
      String lineId) async {
    final db = await DatabaseHelper.getDatabase();
    return await db.rawQuery('''
      SELECT 
        p.P_Name AS Party_Name,
        l.Amt_lent,
        l.Total_Payable_amt,
        la.DaysRemaining
      FROM Lending l
      JOIN party p ON l.P_id = p.P_id
      JOIN LentAmt la ON l.Len_id = la.Len_id
      WHERE l.Line_id = ?
    ''', [lineId]);
  }

  static Future<List<Map<String, dynamic>>> getLendingDetailsByLineIdAndPartyId(
      String lineId, String partyId) async {
    final db = await DatabaseHelper.getDatabase();
    return await db.rawQuery('''
      SELECT 
        p.P_Name AS Party_Name,
        l.Amt_lent,
        l.Total_Payable_amt,
        la.DaysRemaining
      FROM Lending l
      JOIN party p ON l.P_id = p.P_id
      JOIN LentAmt la ON l.Len_id = la.Len_id
      WHERE l.Line_id = ? AND l.P_id = ?
    ''', [lineId, partyId]);
  }
}
