import 'package:flutter/material.dart';

class LineDetailScreen extends StatelessWidget {
  final String lineName;

  LineDetailScreen({required this.lineName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lineName,
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
      body: Center(
        child: Text(
          'Details for $lineName',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
