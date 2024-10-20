import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DatabaseHelper {
  static Future<sql.Database> getDatabase() async {
    // Get the database path
    final dbPath = await sql.getDatabasesPath();

    // Open the database
    final db = await sql.openDatabase(
      path.join(dbPath, 'finance.db'),
      version: 1,
      onCreate: (db, version) async {
        var batch = db.batch();

        // Create tables
        batch.execute('''
          CREATE TABLE Capital (
            Capital_id TEXT PRIMARY KEY,
            Date_of_Particulars DATE,
            Amt_Inv REAL,
            Note TEXT
          )
        ''');
        batch.execute('''
          CREATE TABLE Capital_Total (
            cTotal_id TEXT PRIMARY KEY,
            cTotal_Amt_Inv REAL DEFAULT 0,
            cTotal_Amt_Rem REAL DEFAULT 0
          )
        ''');

        batch.execute('''
          CREATE TABLE Line (
            Line_id TEXT PRIMARY KEY,
            Line_Name TEXT
          )
        ''');

        batch.execute('''
          CREATE TABLE InvestmentScreen (
            Inv_id TEXT PRIMARY KEY,
            Line_id TEXT,
            Date_of_Investment DATE,
            Amount_invested REAL,
            FOREIGN KEY (Line_id) REFERENCES Line(Line_id)
          )
        ''');

        batch.execute('''
          CREATE TABLE InvestmentTotal (
            InvtotalID TEXT PRIMARY KEY,
            Line_id TEXT,
            Inv_Total REAL DEFAULT 0,
            Inv_Remaing REAL,
            Lentamt REAL,
            profit REAL,
            totallineamt REAL,
            FOREIGN KEY (Line_id) REFERENCES Line(Line_id)
          )
        ''');

        batch.execute('''
          CREATE TABLE party (
            P_id TEXT,
            Line_id TEXT,
            P_Name TEXT,
            P_phone TEXT,
            P_Address TEXT,
            PRIMARY KEY (P_id, Line_id),
            FOREIGN KEY (Line_id) REFERENCES Line(Line_id)
          )
        ''');

        batch.execute('''
          CREATE TABLE Lending (
            Len_id TEXT PRIMARY KEY,
            Line_id TEXT,
            P_id TEXT,
            Type TEXT,
            Amt_lent REAL,
            Total_Payable_amt REAL,
            Profit REAL,
            Due_length INTEGER,
            Date_of_lent DATE,
            Due_date DATE,
            FOREIGN KEY (Line_id) REFERENCES Line(Line_id),
            FOREIGN KEY (P_id) REFERENCES party(P_id)
          )
        ''');

        batch.execute('''
          CREATE TABLE LentAmt (
            Len_id TEXT PRIMARY KEY,
            TotalAmt REAL,
            PaidAmt REAL,
            PayableAmt REAL,
            DaysRemaining INTEGER,
            FOREIGN KEY (Len_id) REFERENCES Lending(Len_id)
          )
        ''');

        batch.execute('''
          CREATE TABLE Collection (
            Collection_id TEXT PRIMARY KEY,
            Len_id TEXT,
            Date_of_Payment DATE,
            Amt_Collected REAL,
            FOREIGN KEY (Len_id) REFERENCES Lending(Len_id)
          )
        ''');

        batch.execute('''
          CREATE TABLE Initial_Daily_Report (
            Initial_Dreport_id TEXT PRIMARY KEY,
            Date_of_particulars DATE,
            Cash_in_hand REAL,
            Hand_Digi_cash REAL
          )
        ''');
        batch.execute('''
          CREATE TABLE Profit (
            Len_id TEXT PRIMARY KEY,
            Profit REAL,
            FOREIGN KEY (Len_id) REFERENCES Lending(Len_id)
          )
        ''');
        batch.execute('''
          CREATE TABLE Final_Daily_report (
            Final_Dreport_id TEXT PRIMARY KEY,
            Date_report TEXT,
            Line_id TEXT,
            Amount_Credited REAL,
            Amount_Debited REAL,
            Profit REAL,
            Expense REAL,
            Amount_in_Hand_Final REAL,
            Digi_Balance REAL,
            FOREIGN KEY (Line_id) REFERENCES Line(Line_id)
          )
        ''');

        await batch.commit();
      },
    );

    print('Database created successfully');
    return db;
  }

  // Drop the database
  static Future<void> dropDatabase(String dbName) async {
    final databasesPath = await sql.getDatabasesPath();
    final pathToDelete = path.join(databasesPath, dbName);
    await sql.deleteDatabase(pathToDelete);
    print('Database deleted successfully');
  }

  static Future<List<Map<String, dynamic>>> getTableData(
      String tableName) async {
    final db = await getDatabase();
    return await db.query(tableName);
  }

  static Future<void> deleteEntry(
      String tableName, String primaryKeyColumn, String id) async {
    final db = await getDatabase();
    await db.delete(tableName, where: '$primaryKeyColumn = ?', whereArgs: [id]);
  }

  static Future<void> updateEntry(
      String tableName, Map<String, dynamic> entryData, String id) async {
    final db = await getDatabase();
    await db.update(tableName, entryData, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> insertEntry(
      String tableName, Map<String, dynamic> entryData) async {
    final db = await getDatabase();
    await db.insert(tableName, entryData);
  }

  static Future<void> updateDaysRemaining() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> lentAmtEntries = await db.query('LentAmt');

    for (var entry in lentAmtEntries) {
      final lenId = entry['Len_id'];
      if (lenId != null) {
        final lendingEntry = await db.query(
          'Lending',
          where: 'Len_id = ?',
          whereArgs: [lenId],
        );

        if (lendingEntry.isNotEmpty) {
          final dueDateStr = lendingEntry.first['Due_date'];
          if (dueDateStr != null) {
            try {
              final dueDate = DateTime.parse(dueDateStr as String);
              final today = DateTime.now();
              final daysRemaining = dueDate.difference(today).inDays;

              await db.update(
                'LentAmt',
                {'DaysRemaining': daysRemaining},
                where: 'Len_id = ?',
                whereArgs: [lenId],
              );
            } catch (e) {
              print('Error updating days remaining: $e');
            }
          }
        }
      }
    }
  }
}
