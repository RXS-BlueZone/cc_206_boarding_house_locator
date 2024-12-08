import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:cc_206_boarding_house_locator/features/OwnerSideTabs/hometab_folder/add_rooms.dart';
import 'package:cc_206_boarding_house_locator/features/OwnerSideTabs/hometab_folder/rooms_lists.dart';
import 'package:cc_206_boarding_house_locator/features/OwnerSideTabs/hometab_folder/update_boarding_house.dart';

String OLDBHNAME = "";

class BoardingHouseLists extends StatefulWidget {
  final String userId;
  final bool refresh;

  const BoardingHouseLists({
    super.key,
    required this.userId,
    required this.refresh,
  });

  @override
  State<BoardingHouseLists> createState() => _BoardingHouseListsState();
}

class _BoardingHouseListsState extends State<BoardingHouseLists> {
  Uint8List? _webImage;
  late final SupabaseClient supabase;
  final TextEditingController _searchController = TextEditingController();
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  List<Map<String, dynamic>> boardingHouses = [];
  List<Map<String, dynamic>> filteredBoardingHouses = [];

  @override
  void initState() {
    super.initState();
    _getBoardingHouses();
  }

  //------------------upload images----------------------//
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );

    if (result != null) {
      final bytes = result.files.single.bytes;
      setState(() {
        _webImage = bytes;
      });
    }
  }

  //------------------update boarding house details----------------------//
  Future<void> updateBHDetails({
    required String newBHName,
    required String address,
    required String description,
    required String amenities,
    required String oldBHName,
  }) async {
    oldBHName = OLDBHNAME;
    final response = await supabase
        .from('BUILDING')
        .update({
          'build_name': newBHName,
          'build_address': address,
          'build_description': description,
          'build_amenities': amenities,
        })
        .eq('user_id', widget.userId)
        .select();

    if (response.isEmpty) {
      throw Exception('Failed to update BH details.');
    }

    try {
      final oldFolderPath = oldBHName; // Old folder path
      final newFolderPath = newBHName; // New folder path

      // Move files to the new folder
      final listResponse = await supabase.storage
          .from('boarding-house-images')
          .list(path: oldFolderPath);

      if (listResponse.isEmpty) {
        throw Exception(
            'No files found in the folder or failed to list files.');
      }

      for (final file in listResponse) {
        final moveResponse =
            await supabase.storage.from('boarding-house-images').move(
                  '$oldFolderPath/${file.name}',
                  '$newFolderPath/${file.name}',
                );
        if (moveResponse.isEmpty) {
          throw Exception('Failed to move file: ${file.name}');
        }
      }

      // Remove the old folder
      final deleteResponse = await supabase.storage
          .from('boarding-house-images')
          .remove([oldFolderPath]);
      if (deleteResponse.isEmpty) {
        throw Exception('Failed to delete old folder.');
      }
    } catch (e) {
      throw Exception('Error renaming folder: $e');
    }
  }

  //------------------get boarding houses----------------------//
  Future<void> _getBoardingHouses() async {
    try {
      final response = await _supabaseClient
          .from('BUILDING')
          .select(
              'build_id, build_name, build_description, build_rating, build_amenities, build_address, user_id')
          .eq('user_id', widget.userId);

      if (response.isNotEmpty) {
        final data = response as List<dynamic>;
        setState(() {
          boardingHouses = data.map((item) {
            final buildName = item['build_name'] ?? 'Unknown Building';
            final rating = item['build_rating'] ?? 0;
            return {
              'id': item['build_id'] ?? 0,
              'name': buildName,
              'description': item['build_description'] ?? 'No description',
              'rating': rating,
              'image': _getImageURL(buildName),
              'address': item['build_address'] ?? 'Unknown Address',
            };
          }).toList();

          filteredBoardingHouses = boardingHouses;
        });
      } else {
        print('No data found');
      }
    } catch (e) {
      print('Error fetching boarding houses: $e');
    }
  }

  //------------------get image URL----------------------//
  String _getImageURL(String buildName) {
    final storageBucket = _supabaseClient.storage.from('boarding-house-images');
    return storageBucket.getPublicUrl("$buildName/buildingProfile.jpg");
  }

  //------------------search boarding houses----------------------//
  void _searchBoardingHouses() {
    setState(() {
      filteredBoardingHouses = boardingHouses
          .where((house) =>
              house['name']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              house['address']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  //------------------build UI----------------------//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            //------------------header----------------------//
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Boarding Houses",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _getBoardingHouses,
                    child: const Icon(
                      Icons.refresh,
                      size: 18,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),

            //------------------search bar----------------------//
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _searchBoardingHouses(),
                decoration: InputDecoration(
                  hintText: "Search boarding houses",
                  prefixIcon: const Icon(Icons.search, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            //------------------boarding houses list----------------------//
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 80,
                ),
                itemCount: filteredBoardingHouses.length,
                itemBuilder: (context, index) {
                  final house = filteredBoardingHouses[index];
                  return _createBoardingHouseCard(
                    house['name'],
                    house['address'],
                    house['rating'],
                    house['image'],
                    house['id'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //------------------boarding house card----------------------//
  Widget _createBoardingHouseCard(
    String name,
    String description,
    int rating,
    String imagePath,
    int buildId,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomsLists(
              buildId: buildId,
              imagePath: imagePath,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //------------------image with overlay buttons----------------------//
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.network(
                            imagePath,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                height: 180,
                                child: Center(
                                  child: Icon(Icons.error, size: 50, color: Colors.red),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(204, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(43, 0, 0, 0),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.add, color: Colors.green),
                                  iconSize: 18, 
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddRooms(
                                          buildId: buildId,
                                          buildName: name,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(204, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(8), 
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(43, 0, 0, 0),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.green),
                                  iconSize: 18, 
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UpdateBoardingHouse(
                                          buildId: buildId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            //------------------details----------------------//
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      rating,
                      (index) =>
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                    ),
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
