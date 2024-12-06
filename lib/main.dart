import 'package:cc_206_boarding_house_locator/features/OwnerSideNav.dart';
import 'package:cc_206_boarding_house_locator/features/OwnerSideTabs/hometab_folder/add_boarding_house.dart';
import 'package:cc_206_boarding_house_locator/features/login_page.dart';
import 'package:cc_206_boarding_house_locator/features/role_selection_page.dart';
import 'package:cc_206_boarding_house_locator/features/sign_up_page.dart';
import 'package:cc_206_boarding_house_locator/features/splash_screen_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wwnayjgntdptacsbsnus.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3bmF5amdudGRwdGFjc2JzbnVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI5NTU0MzMsImV4cCI6MjA0ODUzMTQzM30.w3E77UKpHnnhpe7Q3IEBXJhMdB3UP7Fvux9PQf7dxi0',
    debug: true,
  );
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
      initialRoute: '/', // initial route to SplashScreen
      routes: {
        '/': (context) => const SplashScreen(),
        '/role_selection': (context) => const RoleSelectionPage(),
        '/signup': (context) => SignUpPage(
              userType: '',
            ),
        '/login': (context) => const LoginPage(),
        '/homepage': (context) => OwnerHome(userId: ""),
        '/add_boarding_house': (context) => AddNewBoardingHouse(userId: ""),
      },
    );
  }
}
