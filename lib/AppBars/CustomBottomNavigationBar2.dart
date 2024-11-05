import 'package:flutter/material.dart';

class CustomBottomNavigationBar2 extends StatelessWidget {
  final List<IconData> icons;
  final List<String> labels;
  final List<Widget> screens;

  const CustomBottomNavigationBar2({
    super.key,
    required this.icons,
    required this.labels,
    required this.screens,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return BottomAppBar(
      height: screenHeight * 0.11, // Set height based on screen height
      color: Colors.teal.shade900,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: SizedBox(
        height: screenHeight * 0.1, // Set height based on screen height
        width: screenWidth, // Set width based on screen width
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (index) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(icons[index], color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => screens[index]),
                    );
                  },
                ),
                Text(
                  labels[index],
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
