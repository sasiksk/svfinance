import 'package:flutter/material.dart';
import 'package:svfinance/Screens/CollectionScreen.dart';

import 'package:svfinance/Screens/HomeScreen/Card/EmptyDeatilCard.dart';
import 'package:svfinance/Screens/HomeScreen/CustomAppBar.dart';
import 'package:svfinance/Screens/HomeScreen/CustomBottomNavigationBar2.dart';
import 'package:svfinance/Screens/HomeScreen/Line/CollectionCard.dart';
import 'package:svfinance/Screens/HomeScreen/NewHomeScreen.dart';
import 'package:svfinance/Screens/Homescreeen.dart';
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
        actions: [],
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
                    SizedBox(height: 20),
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
            const SizedBox(height: 20),
            const Text(
              'Collection Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 19, 22, 1),
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
      bottomNavigationBar: CustomBottomNavigationBar2(
        icons: const [
          Icons.home,
          Icons.monetization_on,
          Icons.payment,
          Icons.print,
        ],
        labels: const [
          'Home',
          'Lending',
          'Collection',
          'Print',
        ],
        screens: [
          const Newhomescreen(),
          LendingBasicDetailsScreen(),
          CollectionScreen(),
          Homescreen(),
        ],
      ),
    );
  }
}
