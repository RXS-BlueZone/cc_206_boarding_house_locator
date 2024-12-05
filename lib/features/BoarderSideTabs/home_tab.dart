import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  List<Map<String, dynamic>> boardingHouses =
      []; // storage for list containing all the fetched records of boarding houses
  List<Map<String, dynamic>> filteredBoardingHouses =
      []; // filtered version of boardingHouses based on the user’s search input

  static final ValueNotifier<
      List<
          Map<String, dynamic>>> boardingHousesNotifier = ValueNotifier(
      []); // value notifier - share the boardingHouses list across multiple screens and notify listeners when changes occur

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getBoardingHouses();
  }

  Future<void> _getBoardingHouses() async {
    try {
      final userId = _supabaseClient.auth.currentUser!.id;

      final response = await _supabaseClient.from('BUILDING').select('''
            build_id, 
            build_name, 
            build_description, 
            build_rating, 
            build_amenities, 
            build_address, 
            user_id, 
            build_created_at, 
            HOUSE_SAVES(boarder_id)
            ''');

      final data = response as List<dynamic>;

      setState(() {
        boardingHouses = data.map((item) {
          final amenities = (item['build_amenities'] ?? '').toString();
          final buildName = item['build_name'] ?? 'unknown_building';

          // Check if the current user has saved a particular building
          final isSaved = (item['HOUSE_SAVES'] as List)
              .any((save) => save['boarder_id'] == userId);

          return {
            'id': item['build_id'] ?? 0,
            'name': buildName,
            'description':
                item['build_description'] ?? 'No description available',
            'rating': item['build_rating'] ?? 0,
            'amenities': amenities,
            'image': getImageURL(buildName),
            'address': item['build_address'] ?? 'Unknown Address',
            'isSaved': isSaved,
          };
        }).toList();

        // sort boarding houses by build_id when displaying
        boardingHouses
            .sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
        filteredBoardingHouses = List.from(
            boardingHouses); // to maintain the original order even after saving or switching screens
      });
    } catch (e) {
      print('Error fetching boarding houses: $e');
    }
  }

//
  Future<void> _getSaveStatus(int houseId, int index) async {
    final userId = _supabaseClient.auth.currentUser!.id;

    try {
      if (!boardingHouses[index]['isSaved']) {
        // insert if not saved
        await _supabaseClient.from('HOUSE_SAVES').insert({
          'boarder_id': userId,
          'house_id': houseId,
        });
      } else {
        // Delete if saved
        await _supabaseClient.from('HOUSE_SAVES').delete().match({
          'boarder_id': userId,
          'house_id': houseId,
        });
      }

      // Update state
      setState(() {
        boardingHouses[index]['isSaved'] = !boardingHouses[index]['isSaved'];

        // update filtered list
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
    } catch (e) {
      print('Error toggling save state: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  String getImageURL(String buildName) {
    final supabaseBucket = _supabaseClient.storage
        .from('boarding-house-images'); // bucket name for images
    final response = supabaseBucket
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
                padding: const EdgeInsets.all(16.5),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(103, 255, 255, 255),
                    hintText: 'Search for boarding houses...',
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(158, 158, 158, 158),
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color.fromARGB(255, 156, 156, 156),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.green, // when focused
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(121, 76, 175, 79),
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (_) => _searchBoardingHouses(),
                ),
              ),

              // List of Boarding Houses
              Padding(
                padding: const EdgeInsets.all(16.5),
                child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: HomeTabState.boardingHousesNotifier,
                  builder: (context, boardingHouses, child) {
                    return ListView.builder(
                      shrinkWrap: true, // to adjust size based on its content
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredBoardingHouses.length,
                      itemBuilder: (context, index) {
                        final house = filteredBoardingHouses[index];
                        return _createBoardingHouseCardList(
                          // Details to show in the card
                          house['id'],
                          house['name'],
                          house['address'],
                          house['rating'],
                          house['image'],
                          house['isSaved'],
                          index,
                        );
                      },
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
        margin: const EdgeInsets.only(bottom: 16.5),
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
                        boardingHouses[index]['isSaved']
                            ? Icons.bookmark // If saved, show filled icon
                            : Icons
                                .bookmark_border_outlined, // If not saved, show outline
                        size: 30,
                        color: boardingHouses[index]['isSaved']
                            ? const Color.fromARGB(
                                255, 19, 199, 55) // Saved color
                            : Colors.white, // Not saved color
                      ),
                      onPressed: () =>
                          _getSaveStatus(boardingHouses[index]['id'], index),
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
