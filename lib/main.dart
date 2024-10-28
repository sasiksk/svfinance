import 'package:flutter/material.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';

import 'package:svfinance/Screens/HomeScreen/NewHomeScreen.dart'; // Import your DatabaseHelper class

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure widgets are bound before async code

  //await DatabaseHelper.dropDatabase(      'finace.db'); // Uncomment if you need to drop the database
  runApp(MaterialApp(
    home: Newhomescreen(),
  ));
}
