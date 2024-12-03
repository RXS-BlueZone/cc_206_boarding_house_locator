import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display profile info
          const Text('Profile Tab'),

          // Logout button
          ElevatedButton(
            onPressed: () async {
              try {
                // Sign out the user using Supabase
                await Supabase.instance.client.auth.signOut();

                // Navigate to the login screen after logging out
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                // Handle sign out error
                print('Error logging out: $e');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
