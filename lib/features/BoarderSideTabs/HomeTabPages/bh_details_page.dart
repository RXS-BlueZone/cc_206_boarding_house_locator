import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BoardingHouseDetailsPage extends StatefulWidget {
  final int buildId;

  const BoardingHouseDetailsPage({Key? key, required this.buildId})
      : super(key: key);

  @override
  State<BoardingHouseDetailsPage> createState() =>
      _BoardingHouseDetailsPageState();
}

class _BoardingHouseDetailsPageState extends State<BoardingHouseDetailsPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  Map<String, dynamic>? boardingHouseDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBoardingHouseDetails();
  }

  Future<void> _fetchBoardingHouseDetails() async {
    try {
      final response = await _supabaseClient
          .from('BUILDING')
          .select(
              'build_id, build_name, build_description, build_rating, build_amenities, build_address, user_id, build_created_at')
          .eq('build_id', widget.buildId)
          .single();

      setState(() {
        boardingHouseDetails = response;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching boarding house details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Boarding House Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (boardingHouseDetails == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Boarding House Details')),
        body: const Center(child: Text('Boarding house not found')),
      );
    }

    final details = boardingHouseDetails!;
    final amenitiesString = details['build_amenities'] ?? '';
    final amenitiesList =
        amenitiesString.split(',').map((e) => e.trim()).toList();

    return Scaffold(
      appBar: AppBar(title: Text(details['build_name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              details['build_name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              details['build_address'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text('Description: ${details['build_description']}'),
            const SizedBox(height: 16),
            const Text('Amenities:'),
            const SizedBox(height: 8),
            ...amenitiesList.map((amenity) => Text('- $amenity')).toList(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange),
                const SizedBox(width: 5),
                Text(details['build_rating'].toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
