import 'package:cc_206_boarding_house_locator/features/BoarderSideTabs/home_tab.dart';
import 'package:cc_206_boarding_house_locator/features/BoarderSideTabs/profile_tab.dart';
import 'package:cc_206_boarding_house_locator/features/BoarderSideTabs/saved_tab.dart';
import 'package:flutter/material.dart';

class BoarderHomePage extends StatefulWidget {
  @override
  _BoarderHomePageState createState() => _BoarderHomePageState();
}

class _BoarderHomePageState extends State<BoarderHomePage> {
  int _currentIndex = 0; // to track the selected tab

  //  screens for each tab
  final List<Widget> _boarderScreens = [HomeTab(), SavedTab(), ProfileTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _boarderScreens[_currentIndex], // show the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // update selected tab on tap
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
