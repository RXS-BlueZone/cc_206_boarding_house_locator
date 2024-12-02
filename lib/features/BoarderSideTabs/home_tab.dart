import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  List<Map<String, dynamic>> boardingHouses =
      []; // storage for list containing all the fetched records of boarding houses
  List<Map<String, dynamic>> filteredBoardingHouses =
      []; // filtered version of boardingHouses based on the user’s search input

  @override
  void initState() {
    super.initState();
    _getBoardingHouses();
  }

  Future<void> _getBoardingHouses() async {
    try {
      final response = await _supabaseClient.from('BUILDING').select(
          'build_id, build_name, build_description, build_rating, build_amenities, build_address, user_id, build_created_at');

      final data = response as List<dynamic>;
      setState(() {
        boardingHouses = data.map((item) {
          final amenities = (item['build_amenities'] ?? '').toString();
          final buildName = item['build_name'] ?? 'unknown_building';

          return {
            'id': item['build_id'] ?? 0,
            'name': buildName,
            'description':
                item['build_description'] ?? 'No description available',
            'rating': item['build_rating'] ?? 0,
            'amenities': amenities,
            'image': getImageURL(
                buildName), // get image using build_name (build_name = folder name inside bucket)
            'address': item['build_address'] ?? 'Unknown Address',
            'isSaved': false,
          };
        }).toList();

        filteredBoardingHouses = boardingHouses;
      });
    } catch (e) {
      print('Error fetching boarding houses: $e');
    }
  }

  String getImageURL(String buildName) {
    final storageBucket = _supabaseClient.storage
        .from('boarding-house-images'); // bucket name for images
    final response = storageBucket
        .getPublicUrl("$buildName/buildingProfile.jpg"); // image path

    return response ?? ''; // just a placeholder
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    hintText: 'Search for boarding houses...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => _searchBoardingHouses(),
                ),
              ),

              // List of Boarding Houses
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  // ListView.builder for dynamic layout
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredBoardingHouses.length,
                  itemBuilder: (context, index) {
                    final house = filteredBoardingHouses[index];
                    return _createBoardingHouseCardList(
                      // Details to show in card
                      house['id'],
                      house['name'],
                      house['address'],
                      house['rating'],
                      house['image'],
                      house['isSaved'],
                      index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createBoardingHouseCardList(
    int id,
    String name,
    String description,
    int rating,
    String imagePath,
    bool isSaved,
    int index,
  ) {
    final imagePath = getImageURL(name);

    return GestureDetector(
      // Wrapped with gesture detector to make the whole card clickable
      onTap: () => Navigator.pushNamed(
        context,
        '/bhdetails',
        arguments: {
          'id': id, // Pass the build_id
          'image':
              getImageURL(name), // Pass the dynamically generated image URL
        },
      ),

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
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(86, 77, 77, 77),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isSaved
                            ? Icons.bookmark
                            : Icons.bookmark_border_outlined,
                        size: 30,
                        color: isSaved
                            ? const Color.fromARGB(255, 19, 199, 55)
                            : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          boardingHouses[index]['isSaved'] =
                              !boardingHouses[index]['isSaved'];
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            ListTile(
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 5),
                  Text(rating.toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
