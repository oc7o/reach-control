import 'package:flutter/material.dart';

class ReachNavigationBar extends StatefulWidget {
  const ReachNavigationBar({super.key});

  @override
  State<ReachNavigationBar> createState() => _ReachNavigationBarState();
}

class _ReachNavigationBarState extends State<ReachNavigationBar> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _counter,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamed(context, '/map');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/com');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/settings');
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.computer),
          label: 'Com',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
