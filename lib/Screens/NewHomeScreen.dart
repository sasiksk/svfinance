import 'package:flutter/material.dart';
import 'package:svfinance/Screens/Homescreeen.dart';

import 'package:svfinance/operations/CaptialOperations.dart';

class Newhomescreen extends StatelessWidget {
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
        child: Container(
          margin: EdgeInsets.only(top: 20.0),
          height: screenHeight * 0.15, // 15% of screen height
          width: screenWidth - 40, // Full width minus padding (20 on each side)
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
                  SizedBox(height: 02),
                  FutureBuilder<Map<String, dynamic>>(
                    future: CapitalOperations.getCapitalTotals(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                                  color: Colors.white), // White text color
                            ),
                            Text(
                              'Amount Remaining: \$${amtRemaining.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white), // White text color
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
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 40, 65, 2),
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                // Handle home button press
              },
            ),
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                // Handle search button press
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                // Handle notifications button press
              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.white),
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
    );
  }
}
