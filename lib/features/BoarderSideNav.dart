import 'package:flutter/material.dart';
import 'package:cc_206_boarding_house_locator/features/BoarderSideTabs/home_tab.dart';
import 'package:cc_206_boarding_house_locator/features/BoarderSideTabs/profile_tab.dart';
import 'package:cc_206_boarding_house_locator/features/BoarderSideTabs/saved_tab.dart';

class BoarderHomePage extends StatefulWidget {
  const BoarderHomePage({super.key});

  @override
  _BoarderHomePageState createState() => _BoarderHomePageState();
}

class _BoarderHomePageState extends State<BoarderHomePage> {
  int _currentIndex = 0; // to track the selected tab

  // Screens for each tab
  final List<Widget> _boarderScreens = [HomeTab(), SavedTab(), ProfileTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _boarderScreens[_currentIndex], // Show the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green, // Color when selected
        unselectedItemColor: Colors.grey, // Color when not selected
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update selected tab on tap
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 0 ? Icons.home : Icons.home_outlined,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 1 ? Icons.bookmark : Icons.bookmark_border,
            ),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 2 ? Icons.person : Icons.person_outline,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
