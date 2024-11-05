import 'package:flutter/material.dart';
import 'package:svfinance/Screens/LendingBasicDetailsScreen.dart';
import 'package:svfinance/operations/LendingOperations.dart';
import 'package:svfinance/MainScreens/Line/Line_operations.dart';

class LendingHomeScreen extends StatefulWidget {
  @override
  _LendingHomeScreenState createState() => _LendingHomeScreenState();
}

class _LendingHomeScreenState extends State<LendingHomeScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedLineId;
  List<Map<String, dynamic>> _lines = [];
  Map<String, List<Map<String, dynamic>>> _groupedPartyDetails = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLines();
  }

  Future<void> _fetchLines() async {
    setState(() {
      _isLoading = true;
    });
    final lines = await LineOperations.getAllLines();
    setState(() {
      _lines = lines;
      _isLoading = false;
    });
  }

  Future<void> _fetchPartyDetails(String lineId) async {
    setState(() {
      _isLoading = true;
    });
    final partyDetails =
        await LendingOperations.getLendingDetailsByLineId(lineId);
    _groupedPartyDetails = _groupByLineName(partyDetails);
    setState(() {
      _isLoading = false;
    });
  }

  Map<String, List<Map<String, dynamic>>> _groupByLineName(
      List<Map<String, dynamic>> partyDetails) {
    final Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var detail in partyDetails) {
      final lineName = detail['Line_Name'];
      if (lineName != null) {
        // Check for null values
        if (!groupedData.containsKey(lineName)) {
          groupedData[lineName] = [];
        }
        groupedData[lineName]!.add(detail);
      }
    }
    return groupedData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lending Home'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_lines.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Select Line',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: _selectedLineId,
                          hint: Text('Select Line'),
                          items: _lines.map((line) {
                            return DropdownMenuItem<String>(
                              value: line['Line_id'],
                              child: Text(line['Line_Name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLineId = value;
                              _fetchPartyDetails(value!);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView(
                    children: _groupedPartyDetails.entries.map((entry) {
                      final lineName = entry.key;
                      final partyDetails = entry.value;
                      return ExpansionTile(
                        title: Text(lineName),
                        children: partyDetails.map((party) {
                          return ListTile(
                            title: Text(party['Party_Name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Amount Lent: ${party['Amt_lent']}'),
                                Text(
                                    'Total Amount Payable: ${party['Total_Payable_amt']}'),
                                Text(
                                    'Days Remaining: ${party['DaysRemaining']}'),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LendingBasicDetailsScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
