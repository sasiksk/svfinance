import 'package:flutter/material.dart';
import 'package:svfinance/Screens/CollectionScreen.dart';
import 'package:svfinance/Screens/HomeScreen/Card/CustomAppBar.dart';
import 'package:svfinance/Screens/HomeScreen/Card/EmptyDeatilCard.dart';
import 'package:svfinance/Screens/HomeScreen/Card/LineCard.dart';
import 'package:svfinance/Screens/HomeScreen/Line/CollectionCard.dart';
import 'package:svfinance/Screens/HomeScreen/NewHomeScreen.dart';
import 'package:svfinance/Screens/LendingBasicDetailsScreen.dart';

import 'package:svfinance/operations/PartyOperations.dart';

class PartyDetailScreen extends StatefulWidget {
  final String partyId;

  PartyDetailScreen({required this.partyId});

  @override
  _PartyHomeScreenState createState() => _PartyHomeScreenState();
}

class _PartyHomeScreenState extends State<PartyDetailScreen> {
  Map<String, dynamic>? partyDetails;
  Map<String, dynamic>? lentAmtDetails;
  List<Map<String, dynamic>> collectionDetails = [];

  @override
  void initState() {
    super.initState();
    fetchPartyDetails();
  }

  Future<void> fetchPartyDetails() async {
    try {
      final details = await PartyOperations.getPartyByIdAlone(widget.partyId);
      setState(() {
        partyDetails = details;
      });

      if (details != null) {
        final lenId = await PartyOperations.getLenIdByPartyId(widget.partyId);
        if (lenId != null) {
          final lentDetails =
              await PartyOperations.getLentAmtDetailsByLenId(lenId);
          final collections =
              await PartyOperations.getCollectionDetailsByLenId(lenId);
          setState(() {
            lentAmtDetails = lentDetails;
            collectionDetails = collections;
          });
        }
      }
    } catch (e) {
      print('Error fetching party details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        title: partyDetails != null ? partyDetails!['P_Name'] : 'Loading...',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (partyDetails == null || lentAmtDetails == null)
              Center(child: CircularProgressIndicator())
            else
              EmptyCard(
                screenHeight: screenHeight *
                    0.85, // Set the height to 30% of the screen height
                screenWidth:
                    screenWidth, // Set the width to screen width minus 40 for padding
                title: 'Lent Amount Details',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount: ${lentAmtDetails!['TotalAmt']}',
                            style: TextStyle(color: Colors.white)),
                        Text('Paid Amount: ${lentAmtDetails!['PaidAmt']}',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payable Amount: ${lentAmtDetails!['PayableAmt']}',
                            style: TextStyle(color: Colors.white)),
                        Text(
                            'Days Remaining: ${lentAmtDetails!['DaysRemaining']}',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            SizedBox(height: 20),
            Text(
              'Collection Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 174, 204, 4),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: collectionDetails.length,
                itemBuilder: (context, index) {
                  final collection = collectionDetails[index];
                  return CollectionCard(
                    date: 'Date: ${collection['Date_of_Payment']}',
                    screenWidth: screenWidth,
                    amount: 'Amt: ${collection['Amt_Collected']}',
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Lending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections),
            label: 'Collection',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.print),
            label: 'Print',
          ),
        ],
        currentIndex: 0, // Set the initial selected index
        selectedItemColor: Colors.amber[800],
        backgroundColor: Colors.green, // Set the background color here
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Newhomescreen()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LendingBasicDetailsScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CollectionScreen()),
              );
              break;
            // Add cases for other navigation items if needed
          }
        },
      ),
    );
  }
}
