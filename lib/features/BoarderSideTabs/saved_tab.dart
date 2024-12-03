import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_tab.dart';

class SavedTab extends StatefulWidget {
  @override
  _SavedTabState createState() => _SavedTabState();
}

class _SavedTabState extends State<SavedTab> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> savedBoardingHouses =
      []; // storage for saved boarding houses
  bool isLoading = true; // for loading icon

  @override
  void initState() {
    super.initState();
    _getSavedBH();
  }

  // get saved boarding houses from the database
  Future<void> _getSavedBH() async {
    try {
      final userId = _supabaseClient
          .auth.currentUser!.id; // current id of user in sessions

      // get all saved boarding houses for the user
      final response = await _supabaseClient.from('HOUSE_SAVES').select('''
          house_id,
          BUILDING(
            build_id,
            build_name,
            build_description,
            build_rating,
            build_address,
            build_amenities
          )
        ''').eq('boarder_id', userId);

      final data = response as List<dynamic>; // put response to a List

      if (mounted) {
        setState(() {
          savedBoardingHouses = data.map((item) {
            final house = item['BUILDING'];
            return {
              'id': house['build_id'],
              'name': house['build_name'],
              'description':
                  house['build_description'] ?? 'No description available',
              'rating': house['build_rating'] ?? 0,
              'address': house['build_address'] ?? 'Unknown Address',
              'amenities': house['build_amenities'] ?? 'No amenities listed',
              'image': getImageURL(house['build_name']),
            };
          }).toList();
          isLoading = false; // stop loading spinner if data is already fetched
        });
      }
    } catch (e) {
      print('Error fetching saved boarding houses: $e');
      if (mounted) {
        setState(() {
          isLoading =
              false; // stop the loading spinner even if there's an error
        });
      }
    }
  }

  // remove boarding house from the saved
  Future<void> _unsaveBH(int houseId) async {
    final userId = _supabaseClient.auth.currentUser!.id;

    try {
      await _supabaseClient
          .from('HOUSE_SAVES')
          .delete()
          .match({'boarder_id': userId, 'house_id': houseId});

      // Remove from local list
      setState(() {
        savedBoardingHouses.removeWhere((house) => house['id'] == houseId);
      });

      // value notifier connecting to Home Tab
      final updatedBoardingHouses =
          HomeTabState.boardingHousesNotifier.value.map((house) {
        if (house['id'] == houseId) {
          house['isSaved'] = false; // change as unsaved
        }
        return house;
      }).toList();

      HomeTabState.boardingHousesNotifier.value = updatedBoardingHouses;
    } catch (e) {
      print('Error unsaving boarding house: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('An error occurred: $e')), // notify the user of the error
      );
    }
  }

  String getImageURL(String buildName) {
    final supabaseBucket = _supabaseClient.storage
        .from('boarding-house-images'); // Image bucket from supabase
    final response =
        supabaseBucket.getPublicUrl("$buildName/buildingProfile.jpg");
    return response ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // show loading spinner while data is being fetched
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (savedBoardingHouses.isEmpty) {
      return const Center(
        child: Text(
          'No saved boarding houses yet.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    // list of saved BH
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: savedBoardingHouses.length,
      itemBuilder: (context, index) {
        final house = savedBoardingHouses[index];
        return InkWell(
          onTap: () {
            //  to details page of selected boarding house
            Navigator.pushNamed(
              context,
              '/bhdetails',
              arguments: {
                'id': house['id'],
                'image': house['image'],
              },
            );
          },
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section in the card
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Image.network(
                    house['image'],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.error,
                            color:
                                Colors.red), // icon if ever there is no image
                      );
                    },
                  ),
                ),
                // Details Section of BH
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          house['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          house['address'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              house['rating'].toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.bookmark_remove,
                                color: Colors.red, // unsave icon
                              ),
                              onPressed: () => _unsaveBH(house['id']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
