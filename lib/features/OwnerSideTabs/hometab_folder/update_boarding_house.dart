import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateBoardingHouse extends StatefulWidget {
  final int buildId;

  const UpdateBoardingHouse({super.key, required this.buildId});

  @override
  State<UpdateBoardingHouse> createState() => _UpdateBoardingHouseState();
}

class _UpdateBoardingHouseState extends State<UpdateBoardingHouse> {
  final _formKey = GlobalKey<FormState>();
  Uint8List? _webImage;
  bool _isUploading = false;
  bool imageAdded = false;
  late Future<String> _imageUrl;
  late Future<void> _initializationFuture;
  String BUCKETNAME = "boarding-house-images";
  late String folderName;
  late String BUILDINGNAME;

  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _buildingDescriptionController =
      TextEditingController();
  final TextEditingController _buildingAddressController =
      TextEditingController();
  final TextEditingController _buildingAmenitiesController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _loadBuildingData();
      final folderName = _buildingNameController.text.isNotEmpty
          ? _buildingNameController.text
          : 'uploads';
      final filePath = "$folderName/buildingProfile.jpg";
      setState(() {
        _imageUrl = _fetchImageUrl(BUCKETNAME, filePath);
      });
    } catch (e) {
      debugPrint("Initialization error: $e");
    }
  }

  Future<String> _fetchImageUrl(String bucketName, String filePath) async {
    try {
      final response = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      if (response.isEmpty) {
        throw Exception('Error fetching image URL');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadBuildingData() async {
    try {
      final response = await Supabase.instance.client
          .from('BUILDING')
          .select(
              'build_id, build_name, build_description, build_address, build_amenities, build_rating, user_id')
          .eq('build_id', widget.buildId)
          .single();

      setState(() {
        _buildingNameController.text = response['build_name'] ?? '';
        _buildingDescriptionController.text =
            response['build_description'] ?? '';
        _buildingAddressController.text = response['build_address'] ?? '';
        _buildingAmenitiesController.text = response['build_amenities'] ?? '';
      });
        } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _updateBuildingData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final updates = {
        'build_name': _buildingNameController.text,
        'build_description': _buildingDescriptionController.text,
        'build_address': _buildingAddressController.text,
        'build_amenities': _buildingAmenitiesController.text,
      };

      final response = await Supabase.instance.client
          .from('BUILDING')
          .update(updates)
          .eq('build_id', widget.buildId);

      String buildName = _buildingNameController.text;
      String folderName = "$buildName/buildingProfile.jpg";
      String bucketname = BUCKETNAME;
      _fetchImageUrl(bucketname, folderName);

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Building updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating building: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> deleteBuildById(int userId) async {
    try {
      final supabase = Supabase.instance.client;

      final response =
          await supabase.from('BUILDING').delete().eq('build_id', userId);

      if (response.error == null) {
        print('Record with userId: $userId deleted successfully!');
      } else {
        print('Error deleting record: ${response.error!.message}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successsfully deleted Boarding House'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void showPopupDialog(BuildContext context, int buildId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(15.0),
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
                deleteBuildById(buildId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Text(
                    "Update Boarding House Information",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<void>(
                    future: _initializationFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            height: 180,
                            width: 500,
                            child: Center(
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return FutureBuilder<String>(
                          future: _imageUrl,
                          builder: (context, imageSnapshot) {
                            if (imageSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (imageSnapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SizedBox(
                                  height: 180,
                                  width: 500,
                                  child: Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              final imageUrl = imageSnapshot.data!;
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SizedBox(
                                  height: 180,
                                  width: 500,
                                  child: Center(
                                    child: Image.network(
                                      imageUrl,
                                      height: 200,
                                      width: 500,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder(
                    future: Supabase.instance.client
                        .from('BUILDING')
                        .select(
                            'build_name, build_address, build_description, build_amenities')
                        .eq('build_id', widget.buildId)
                        .single(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData) {
                        return const Center(
                            child: Text('No building data found.'));
                      } else {
                        final buildName =
                            snapshot.data as Map<String, dynamic>;
                        BUILDINGNAME = buildName['build_name'];
                        return Column(
                          children: [
                            SizedBox(height: 20),
                            Text(buildName['build_name'],
                                style: TextStyle(fontSize: 30)),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _buildingAddressController,
                              decoration: InputDecoration(
                                labelText: 'Building Address',
                                prefixIcon: const Icon(Icons.location_on,
                                    color: Colors.green),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                                controller: _buildingDescriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Building Description',
                                  prefixIcon: const Icon(Icons.description,
                                      color: Colors.green),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                minLines: 1),
                            const SizedBox(height: 20),
                            TextFormField(
                                controller: _buildingAmenitiesController,
                                decoration: InputDecoration(
                                  labelText: 'Building Amenities',
                                  prefixIcon: const Icon(Icons.list,
                                      color: Colors.green),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                minLines: 1),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 170,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 226, 92, 82),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                          ),
                          onPressed: () {
                            showPopupDialog(context, widget.buildId);
                          },
                          child: _isUploading
                              ? const Text(
                                  'Delete',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                )
                              : const Text(
                                  'Delete',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                          ),
                          onPressed: _isUploading ? null : _updateBuildingData,
                          child: _isUploading
                              ? const Text(
                                  'Update',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                )
                              : const Text(
                                  'Update',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
