import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> boardingHouses = [
    // static list of boarding houses
    {
      'name': "Students' Haven",
      'description': 'Near University of Iloilo, with study areas',
      'rating': 4,
      'amenities': ['Wi-Fi', 'Air-conditioned', 'Laundry Service'],
      'image': 'lib/assets/bh1.jpg',
      'type': 'Room',
      'isLiked': false,
    },
    {
      'name': 'Rivera Inn',
      'description': 'Affordable and safe, well-ventilated rooms',
      'rating': 3,
      'amenities': ['Wi-Fi', '24/7 Security', 'Free Parking'],
      'image': 'lib/assets/bh2.jpg',
      'type': 'Bedspace',
      'isLiked': false,
    },
    {
      'name': 'Transient House Iloilo',
      'description': 'Fully furnished rooms for short stays',
      'rating': 4,
      'amenities': ['Wi-Fi', 'Air-conditioned'],
      'image': 'lib/assets/bh3.webp',
      'type': 'Transient',
      'isLiked': false,
    },
  ];

  List<Map<String, dynamic>> filteredBoardingHouses =
      []; // filtered version of boardingHouses for searching
  // String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    filteredBoardingHouses = boardingHouses;
  }

  void _searchBoardingHouses() {
    setState(() {
      filteredBoardingHouses = boardingHouses
          .where((house) =>
              house['name']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              house['description']
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

              // Filters Section (for testing)
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       _categoryButton('All'),
              //       _categoryButton('Bedspace'),
              //       _categoryButton('Room'),
              //       _categoryButton('Transient'),
              //     ],
              //   ),
              // ),

              // Boarding Houses List
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredBoardingHouses.length,
                  itemBuilder: (context, index) {
                    final house = filteredBoardingHouses[index];
                    return createBoardingHouseCards(
                      house['name'],
                      house['description'],
                      house['rating'],
                      house['image'],
                      house['isLiked'],
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

  // BH Cards for listings
  Widget createBoardingHouseCards(
    String name,
    String description,
    int rating,
    String imagePath,
    bool isLiked,
    int index,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 275,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape
                        .circle, // Make sure the shadow follows the round shape
                  ),
                  child: IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                      size: 30,
                      color: isLiked
                          ? const Color.fromARGB(255, 255, 38, 74)
                          : Colors.white, // color change based on like state
                    ),
                    onPressed: () {
                      setState(() {
                        boardingHouses[index]['isLiked'] =
                            !boardingHouses[index]
                                ['isLiked']; // toggle like state
                      });
                    },
                  ),
                ),
              )
            ],
          ),
          ListTile(
            title:
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.orange, size: 16),
                const SizedBox(width: 5),
                Text(rating.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
