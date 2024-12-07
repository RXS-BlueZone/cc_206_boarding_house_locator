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
        seconds: 2)); // Delay for splash screen before displaying login (changed from 3 to 2 seconds)

    try {
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        // For Debugging: Log the session
        print('Session restored: ${session.toJson()}');

        // Check if session is valid by querying the USERS table using user_id (to redirect to home page if user is not logged out)
        final userId = session.user.id;
        final response = await Supabase.instance.client
            .from('USERS')
            .select('user_id, user_type') // get user_id and user_type from USERS table
            .eq('user_id', userId)
            .single(); // Expect a single record or row from the table

        // Check the user_type and navigate accordingly if user truly is in session
        final userType = response['user_type'];
        if (userType == 'Boarder') {
          Navigator.pushReplacementNamed(context, '/boarderHome');
        } else if (userType == 'Owner') {
          Navigator.pushReplacementNamed(context, '/ownerHome');
        }
        // Precautionary
        else {
         
          print('Unexpected user_type: $userType');
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      // Go to login if no valid session or user is found
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // For debugging purposes: Print error in console
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
