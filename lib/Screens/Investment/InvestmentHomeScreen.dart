import 'package:flutter/material.dart';
import 'package:svfinance/operations/InvestmentOperations.dart';
import 'package:svfinance/Screens/Investment_Screen.dart';

class InvestmentHomeScreen extends StatefulWidget {
  @override
  _InvestmentHomeScreenState createState() => _InvestmentHomeScreenState();
}

class _InvestmentHomeScreenState extends State<InvestmentHomeScreen> {
  late Future<Map<String, dynamic>> _investmentTotals;
  late Future<List<Map<String, dynamic>>> _investmentEntries;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _investmentTotals = InvestmentOperations.getInvestmentTotals();
    _investmentEntries = InvestmentOperations.getInvestmentEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investment Home Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: _investmentTotals,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final totals = snapshot.data!;
                  return Card(
                    child: ListTile(
                      title: Text('Total Invested: ${totals['inv_total']}'),
                      subtitle: Text('Remaining: ${totals['inv_remaining']}'),
                    ),
                  );
                }
              },
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _investmentEntries,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final entries = snapshot.data!;
                    return ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Card(
                          child: ListTile(
                            title: Text('Line Name: ${entry['Line_name']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Date of Investment: ${entry['Date_of_Investment']}'),
                                Text(
                                    'Amount Invested: ${entry['Amount_invested']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => InvestmentScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
