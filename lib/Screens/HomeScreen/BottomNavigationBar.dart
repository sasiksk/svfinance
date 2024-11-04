import 'package:flutter/material.dart';
import 'package:svfinance/Screens/Captial/CaptitalScreen2.dart';
import 'package:svfinance/Screens/Homescreeen.dart';
import 'package:svfinance/Screens/Line/LineScreen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color.fromARGB(255, 40, 65, 2),
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.account_balance, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CapitalScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.line_axis, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LineScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.print, color: Colors.white),
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
