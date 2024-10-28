import 'package:sqflite/sqflite.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';

class CollectionOperations {
  static Future<void> insertCollection(String collectionId, String lendingId,
      String dateOfPayment, double amountCollected) async {
    final db = await DatabaseHelper.getDatabase();

    await db.transaction((txn) async {
      // Check if the status in the Lending table is 'active'
      final List<Map<String, dynamic>> lendingStatus = await txn.query(
        'Lending',
        columns: ['status', 'Line_id'],
        where: 'Len_id = ?',
        whereArgs: [lendingId],
      );

      if (lendingStatus.isNotEmpty &&
          lendingStatus.first['status'] == 'active') {
        final String lineId = lendingStatus.first['Line_id'];

        await txn.insert(
          'Collection',
          {
            'Collection_id': collectionId,
            'Len_id': lendingId,
            'Date_of_Payment': dateOfPayment, // Correct column name
            'Amt_Collected': amountCollected, // Correct column name
          },
        );

        // Update the LentAmt table
        await txn.rawUpdate('''
          UPDATE LentAmt
          SET PaidAmt = PaidAmt + ?,
              PayableAmt = PayableAmt - ?
          WHERE Len_id = ?
        ''', [amountCollected, amountCollected, lendingId]);

        // Check if PayableAmt is 0
        final List<Map<String, dynamic>> result = await txn.query(
          'LentAmt',
          columns: ['PayableAmt'],
          where: 'Len_id = ?',
          whereArgs: [lendingId],
        );

        if (result.isNotEmpty && result.first['PayableAmt'] == 0) {
          // Update status in Lending table to 'completed'
          await txn.rawUpdate('''
            UPDATE Lending
            SET status = 'completed'
            WHERE Len_id = ?
          ''', [lendingId]);

          // Set Len_id to NULL in party table
          await txn.rawUpdate('''
            UPDATE party
            SET Len_id = NULL
            WHERE P_id = (SELECT P_id FROM Lending WHERE Len_id = ?)
          ''', [lendingId]);
        }

        // Fetch returnamt and totallineamt from InvestmentTotal table
        final List<Map<String, dynamic>> investmentTotalResult =
            await txn.query(
          'InvestmentTotal',
          columns: ['Returnamt', 'totallineamt', 'Inv_Remaing'],
          where: 'Line_id = ?',
          whereArgs: [lineId],
        );

        try {
          if (investmentTotalResult.isNotEmpty) {
            final double returnamt =
                (investmentTotalResult.first['Returnamt']) as double;
            final double totallineamt =
                (investmentTotalResult.first['totallineamt']) as double;

            final double invRemaing =
                (investmentTotalResult.first['Inv_Remaing']) as double;

            // Update returnamt and totallineamt
            final double newReturnamt = returnamt + amountCollected;
            final double newTotallineamt = totallineamt - amountCollected;
            final double newInvRemaing =
                invRemaing + amountCollected; // Update Inv_Remaing

            print('Updating InvestmentTotal:');
            print('Returnamt: $newReturnamt');
            print('Totallineamt: $newTotallineamt');
            print('Inv_Remaing: $newInvRemaing');

            await txn.rawUpdate('''
               UPDATE InvestmentTotal
                SET Returnamt = ?,
                   totallineamt = ?,
                  Inv_Remaing = ? 
      WHERE Line_id = ?
    ''', [newReturnamt, newTotallineamt, newInvRemaing, lineId]);
          }
        } catch (e) {
          print('Error updating InvestmentTotal: $e');
          // Optionally, you can rethrow the error or handle it as needed
          throw Exception('Error updating InvestmentTotal: $e');
        }
      } else {
        throw Exception(
            'Cannot insert collection. Lending status is not active.');
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
