import 'package:cc_206_boarding_house_locator/features/OwnerSideTabs/home_tab.dart';
import 'package:cc_206_boarding_house_locator/features/OwnerSideTabs/profile_tab.dart';
import 'package:flutter/material.dart';


class OwnerHome extends StatefulWidget {
  final String userId;
  const OwnerHome({super.key, required this.userId});

  @override
  _OwnerHomeState createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  int _currentIndex = 0; // to track the selected tab
  late String userId; // Declare but don't initialize here

  late final List<Widget> _boarderScreens; // Initialize later

  @override
  void initState() {
    super.initState();
    userId = widget.userId; // Initialize userId with widget.userId
    _boarderScreens = [
      HomeTab(userId: userId), // Now userId is accessible
      // Add other screens for Saved and Profile if necessary
  ProfileTab(),
      // Placeholder
    ];
  }

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
              _currentIndex == 2 ? Icons.person : Icons.person_outline,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
