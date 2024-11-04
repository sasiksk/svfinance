import 'package:flutter/material.dart';
import 'package:svfinance/Screens/DatabaseHelper.dart';
import 'package:svfinance/Screens/HomeScreen/NewHomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Uncomment the following line if you need to drop the database
  // await DatabaseHelper.dropDatabase('finace.db');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFF284102), // Dark green color
        hintColor: const Color(0xFFB2DFDB), // Light green for accents
        scaffoldBackgroundColor: const Color(0xFFF3F4F6), // Light background
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(
              255, 84, 92, 71), // AppBar color matching primary color
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white), // Icon color in AppBar
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          titleLarge: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF284102), // Button color matching primary
          textTheme: ButtonTextTheme.primary,
        ),
        iconTheme:
            const IconThemeData(color: Color(0xFF284102)), // General icon color
      ),
      home: const Newhomescreen(),
    );
  }
}
