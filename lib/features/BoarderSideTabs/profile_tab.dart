import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    try {
      final userId = _supabaseClient.auth.currentUser!.id;
      final response = await _supabaseClient
          .from('USERS')
          .select('user_fullname, user_email, user_phonenumber')
          .eq('user_id', userId)
          .single();

      if (mounted) {
        setState(() {
          userData = response;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _createProfilePlaceholderImage() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 101, 185, 106),
            const Color.fromARGB(255, 67, 160, 72)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(183, 76, 175, 79),
            blurRadius: 16,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        size: 50,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    if (userData == null) {
      return const Center(
        child: Text(
          'Error loading profile information.',
          style: TextStyle(
              fontSize: 16,
              /*colors: Colors.green,*/ fontWeight: FontWeight.w500),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile image
            _createProfilePlaceholderImage(),
            const SizedBox(height: 16),

            Text(
              userData!['user_fullname'] ?? 'Unknown Name',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // User details in cards (field-like)
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text('Email'),
                subtitle: Text(userData!['user_email'] ?? 'Unknown Email'),
                leading: const Icon(Icons.email, color: Colors.green),
              ),
            ),
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text('Phone Number'),
                subtitle:
                    Text(userData!['user_phonenumber'] ?? 'Unknown Contact'),
              ),
            ),

            const SizedBox(height: 32),

            // Logout button with gradient
            ElevatedButton(
              onPressed: () async {
                try {
                  await Supabase.instance.client.auth.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                } catch (e) {
                  print('Error logging out: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error logging out: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.green,
                elevation: 5,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
