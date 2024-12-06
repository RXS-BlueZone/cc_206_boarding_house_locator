import 'package:cc_206_boarding_house_locator/features/OwnerSideTabs/home_tab.dart';
import 'package:cc_206_boarding_house_locator/features/OwnerSideTabs/profile_tab.dart';
import 'package:flutter/material.dart';

class OwnerHomepage extends StatefulWidget {
  // Optional constructor if you want to pass additional arguments
  const OwnerHomepage({Key? key}) : super(key: key);

  @override
  _OwnerHomepageState createState() => _OwnerHomepageState();
}

class _OwnerHomepageState extends State<OwnerHomepage> {
  int _currentIndex = 0; // Track the selected tab

  // Define the screens for each tab
  final List<Widget> _ownerScreens = [HomeTab(), ProfileTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ownerScreens[_currentIndex], // Show the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update selected tab
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
