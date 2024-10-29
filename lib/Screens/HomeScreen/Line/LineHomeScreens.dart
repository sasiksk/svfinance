import 'package:flutter/material.dart';
import 'package:svfinance/Screens/HomeScreen/Card/CustomAppBar.dart';
import 'package:svfinance/Screens/HomeScreen/Card/EmptyDeatilCard.dart';
import 'package:svfinance/Screens/HomeScreen/Card/LineCard.dart';

import 'package:svfinance/Screens/HomeScreen/Line/PartyHomeScreen.dart';
import 'package:svfinance/Screens/HomeScreen/NewHomeScreen.dart';
import 'package:svfinance/Screens/Homescreeen.dart';
import 'package:svfinance/Screens/Investment/Investment_Screen.dart';
import 'package:svfinance/Screens/Party/PartyScreen.dart';
import 'package:svfinance/operations/Line_operations.dart';
// Import PartyScreen

class LineHomeScreen2 extends StatefulWidget {
  final String lineName;

  LineHomeScreen2({required this.lineName});

  @override
  _LineHomeScreen2State createState() => _LineHomeScreen2State();
}

class _LineHomeScreen2State extends State<LineHomeScreen2> {
  String? lineId;
  Map<String, dynamic>? investmentDetails;
  List<Map<String, dynamic>> partyNames = [];

  @override
  void initState() {
    super.initState();
    fetchLineIdAndDetails();
  }

  Future<void> fetchLineIdAndDetails() async {
    try {
      final result = await LineOperations.getLineIdByName(widget.lineName);
      setState(() {
        lineId = result;
      });

      if (lineId != null) {
        final details =
            await LineOperations.getInvestmentDetailsByLineId(lineId!);
        final parties = await LineOperations.getPartyNamesByLineId(lineId!);
        setState(() {
          investmentDetails = details;
          partyNames = parties;
        });
      }
    } catch (e) {
      print('Error fetching lineId or investment details: $e');
    }
  }

  void onPartySelected(String partyName) async {
    final partyId = await LineOperations.getPartyIdByName(partyName);
    if (partyId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PartyDetailScreen(partyId: partyId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.lineName,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (investmentDetails == null)
              Center(child: CircularProgressIndicator())
            else
              EmptyCard(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                title: 'Line-Id : $lineId',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Invested: ${investmentDetails!['Inv_Total']}'),
                        Text('Remaining: ${investmentDetails!['Inv_Remaing']}'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('LentAmt: ${investmentDetails!['Lentamt']}'),
                        Text('Returnamt: ${investmentDetails!['Returnamt']}'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Profit: ${investmentDetails!['profit']}'),
                        Text('Expense: ${investmentDetails!['expense']}'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                        'Total Line Amt: ${investmentDetails!['totallineamt']}'),
                  ],
                ),
              ),
            SizedBox(height: 20),
            Text(
              'Party List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 174, 204, 4),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: partyNames.length,
                itemBuilder: (context, index) {
                  return LineCard(
                    lineName: partyNames[index]['P_Name'],
                    screenWidth: screenWidth,
                    onLineSelected: onPartySelected,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 40, 65, 2),
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Container(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.home, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Newhomescreen()),
                      );
                    },
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.line_axis_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InvestmentScreen()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.person_3_sharp, color: Colors.white),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PartyScreen()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.print, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Homescreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ), // Revert to the old BottomNavigationBar
    );
  }
}
