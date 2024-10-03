import 'package:flutter/material.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String selectedTable = 'Capital';
  Future<List<Map<String, dynamic>>>? tableData;

  @override
  void initState() {
    super.initState();
    loadTableData();
  }

  void loadTableData() {
    setState(() {
      tableData = DatabaseHelper.getTableData(selectedTable);
    });
  }

  Future<void> deleteEntry(
      String tableName, String primaryKeyColumn, String id) async {
    await DatabaseHelper.deleteEntry(tableName, primaryKeyColumn, id);
    loadTableData();
  }

  void showDeleteConfirmationDialog(
      String tableName, String primaryKeyColumn, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Entry'),
          content: Text('Are you sure you want to delete this entry?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                deleteEntry(tableName, primaryKeyColumn, id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String getPrimaryKeyColumn(String tableName) {
    switch (tableName) {
      case 'Capital':
        return 'Capital_id';
      case 'Line':
        return 'Line_id';
      case 'Party':
        return 'P_id';
      case 'InvestmentScreen':
        return 'Inv_id';
      case 'Lending':
        return 'Len_id';
      case 'Collection':
        return 'Collection_id';
      case 'Capital_Total':
        return 'cTotal_id';
      case 'InvestmentTotal':
        return 'InvtotalID';
      case 'LentAmt':
        return 'Len_id';
      case 'Profit':
        return 'Len_id';

      default:
        return 'id';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report Screen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedTable,
            items: <String>[
              'Capital',
              'Line',
              'Party',
              'InvestmentScreen',
              'Lending',
              'Collection',
              'Capital_Total',
              'InvestmentTotal',
              'LentAmt',
              'Profit',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedTable = newValue!;
                loadTableData();
              });
            },
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: tableData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                } else {
                  final data = snapshot.data!;
                  final columns = data.first.keys.toList();
                  final primaryKeyColumn = getPrimaryKeyColumn(selectedTable);
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: columns
                            .map((column) => DataColumn(label: Text(column)))
                            .toList()
                          ..add(DataColumn(label: Text('Actions'))),
                        rows: data
                            .map((row) => DataRow(
                                  cells: columns
                                      .map((column) => DataCell(
                                            Text(row[column].toString()),
                                          ))
                                      .toList()
                                    ..add(DataCell(
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          showDeleteConfirmationDialog(
                                              selectedTable,
                                              primaryKeyColumn,
                                              row[primaryKeyColumn]);
                                        },
                                      ),
                                    )),
                                ))
                            .toList(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
