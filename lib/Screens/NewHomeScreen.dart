import 'package:flutter/material.dart';
import 'package:svfinance/Screens/Captial/CaptitalScreen2.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';
import 'package:svfinance/Screens/Homescreeen.dart';
import 'package:svfinance/Screens/Line/LineScreen.dart';
import 'package:svfinance/Screens/LineDetailScreen.dart';
import 'package:svfinance/operations/CaptialOperations.dart';
import 'package:svfinance/operations/Line_operations.dart';
// Import the new screen

class Newhomescreen extends StatefulWidget {
  @override
  State<Newhomescreen> createState() => _NewhomescreenState();
}

class _NewhomescreenState extends State<Newhomescreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _updateDaysRemaining();
    await _initializeDatabase();
  }

  Future<void> _updateDaysRemaining() async {
    try {
      print("Updating days remaining...");
      await DatabaseHelper.updateDaysRemaining();
      print("Days remaining updated successfully.");
    } catch (e) {
      print("Error updating days remaining: $e");
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      print("Initializing database...");
      await DatabaseHelper.getDatabase();
      // await DatabaseHelper.dropDatabase('finance.db');
      print("Database initialized successfully.");
    } catch (e) {
      print("Error initializing database: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Finance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 2, 128, 18),
        elevation: 20.0,
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20.0),
                height: screenHeight * 0.18, // 18% of screen height
                width: screenWidth -
                    40, // Full width minus padding (20 on each side)
                child: Card(
                  color: Colors.black54, // Light black background color
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0), // Rectangular box
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Capital Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // White text color
                          ),
                        ),
                        SizedBox(height: 10),
                        FutureBuilder<Map<String, dynamic>>(
                          future: CapitalOperations.getCapitalTotals(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(color: Colors.white),
                              );
                            } else if (snapshot.hasData) {
                              final data = snapshot.data!;
                              final totalAmtInvested = data['cTotal_Amt_Inv'];
                              final amtRemaining = data['cTotal_Amt_Rem'];
                              return Column(
                                children: [
                                  Text(
                                    'Total Amount Invested: \$${totalAmtInvested.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            Colors.white), // White text color
                                  ),
                                  Text(
                                    'Amount Remaining: \$${amtRemaining.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            Colors.white), // White text color
                                  ),
                                ],
                              );
                            } else {
                              return Text(
                                'No data available',
                                style: TextStyle(color: Colors.white),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Line List',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 174, 204, 4),
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: LineOperations.getAllLines(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white),
                    );
                  } else if (snapshot.hasData) {
                    final lines = snapshot.data!;
                    return Column(
                      children: lines.map((line) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LineDetailScreen(
                                    lineName: line['Line_Name']),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10.0),
                            width: screenWidth -
                                40, // Full width minus padding (20 on each side)
                            child: Card(
                              color: Colors
                                  .black54, // Light black background color
                              elevation: 8.0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(0), // Rectangular box
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  line['Line_Name'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // White text color
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return Text(
                      'No lines available',
                      style: TextStyle(color: Colors.white),
                    );
                  }
                },
              ),
            ],
          ),
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
                    onPressed: () {},
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.account_balance, color: Colors.white),
                onPressed: () {
                  // navigate to CapitalScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CapitalScreen()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.line_axis, color: Colors.white),
                onPressed: () {
                  //navigate to LineScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LineScreen()),
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
      ),
    );
  }
}
