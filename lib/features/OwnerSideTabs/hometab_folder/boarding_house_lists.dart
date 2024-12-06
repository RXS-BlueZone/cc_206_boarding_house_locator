import 'package:cc_206_boarding_house_locator/features/OwnerSideTabs/hometab_folder/update_boarding_house.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

String OLDBHNAME = "";

class BoardingHouseLists extends StatefulWidget {
  final String userId;
  final bool refresh;
  const BoardingHouseLists(
      {super.key, required this.userId, required this.refresh});

  @override
  State<BoardingHouseLists> createState() => _BoardingHouseListsState();
}

class _BoardingHouseListsState extends State<BoardingHouseLists> {
  Uint8List? _webImage;
  bool _isUploading = false;
  late final SupabaseClient supabase;
  final TextEditingController _searchController = TextEditingController();
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  late Future<String> _imageUrl;

  List<Map<String, dynamic>> boardingHouses = [];
  List<Map<String, dynamic>> filteredBoardingHouses = [];
  String selectedCategory = 'All';

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

  Future<void> updateBHDetails({
    required String newBHName,
    required String address,
    required String description,
    required String amenities,
    required String oldBHName,
  }) async {
    oldBHName = OLDBHNAME;
    print('old BH N: $oldBHName');

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

    print('NEW BH NAME: $newBHName');

    if (response.isEmpty) {
      throw Exception('Failed to update BH details.');
    }

    try {
      final oldFolderPath = oldBHName; // Old folder path
      final newFolderPath = newBHName; // New folder path
      print('old folder path: $oldFolderPath');
      print('new folder path: $newFolderPath');

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
        print("Folder renamed successfully.");
        // fetchUserData();
        // _uploadImage();
      }

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

  final boardingHousenameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final amenitiesController = TextEditingController();
  final oldbhnameController = TextEditingController();

  Future<void> _getBoardingHouses() async {
    try {
      final response = await _supabaseClient
          .from('BUILDING')
          .select(
              'build_id, build_name, build_description, build_rating, build_amenities, build_address, user_id, build_created_at')
          .eq('user_id', widget.userId);
      if (response.isNotEmpty) {
        final data = response as List<dynamic>;

        setState(() {
          boardingHouses = data.map((item) {
            final amenities =
                (item['build_amenities'] ?? '').toString().split(',');
            final buildName = item['build_name'] ?? 'unknown_building';

            return {
              'id': item['build_id'] ?? 0,
              'name': buildName,
              'description':
                  item['build_description'] ?? 'No description available',
              'rating': item['build_rating'] ?? 0,
              'amenities': amenities,
              'image': getImageURL(buildName),
              'address': item['build_address'] ?? 'Unknown Address',
              'isSaved': false,
            };
          }).toList();

          filteredBoardingHouses = boardingHouses;
        });
      } else {
        print('Error fetching boarding houses: ${response}');
      }
    } catch (e) {
      print('Error fetching boarding houses: $e');
    }
  }

  String getImageURL(String buildName) {
    final storageBucket = _supabaseClient.storage.from('boarding-house-images');
    final response =
        storageBucket.getPublicUrl("$buildName/buildingProfile.jpg");
    String imagePath = "$buildName/buildingProfile.jpg";
    return response;
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: 450,
          height: 620,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsetsDirectional.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 30,
                        width: 105,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: () {
                                _getBoardingHouses();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.refresh,
                                      size: 16, color: Colors.green),
                                  SizedBox(width: 2),
                                  Text("Refresh",
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.green)),
                                ],
                              )),
                        ),
                      ),
                      SizedBox(width: 30),
                      Text("My Boarding Houses",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                // List of Boarding Houses
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredBoardingHouses.length,
                    itemBuilder: (context, index) {
                      final house = filteredBoardingHouses[index];
                      return _createBoardingHouseCard(
                        house['name'],
                        house['address'],
                        house['rating'],
                        house['image'],
                        house['isSaved'],
                        house['id'],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createBoardingHouseCard(
    String name,
    String description,
    int rating,
    String imagePath,
    bool isSaved,
    int buildId,
  ) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imagePath,
                      width: double.infinity,
                      height: 275,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error,
                            size: 50, color: Colors.red);
                      },
                    )),
                Positioned(
                  right: 50,
                  top: 10,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(137, 255, 255, 255),
                        borderRadius: BorderRadius.circular(7)),
                    child: Center(
                      child: IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 16,
                          ),
                          onPressed: () {}),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(137, 255, 255, 255),
                        borderRadius: BorderRadius.circular(7)),
                    child: Center(
                      child: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 18,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UpdateBoardingHouse(
                                          buildId: buildId,
                                        )));
                          }),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
