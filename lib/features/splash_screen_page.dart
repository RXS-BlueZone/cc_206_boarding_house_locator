import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goTo();
  }

  // Handle routing after the splash screen
  Future<void> _goTo() async {
    await Future.delayed(const Duration(
        seconds: 3)); // Delay for splash screen before displaying login

    try {
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        // For Debugging: Log the session
        print('Session restored: ${session.toJson()}');

        // Check if session is valid by querying the USERS table
        final email = session.user.email;
        if (email != null) {
          final response = await Supabase.instance.client
              .from('USERS')
              .select('user_email')
              .eq('user_email', email);

          if (response.isNotEmpty) {
            // Go to homepage if the user exists
            Navigator.pushReplacementNamed(context, '/homepage');
            return;
          }
        }
      }

      // Go to login if no valid session or user is found
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error checking session: $e');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'lib/assets/logo.png',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 8),
            // Slogan
            const Text(
              'Discover your ideal boarding house.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
