import 'package:flutter/material.dart';
import 'package:svfinance/operations/Investmentoperations.dart';
import 'package:svfinance/Screens/Investment_Screen.dart';

class InvestmentHomeScreen extends StatefulWidget {
  @override
  _InvestmentHomeScreenState createState() => _InvestmentHomeScreenState();
}

class _InvestmentHomeScreenState extends State<InvestmentHomeScreen> {
  late Future<Map<String, dynamic>> _investmentTotals;
  late Future<Map<String, List<Map<String, dynamic>>>>
      _groupedInvestmentEntries;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _investmentTotals = InvestmentOperations.getInvestmentTotals();
    _groupedInvestmentEntries =
        InvestmentOperations.getGroupedInvestmentEntries();
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
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No data available');
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
              child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                future: _groupedInvestmentEntries,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No entries available');
                  } else {
                    final groupedEntries = snapshot.data!;
                    return ListView.builder(
                      itemCount: groupedEntries.keys.length,
                      itemBuilder: (context, index) {
                        final lineId = groupedEntries.keys.elementAt(index);
                        final investments = groupedEntries[lineId]!;
                        final lineName = investments.first['Line_Name'];
                        final totalInvested = investments.fold(
                            0.0,
                            (sum, item) =>
                                sum + (item['Amount_invested'] as double));
                        final remainingAmount = investments.fold(
                            0.0,
                            (sum, item) =>
                                sum + (item['Inv_Remaing'] as double));

                        return Card(
                          child: ExpansionTile(
                            title: Text('Line Name: $lineName (ID: $lineId)'),
                            children: [
                              ...investments.map((investment) {
                                return ListTile(
                                  title: Text(
                                      'Date of Investment: ${investment['Date_of_Investment']}'),
                                  subtitle: Text(
                                      'Amount Invested: ${investment['Amount_invested']}'),
                                );
                              }).toList(),
                              ListTile(
                                title: Text(
                                    'Total Amount Invested: $totalInvested'),
                                subtitle:
                                    Text('Remaining Amount: $remainingAmount'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            )
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
