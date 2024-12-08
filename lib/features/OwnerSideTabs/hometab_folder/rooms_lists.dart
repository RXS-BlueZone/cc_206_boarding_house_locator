import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://wwnayjgntdptacsbsnus.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3bmF5amdudGRwdGFjc2JzbnVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI5NTU0MzMsImV4cCI6MjA0ODUzMTQzM30.w3E77UKpHnnhpe7Q3IEBXJhMdB3UP7Fvux9PQf7dxi0');
  runApp(const RoomsLists(buildId: 0, imagePath: ''));
}

class RoomsLists extends StatefulWidget {
  final int buildId;
  final String imagePath;
  const RoomsLists({super.key, required this.buildId, required this.imagePath});
  @override
  State<RoomsLists> createState() => _RoomsListsState();
}

class _RoomsListsState extends State<RoomsLists> {
  Uint8List? _webImage;
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? boardingHouseDetails;
  List<Map<String, dynamic>> rooms = [];
  bool isLoading = true;
  bool isRoomsLoading = true;
  late Future<String> _imageUrl;

  final bucketName = "boarding-house-images";
  final filePath = "uploads/roomProfile.jpg";

  final roomPriceController = TextEditingController();
  final roomDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getBHDetails();
    _getRooms();
    _imageUrl = _fetchImageUrl(bucketName, filePath);
  }

  Future<String> _fetchImageUrl(String bucketName, String filePath) async {
    try {
      final response =
          supabase.storage.from(bucketName).getPublicUrl(filePath);

      if (response.isEmpty) {
        throw Exception('Error fetching image URL');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }
Future<void> _getBHDetails() async {
  try {
    final response = await _supabaseClient
        .from('BUILDING')
        .select(
            'build_id, build_name, build_description, build_rating, build_amenities, build_address')
        .eq('build_id', widget.buildId)
        .single();

    setState(() {
      response['build_rating'] = response['build_rating'] ?? 0;

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

  // function to fetch rooms from the database based in build_id
  Future<void> _getRooms() async {
    try {
      final response = await _supabaseClient
          .from('ROOMS')
          .select('room_id, room_name, room_description, room_price')
          .eq('build_id', widget.buildId);

      setState(() {
        rooms = List<Map<String, dynamic>>.from(response);
        isRoomsLoading = false;
      });
    } catch (e) {
      print('Error fetching rooms: $e');
      setState(() {
        isRoomsLoading = false;
      });
    }
  }

  Future<void> updateRoomDetails({
    required int roomId,
    required String price,
    required String description,
  }) async {
    try {
      if (price.isEmpty || description.isEmpty) {
        throw Exception('Price and description cannot be empty.');
      }
      final response = await supabase.from('ROOMS').update({
        'room_price': int.parse(price),
        'room_description': description,
      }).eq('room_id', roomId);

      if (response.error != null) {
        throw Exception('Failed to update room: ${response.error!.message}');
      }
    } catch (e) {
      throw Exception('Error updating room details: $e');
    }
  }

  Future<void> deleteRoomById(int roomId) async {
    try {
      final supabase = Supabase.instance.client;

      final response =
          await supabase.from('ROOMS').delete().eq('room_id', roomId);

      if (response.error == null) {
        print('Record with roomId: $roomId deleted successfully!');
      } else {
        print('Error deleting record: ${response.error!.message}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successsfully deleted Room'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void showPopupDialog(BuildContext context, int roomId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(15),
            child: const Text("Are you sure you want to delete this?"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                deleteRoomById(roomId);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Delete", style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // reused getImageUrl in getting BH image
  String getRoomImageURL(String buildName, String roomName) {
    final supabaseBucket =
        _supabaseClient.storage.from('boarding-house-images');

    final response = supabaseBucket.getPublicUrl("$buildName/$roomName.jpg");
    return response ?? '';
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
                      return const Icon(Icons.error,
                          size: 50, color: Colors.red);
                    },
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 30),
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
                          details['build_rating'].toString(),
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
                              height: 430,
                              child: TabBarView(
                                children: [
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
                                  isRoomsLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: rooms.length,
                                          itemBuilder: (context, index) {
                                            final room = rooms[index];
                                            final roomImage = getRoomImageURL(
                                                details['build_name'],
                                                room['room_name']);

                                            return ExpansionTile(
                                              title: SizedBox(
                                                width: 350,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      room['room_name'],
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: SizedBox(
                                                        width: 120,
                                                        height: 30,
                                                        child: ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.edit,
                                                                    color: Colors
                                                                        .green),
                                                                SizedBox(
                                                                    width: 8),
                                                                Text("Edit",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .green)),
                                                              ],
                                                            ),
                                                            onPressed: () {
                                                              showModalBottomSheet(
                                                                  context:
                                                                      context,
                                                                  isScrollControlled:
                                                                      true,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return Padding(
                                                                      padding:
                                                                          EdgeInsets
                                                                              .only(
                                                                        bottom: MediaQuery.of(context)
                                                                            .viewInsets
                                                                            .bottom,
                                                                      ),
                                                                      child:
                                                                          FractionallySizedBox(
                                                                        heightFactor:
                                                                            0.8,
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Align(
                                                                              alignment: Alignment.topRight,
                                                                              child: IconButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                icon: Icon(Icons.close),
                                                                              ),
                                                                            ),
                                                                            Text('Update Rooms'),
                                                                            SizedBox(height: 10),
                                                                            Container(
                                                                              width: 380,
                                                                              height: 180,
                                                                              decoration: BoxDecoration(
                                                                                  border: Border.all(
                                                                                color: const Color.fromARGB(255, 105, 105, 105),
                                                                                width: 1,
                                                                              )),
                                                                              child: Center(
                                                                                child: _webImage == null
                                                                                    ? FutureBuilder<String>(
                                                                                        future: _imageUrl = _fetchImageUrl(bucketName, '${details['build_name']}/${room['room_name']}.jpg'),
                                                                                        builder: (context, snapshot) {
                                                                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                            return const CircularProgressIndicator();
                                                                                          } else if (snapshot.hasError) {
                                                                                            return CircleAvatar(
                                                                                              backgroundColor: Colors.white,
                                                                                              child: Icon(
                                                                                                Icons.person,
                                                                                                size: 40,
                                                                                                color: Colors.green,
                                                                                              ),
                                                                                            );
                                                                                          } else {
                                                                                            final imageUrl = snapshot.data!;
                                                                                            return SizedBox(
                                                                                              child: Image.network(
                                                                                                imageUrl,
                                                                                                width: 380,
                                                                                                height: 200,
                                                                                                fit: BoxFit.cover,
                                                                                              ),
                                                                                            );
                                                                                          }
                                                                                        },
                                                                                      )
                                                                                    : Image.memory(
                                                                                        _webImage!,
                                                                                        fit: BoxFit.cover,
                                                                                        width: double.infinity,
                                                                                        height: double.infinity,
                                                                                      ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: 20),
                                                                            Text('${room['room_name']}',
                                                                                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                                                                            SizedBox(height: 10),
                                                                            Padding(
                                                                                padding: EdgeInsets.all(20),
                                                                                child: Column(
                                                                                  children: [
                                                                                    TextField(
                                                                                        controller: roomDescriptionController,
                                                                                        decoration: InputDecoration(
                                                                                          labelText: '${room['room_description']}',
                                                                                          prefixIcon: Icon(
                                                                                            Icons.person,
                                                                                            color: Colors.green,
                                                                                          ),
                                                                                          border: OutlineInputBorder(
                                                                                            borderRadius: BorderRadius.circular(10),
                                                                                          ),
                                                                                          enabledBorder: OutlineInputBorder(
                                                                                            borderRadius: BorderRadius.circular(10),
                                                                                            borderSide: BorderSide(color: const Color.fromARGB(255, 105, 105, 105)),
                                                                                          ),
                                                                                          focusedBorder: OutlineInputBorder(
                                                                                            borderRadius: BorderRadius.circular(10),
                                                                                            borderSide: BorderSide(color: Colors.green),
                                                                                          ),
                                                                                        ),
                                                                                        keyboardType: TextInputType.multiline,
                                                                                        maxLines: 3,
                                                                                        minLines: 1),
                                                                                    SizedBox(height: 10),
                                                                                    TextField(
                                                                                      controller: roomPriceController,
                                                                                      decoration: InputDecoration(
                                                                                        labelText: '${room['room_price']}',
                                                                                        prefixIcon: Icon(
                                                                                          Icons.email,
                                                                                          color: Colors.green,
                                                                                        ),
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                          borderSide: BorderSide(color: const Color.fromARGB(255, 105, 105, 105)),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                          borderSide: BorderSide(color: Colors.green),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(height: 15),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        SizedBox(
                                                                                          width: 170,
                                                                                          child: ElevatedButton(
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                backgroundColor: const Color.fromARGB(255, 226, 92, 82),
                                                                                                shape: RoundedRectangleBorder(
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                ),
                                                                                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                                                                              ),
                                                                                              onPressed: () {
                                                                                                showPopupDialog(context, room['room_id']);
                                                                                              },
                                                                                              child: const Text(
                                                                                                'Delete',
                                                                                                style: TextStyle(color: Colors.white, fontSize: 18),
                                                                                              )),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: 170,
                                                                                          child: ElevatedButton(
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                backgroundColor: Colors.green,
                                                                                                shape: RoundedRectangleBorder(
                                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                                ),
                                                                                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                                                                              ),
                                                                                              onPressed: () {
                                                                                                if (int.tryParse(roomPriceController.text) != null) {
                                                                                                  updateRoomDetails(
                                                                                                    roomId: room['room_id'],
                                                                                                    price: roomPriceController.text,
                                                                                                    description: roomDescriptionController.text,
                                                                                                  );
                                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                                    SnackBar(
                                                                                                      content: Text('room updated successfully!'),
                                                                                                      backgroundColor: Colors.green,
                                                                                                    ),
                                                                                                  );
                                                                                                } else {
                                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                                    SnackBar(
                                                                                                      content: Text('please enter a valid number!'),
                                                                                                      backgroundColor: Colors.red,
                                                                                                    ),
                                                                                                  );
                                                                                                }

                                                                                                Navigator.pop(context, true);
                                                                                              },
                                                                                              child: const Text(
                                                                                                'Update',
                                                                                                style: TextStyle(color: Colors.white, fontSize: 18),
                                                                                              )),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                )),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  });
                                                            }),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              subtitle: Text(
                                                  'Price: ₱${room['room_price']}'),
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      16),
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
