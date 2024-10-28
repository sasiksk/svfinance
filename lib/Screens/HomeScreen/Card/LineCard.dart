import 'package:flutter/material.dart';
import 'package:svfinance/Screens/HomeScreen/Line/LineHomeScreens.dart';

import 'package:svfinance/Screens/LineDetailScreen.dart';

class LineCard extends StatelessWidget {
  final String lineName;
  final double screenWidth;
  final Function(String) onLineSelected;

  LineCard({
    required this.lineName,
    required this.screenWidth,
    required this.onLineSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onLineSelected(lineName);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LineHomeScreen2(lineName: lineName), // Pass the line name
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        width: screenWidth - 40, // Full width minus padding (20 on each side)
        child: Card(
          elevation: 10.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  Colors.blueGrey.shade700,
                  Colors.black87
                ], // Gradient background
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                  20.0), // Increased padding for consistency
              child: Text(
                lineName,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text color
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
