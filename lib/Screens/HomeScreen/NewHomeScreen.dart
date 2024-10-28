import 'package:flutter/material.dart';
import 'package:svfinance/Screens/HomeScreen/CapitalDetailsCard.dart';

import 'package:svfinance/Screens/Captial/CaptitalScreen2.dart';
import 'package:svfinance/Screens/HomeScreen/Card/LineCard.dart';
import 'package:svfinance/Screens/Homescreeen.dart';
import 'package:svfinance/Screens/Line/LineScreen.dart';
import 'package:svfinance/operations/Line_operations.dart';

class Newhomescreen extends StatefulWidget {
  @override
  State<Newhomescreen> createState() => _NewhomescreenState();
}

class _NewhomescreenState extends State<Newhomescreen> {
  String selectedLineName = '';

  void handleLineSelected(String lineName) {
    setState(() {
      selectedLineName = lineName;
    });
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
              CapitalDetailsCard(
                  screenHeight: screenHeight, screenWidth: screenWidth),
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
                        return LineCard(
                          lineName: line['Line_Name'],
                          screenWidth: screenWidth,
                          onLineSelected: handleLineSelected,
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
                  navigateTo(context, CapitalScreen());
                },
              ),
              IconButton(
                icon: Icon(Icons.line_axis, color: Colors.white),
                onPressed: () {
                  navigateTo(context, LineScreen());
                },
              ),
              IconButton(
                icon: Icon(Icons.print, color: Colors.white),
                onPressed: () {
                  navigateTo(context, Homescreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
