import 'package:flutter/material.dart';

class CollectionCard extends StatelessWidget {
  final String date;
  final double screenWidth;
  final String amount;

  CollectionCard({
    required this.date,
    required this.screenWidth,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date, style: TextStyle(fontSize: 16.0)),
            Text(amount, style: TextStyle(fontSize: 16.0)),
          ],
        ),
      ),
    );
  }
}
