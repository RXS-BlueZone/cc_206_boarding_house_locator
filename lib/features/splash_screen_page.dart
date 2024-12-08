import 'package:cc_206_boarding_house_locator/features/OwnerSideNav.dart';
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
    await Future.delayed(const Duration(seconds: 2));

    try {
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
            // For Debugging: Log the session
            print('Session restored: ${session.toJson()}');

            // get the user_id from the session and query user details
            final userId = session.user.id;
            final response = await Supabase.instance.client
                .from('USERS')
                .select('user_id, user_type')
                .eq('user_id', userId)
                .single();

            final userType = response['user_type'];

            if (userType == 'Boarder') {
                Navigator.pushReplacementNamed(context, '/boarderHome');
            } else if (userType == 'Owner') {
                // Pass userId to OwnerHomePage to make sure owner is logged in even after closing the app
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OwnerHomePage(userId: userId)),
                );
            } else {
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
