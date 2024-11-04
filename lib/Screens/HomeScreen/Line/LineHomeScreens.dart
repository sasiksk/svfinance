import 'package:flutter/material.dart';

import 'package:svfinance/Screens/HomeScreen/Card/EmptyDeatilCard.dart';
import 'package:svfinance/Screens/HomeScreen/Card/LineCard.dart';
import 'package:svfinance/Screens/HomeScreen/CustomAppBar.dart';
import 'package:svfinance/Screens/HomeScreen/CustomBottomNavigationBar2.dart';
import 'package:svfinance/Screens/HomeScreen/Line/PartyHomeScreen.dart';
import 'package:svfinance/Screens/HomeScreen/NewHomeScreen.dart';
import 'package:svfinance/Screens/Homescreeen.dart';
import 'package:svfinance/Screens/Investment/Investment_Screen.dart';
import 'package:svfinance/Screens/Party/PartyScreen.dart';
import 'package:svfinance/operations/Line_operations.dart';

class LineHomeScreen2 extends StatefulWidget {
  final String lineName;

  const LineHomeScreen2({super.key, required this.lineName});

  @override
  _LineHomeScreen2State createState() => _LineHomeScreen2State();
}

class _LineHomeScreen2State extends State<LineHomeScreen2> {
  String? lineId;
  Map<String, dynamic>? investmentDetails;
  List<Map<String, dynamic>> partyNames = [];
  bool isLoading = true;

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
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // print('Error fetching lineId or investment details: $e');
      setState(() {
        isLoading = false;
      });
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
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (investmentDetails == null)
              const Center(
                  child: Text('No investment details found for the line name'))
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
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('LentAmt: ${investmentDetails!['Lentamt']}'),
                        Text('Returnamt: ${investmentDetails!['Returnamt']}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Profit: ${investmentDetails!['profit']}'),
                        Text('Expense: ${investmentDetails!['expense']}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                        'Total Line Amt: ${investmentDetails!['totallineamt']}'),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Party List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 174, 204, 4),
              ),
            ),
            Expanded(
              child: partyNames.isEmpty
                  ? const Text(
                      'No Parties Found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                      ),
                    )
                  : ListView.builder(
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
      bottomNavigationBar: CustomBottomNavigationBar2(
        icons: const [
          Icons.home,
          Icons.line_axis_outlined,
          Icons.person_3_sharp,
          Icons.print,
        ],
        labels: const [
          'Home',
          'Add Investment',
          'Add Party',
          'Report',
        ],
        screens: [
          const Newhomescreen(),
          InvestmentScreen(),
          PartyScreen(),
          Homescreen(),
        ],
      ),
    );
  }
}
