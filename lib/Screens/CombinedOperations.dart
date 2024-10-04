import 'package:sqflite/sqflite.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';

class CombinedOperations {
  static Future<List<Map<String, dynamic>>> getPartyAmounts() async {
    final db = await DatabaseHelper.getDatabase();

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        party.P_name AS partyName, 
        SUM(LentAmt.PayableAmt) AS amountToBePaid
      FROM 
        party
      INNER JOIN 
        Lending ON party.P_id = Lending.P_id
      INNER JOIN 
        LentAmt ON Lending.Len_id = LentAmt.Len_id
      GROUP BY 
        party.P_name
    ''');

    return result;
  }

  static Future<Map<String, dynamic>> getAmountToBePaidForLenId(
      String lenId) async {
    final db = await DatabaseHelper.getDatabase();

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        SUM(LentAmt.PayableAmt) AS amountToBePaid
      FROM 
        LentAmt
      WHERE 
        Len_id = ?
    ''', [lenId]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {'amountToBePaid': 0.0};
    }
  }
}
