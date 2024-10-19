import 'package:flutter/material.dart';
import 'package:svfinance/Screens/LendingBasicDetailsScreen.dart';
import 'package:svfinance/operations/LendingOperations.dart';
import 'package:svfinance/operations/Line_operations.dart';

class LendingHomeScreen extends StatefulWidget {
  @override
  _LendingHomeScreenState createState() => _LendingHomeScreenState();
}

class _LendingHomeScreenState extends State<LendingHomeScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedLineId;
  List<Map<String, dynamic>> _lines = [];
  List<Map<String, dynamic>> _partyDetails = [];
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
    setState(() {
      _partyDetails = partyDetails;
      _isLoading = false;
    });
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
                SizedBox(height: 20),
                if (_partyDetails.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _partyDetails.length,
                      itemBuilder: (context, index) {
                        final party = _partyDetails[index];
                        return ListTile(
                          title: Text(party['Party_Name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Amount Lent: ${party['Amt_lent']}'),
                              Text(
                                  'Total Amount Payable: ${party['Total_Payable_amt']}'),
                              Text('Days Remaining: ${party['DaysRemaining']}'),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                else if (_selectedLineId != null)
                  Center(child: Text('No parties found for the selected line')),
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
