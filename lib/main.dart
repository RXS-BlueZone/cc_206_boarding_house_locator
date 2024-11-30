import 'package:cc_206_boarding_house_locator/features/homepage%20(placeholder).dart';
import 'package:cc_206_boarding_house_locator/features/login_page.dart';
import 'package:cc_206_boarding_house_locator/features/role_selection_page.dart';
import 'package:cc_206_boarding_house_locator/features/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hbxnsgvkwnuxflfsvjox.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhieG5zZ3Zrd251eGZsZnN2am94Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzIxMTQ3NTksImV4cCI6MjA0NzY5MDc1OX0.THv60rIvz8zupimuxZVIydrXsAbGGX1O1UKcN_0YS_4',
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
      routes: {
        '/': (context) => const RoleSelectionPage(),
        '/signup': (context) => SignUpPage(
              userType: '',
            ),
        '/login': (context) => const LoginPage(),
        '/homepage': (context) => HomePage(),
      },
      initialRoute: _getRouteCondition(),
    );
  }

  // Function to determine the initial route based on authentication status
  String _getRouteCondition() {
    // Check if the user is logged in using Supabase
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      return '/homepage'; // Redirect logged-in users to homepage
    } else {
      return '/login'; // If not logged in, send them to role selection page
    }
  }
}
