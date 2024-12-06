import 'package:flutter/material.dart';

class OwnerHomepage extends StatefulWidget {
  // Optional constructor if you want to pass additional arguments
  const OwnerHomepage({Key? key}) : super(key: key);

  @override
  _OwnerHomepageState createState() => _OwnerHomepageState();
}

class _OwnerHomepageState extends State<OwnerHomepage> {
  // Define the screens for each tab
  final List<Widget> _ownerScreens = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
