import 'package:flutter/material.dart';
import 'package:svfinance/MainScreens/Captial/CaptialScreenHome.dart';
import 'package:svfinance/Screens/CollectionScreen.dart';
import 'package:svfinance/Screens/DailyReportScreen.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';
import 'package:svfinance/Screens/Investment/InvestmentHomeScreen.dart';
import 'package:svfinance/Screens/CollectionScreen3.dart';
import 'package:svfinance/Screens/LendingHomeScreen.dart';
import 'package:svfinance/Screens/Line/LineScreenHome.dart';

import 'package:svfinance/Screens/Party/PartyHomeScreen.dart';
import 'package:svfinance/Screens/reportScreen.dart';

class Homescreen extends StatefulWidget {
  Homescreen({super.key});

  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
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

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home Screen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 56, 90, 243),
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 80, 52, 1),
              Color.fromARGB(255, 247, 188, 111)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 195, 91, 209),
                    Color.fromARGB(255, 46, 70, 2)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                'Navigation Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildDrawerItem('Capital Screen', CapitalScreenHome()),
            _buildDrawerItem('Line Screen', LineScreenHome()),
            _buildDrawerItem('Investment Screen', InvestmentHomeScreen()),
            _buildDrawerItem('Party Screen', PartyHomeScreen()),
            _buildDrawerItem('Lending Screen', LendingHomeScreen()),
            _buildDrawerItem('Collection Screen', CollectionScreen()),
            _buildDrawerItem('Daily Report Screen', DailyReportScreen()),
            _buildDrawerItem('Bulk Insert', CollectionHomeScreen()),
            _buildDrawerItem('Report Screen', ReportScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 28, 54, 27),
            Color.fromARGB(255, 229, 243, 242)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Text(
            'Home Screen Content',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, Widget screen) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }
}
