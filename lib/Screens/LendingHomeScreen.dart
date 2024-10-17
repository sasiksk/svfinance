import 'package:flutter/material.dart';
import 'package:svfinance/Screens/LendingBasicDetailsScreen.dart';

class LendingHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lending Home'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Lending Home Screen Content',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LendingBasicDetailsScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
