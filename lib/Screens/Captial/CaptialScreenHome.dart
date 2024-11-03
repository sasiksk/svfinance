import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:svfinance/Screens/Captial/CaptitalScreen2.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';
import 'package:svfinance/Screens/HomeScreen/BottomNavItem.dart';
import 'package:svfinance/Screens/HomeScreen/Card/EmptyDeatilCard.dart';
import 'package:svfinance/Screens/HomeScreen/NewHomeScreen.dart';
import 'package:svfinance/Screens/Homescreeen.dart';
import 'package:svfinance/Screens/Line/LineScreen.dart';
import 'package:svfinance/operations/CaptialOperations.dart';

class CapitalScreenHome extends StatefulWidget {
  @override
  _CapitalScreenHomeState createState() => _CapitalScreenHomeState();
}

class _CapitalScreenHomeState extends State<CapitalScreenHome> {
  Future<List<Map<String, dynamic>>>? capitalEntries;
  Future<Map<String, dynamic>>? totalAmounts;

  @override
  void initState() {
    super.initState();
    loadCapitalEntries();
    loadTotalAmounts();
  }

  void loadCapitalEntries() {
    setState(() {
      capitalEntries = DatabaseHelper.getTableData('Capital');
    });
  }

  void loadTotalAmounts() {
    setState(() {
      totalAmounts = CapitalOperations.getTotalAmounts();
    });
  }

  void _navigateToAddScreen() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => CapitalScreen(),
      ),
    )
        .then((_) {
      loadCapitalEntries(); // Refresh the list after adding new entry
      loadTotalAmounts(); // Refresh the total amounts after adding new entry
    });
  }

  void _navigateToUpdateScreen(Map<String, dynamic> entry) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => CapitalScreen(entry: entry),
      ),
    )
        .then((_) {
      loadCapitalEntries(); // Refresh the list after updating entry
      loadTotalAmounts(); // Refresh the total amounts after updating entry
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final cardHeight = mediaQuery.size.height * 0.15;
    final cardWidth = mediaQuery.size.width * 0.9;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Capital Screen'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<Map<String, dynamic>>(
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
                  return EmptyCard(
                    screenHeight: mediaQuery.size.height * 0.70,
                    screenWidth: mediaQuery.size.width,
                    title: 'Capital Investment',
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Invested:',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${totalData['cTotal_Amt_Inv']}',
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
                                  'Remaining:',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${totalData['cTotal_Amt_Rem']}',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: capitalEntries,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No entries available'));
                  } else {
                    final data = snapshot.data!;
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final entry = data[index];
                        return Card(
                          child: ListTile(
                            title:
                                Text('Date: ${entry['Date_of_Particulars']}'),
                            subtitle: Text('Amt Invested: ${entry['Amt_Inv']}'),
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _navigateToUpdateScreen(entry),
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
      bottomNavigationBar: SafeArea(
          child: BottomAppBar(
        color: const Color.fromARGB(255, 40, 65, 2),
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        height: screenWidth * 0.23,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              BottomNavItem(
                icon: FontAwesomeIcons.home,
                label: 'Home',
                destinationScreen: Newhomescreen(),
              ),
              BottomNavItem(
                icon: FontAwesomeIcons.coins,
                label: 'Add Capital Investment',
                destinationScreen: CapitalScreen(),
              ),
              BottomNavItem(
                icon: FontAwesomeIcons.print,
                label: 'Report',
                destinationScreen: Homescreen(),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
