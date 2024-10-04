import 'package:flutter/material.dart';
import 'package:svfinance/Screens/CollectionScreen.dart';
import 'package:svfinance/Screens/CombinedOperations.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';
import 'package:svfinance/operations/CollectionOperations.dart';

class CollectionScreenHome extends StatefulWidget {
  @override
  _CollectionScreenHomeState createState() => _CollectionScreenHomeState();
}

class _CollectionScreenHomeState extends State<CollectionScreenHome> {
  Future<Map<String, double>>? totalAmounts;
  Future<List<Map<String, dynamic>>>? partyAmounts;

  @override
  void initState() {
    super.initState();
    loadTotalAmounts();
    loadPartyAmounts();
  }

  void loadTotalAmounts() {
    setState(() {
      totalAmounts = CollectionOperations.getTotalAmounts();
    });
  }

  void loadPartyAmounts() {
    setState(() {
      partyAmounts = CombinedOperations.getPartyAmounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final cardHeight = mediaQuery.size.height * 0.25; // Adjusted height
    final cardWidth = mediaQuery.size.width * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: Text('Collection Screen'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<Map<String, double>>(
              future: totalAmounts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No data available'));
                } else {
                  final totalData = snapshot.data!;
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      height: cardHeight,
                      width: cardWidth,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Collection Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Given Amount:',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '₹${totalData['givenAmount']}',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Collected Amount:',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '₹${totalData['collectedAmount']}',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Handle view report action
                              },
                              icon: Icon(Icons.report),
                              label: Text('View Report'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: partyAmounts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No parties available'));
                  } else {
                    final data = snapshot.data!;
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final entry = data[index];
                        return Card(
                          child: ListTile(
                            title: Text('Party Name: ${entry['partyName']}'),
                            trailing: Text('₹${entry['amountToBePaid']}'),
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
    );
  }
}
