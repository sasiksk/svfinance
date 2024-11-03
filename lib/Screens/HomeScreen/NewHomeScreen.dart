import 'package:flutter/material.dart';
import 'package:svfinance/Screens/Captial/CaptialScreenHome.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';
import 'package:svfinance/Screens/HomeScreen/BottomNavItem.dart';
import 'package:svfinance/Screens/HomeScreen/CapitalDetailsCard.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _updateDaysRemaining();
  }

  void handleLineSelected(String lineName) {
    setState(() {
      selectedLineName = lineName;
    });
  }

  void navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
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
      //await DatabaseHelper.dropDatabase('finance.db');
      print("Database initialized successfully.");
    } catch (e) {
      print("Error initializing database: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
              const SizedBox(height: 20),
              const Text(
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
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
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
                    return const Text(
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
                label: 'Capital',
                destinationScreen: CapitalScreenHome(),
              ),
              BottomNavItem(
                icon: FontAwesomeIcons.chartLine,
                label: 'Line',
                destinationScreen: LineScreen(),
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
