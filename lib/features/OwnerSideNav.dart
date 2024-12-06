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
  int _currentIndex = 0;
  late String userId;

  late final List<Widget> _boarderScreens;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    _boarderScreens = [
      HomeTab(userId: userId),
      ProfileTab(
        userId: userId,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _boarderScreens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
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
