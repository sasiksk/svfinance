import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget destinationScreen;

  const BottomNavItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.destinationScreen,
  }) : super(key: key);

  void _navigateTo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destinationScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: FaIcon(icon, color: Colors.white),
          onPressed: () => _navigateTo(context),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
