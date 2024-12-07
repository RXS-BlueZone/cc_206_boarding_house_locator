import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: unused_import
import '../home_tab.dart';

class BoardingHouseDetailsPage extends StatefulWidget {
  // Required parameters passed to this page
  final int buildId; // ID of the building
  final String
      imagePath; // URL/path to the building's image from Supabase buckets

  // to initialize with required parameters
  const BoardingHouseDetailsPage(
      {super.key, required this.buildId, required this.imagePath});

  @override
  State<BoardingHouseDetailsPage> createState() =>
      _BoardingHouseDetailsPageState();
}

class _BoardingHouseDetailsPageState extends State<BoardingHouseDetailsPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  Map<String, dynamic>?
      boardingHouseDetails; // storage for fetched data of boarding house details
  List<Map<String, dynamic>> rooms = [];
  Map<String, dynamic>? ownerDetails; // storage for fetched owner details
  bool isLoading = true;
  bool isRoomsLoading = true;
  bool isOwnerLoading = true;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    _getBHDetails(); // get boarding house details when the page loads
    _getRooms();
    _getOwnerDetails(); // fetch owner details
  }

  // get building details from the Supabase backend
  Future<void> _getBHDetails() async {
    try {
      final response = await _supabaseClient
          .from('BUILDING')
          .select(
              'build_id, build_name, build_description, build_rating , build_amenities, build_address')
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

  // function to fetch rooms from the database based on build_id
  Future<void> _getRooms() async {
    try {
      final response = await _supabaseClient
          .from('ROOMS')
          .select('room_id, room_name, room_description, room_price')
          .eq('build_id', widget.buildId);

      setState(() {
        rooms = List<Map<String, dynamic>>.from(
            response); // storage for fetched data
        isRoomsLoading = false;
      });
    } catch (e) {
      print('Error fetching rooms: $e');
      setState(() {
        isRoomsLoading = false;
      });
    }
  }

  // get owner details associated with the build_id to be displayed
  Future<void> _getOwnerDetails() async {
    try {
      // relation to the BUILDING table
      final response = await _supabaseClient
          .from('BUILDING')
          .select(
            'USERS:user_id(user_fullname, user_phonenumber, user_email)',
          )
          .eq('build_id', widget.buildId)
          .single();

      if (response['USERS'] != null) {
        setState(() {
          ownerDetails = response['USERS'];
          isOwnerLoading = false;
        });
      } else {
        setState(() {
          ownerDetails = null;
          isOwnerLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching owner details: $e'); // debugging
      setState(() {
        isOwnerLoading = false;
      });
    }
  }

  // reused getImageUrl in getting BH image
  String getRoomImageURL(String buildName, String roomName) {
    final supabaseBucket =
        _supabaseClient.storage.from('boarding-house-images');

    final response = supabaseBucket.getPublicUrl("$buildName/$roomName.jpg");
    return response;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || isOwnerLoading) {
      // for loading spinner as the data is fetched
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

    final details = boardingHouseDetails!; // non-nullable shortcut for details
    final amenitiesString = details['build_amenities'] ?? '';
    final amenitiesList = amenitiesString
        .split(',')
        .map((e) => e.trim())
        .toList(); // parsing amenities into a list

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Image.network(
                    widget.imagePath,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // if there is an error fetching the image, display error icon
                      return const Icon(Icons.error,
                          size: 50, color: Colors.red);
                    },
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon:
                          const Icon(Icons.arrow_back, size: 30), // Back Button
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          details['build_rating']?.toString() ?? '0',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Owner Details Section
              // Owner Details Section
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Owner Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (ownerDetails != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Name: ${ownerDetails?['user_fullname'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Phone: ${ownerDetails?['user_phonenumber'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.email, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Email: ${ownerDetails?['user_email'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ] else
                        const Text(
                          'Owner details not available',
                          style: TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ),
              ),

              // BH details card (including rooms)
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        details['build_name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        details['build_address'],
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            const TabBar(
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Colors.green,
                              tabs: [
                                Tab(
                                  child: Text(
                                    'Details',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Tab(
                                  child: Text(
                                    'Rooms',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 300,
                              child: TabBarView(
                                children: [
                                  // BH Details Tab
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Description:',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(details['build_description']),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Amenities:',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        ...amenitiesList.map(
                                            (amenity) => Text('- $amenity')),
                                      ],
                                    ),
                                  ),
                                  // Rooms Tab
                                  isRoomsLoading
                                      ? const Center(
                                          // used loading Icon
                                          child: CircularProgressIndicator(),
                                        )
                                      : ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: rooms.length,
                                          itemBuilder: (context, index) {
                                            final room = rooms[index];
                                            final roomImage = getRoomImageURL(
                                                details['build_name'],
                                                room[
                                                    'room_name']); // pass build_name and room_name

                                            return ExpansionTile(
                                              title: Text(
                                                room['room_name'],
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              subtitle: Text(
                                                  'Price: ₱${room['room_price']}'),
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Image.network(
                                                        roomImage,
                                                        height: 150,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return const Icon(
                                                              Icons.error,
                                                              size: 50,
                                                              color:
                                                                  Colors.red);
                                                        },
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        room[
                                                            'room_description'],
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
