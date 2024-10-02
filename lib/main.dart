import 'package:cc_206_boarding_house_locator/features/role_selection_page.dart';
import 'package:cc_206_boarding_house_locator/features/sign_up_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boarding House Locator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const SignUpPage(
        userType: '',
      ),
    );
  }
}
