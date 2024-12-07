import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://wwnayjgntdptacsbsnus.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3bmF5amdudGRwdGFjc2JzbnVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI5NTU0MzMsImV4cCI6MjA0ODUzMTQzM30.w3E77UKpHnnhpe7Q3IEBXJhMdB3UP7Fvux9PQf7dxi0');
  runApp(const AddNewBoardinHouse(userId: ''));
}

class AddNewBoardinHouse extends StatefulWidget {
  final String userId;

  const AddNewBoardinHouse({super.key, required this.userId});

  @override
  State<AddNewBoardinHouse> createState() => _AddNewBoardinHouseState();
}

class _AddNewBoardinHouseState extends State<AddNewBoardinHouse> {
  final _formKey = GlobalKey<FormState>();
  Uint8List? _webImage;
  bool _isUploading = false;
//---------------------update details to database---------------------//
  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _buildingDescriptionController =
      TextEditingController();
  final TextEditingController _buildingAdressController =
      TextEditingController();
  final TextEditingController _buildingAmenitiesController =
      TextEditingController();

  String? BuildingName;
  bool imageAdded = false;

  Future<void> _validateBuildingName() async {
    if (_formKey.currentState!.validate()) {
      final name = _buildingNameController.text;
      try {
        final response = await Supabase.instance.client
            .from('BUILDING')
            .select('build_name')
            .eq('build_name', name)
            .maybeSingle();

        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Boarding House name already in use!'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Boarding House created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Call the subsequent functions to process the form and upload the image
          await _submitBuildingData();
          await _uploadImage();

          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitBuildingData() async {
    final buildingName = _buildingNameController.text;
    final buildDescription = _buildingDescriptionController.text;
    final buildingAddress = _buildingAdressController.text;
    final buildingAmenities = _buildingAmenitiesController.text;
    final buildingUserId = widget.userId;

    BuildingName = buildingName;

    if (buildingName.isEmpty ||
        buildDescription.isEmpty ||
        buildingAddress.isEmpty ||
        buildingAmenities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    if (buildingAddress.isEmpty || buildingAmenities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address and Amenities are required')),
      );
      return;
    }
    try {
      await Supabase.instance.client.from('BUILDING').insert({
        'build_name': buildingName,
        'build_description': buildDescription,
        'build_address': buildingAddress,
        'build_amenities': buildingAmenities,
        'user_id': buildingUserId,
      });

      _buildingNameController.clear();
      _buildingDescriptionController.clear();
      _buildingAdressController.clear();
      _buildingAmenitiesController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _buildingNameController.dispose();
    _buildingDescriptionController.dispose();
    _buildingAdressController.dispose();
    _buildingAmenitiesController.dispose();
    _webImage = null;
    super.dispose();
  }

//---------------------------------pick our image from --------------------------//
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _webImage = bytes;
        imageAdded = true;
      });
    } else {
      setState(() {
        imageAdded = false;
      });
    }
  }

  //---------------------future function to upload our image to database---------------//
  Future<void> _uploadImage() async {
    if (_webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }
    setState(() {
      _isUploading = true;
    });
    try {
      final supabase = Supabase.instance.client;
      final fileName = "buildingProfile";
      final filePath = '$BuildingName/$fileName.jpg';

      final storageResponse = await supabase.storage
          .from('boarding-house-images')
          .uploadBinary(filePath, _webImage!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('  ')),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Boarding House Information",
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 300,
                        height: 150,
                        decoration: BoxDecoration(
                            border: Border.all(
                          color: const Color.fromARGB(255, 105, 105, 105),
                          width: 1.0,
                        )),
                        child: Center(
                          child: _webImage == null
                              ? Icon(Icons.image)
                              : Image.memory(
                                  _webImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: 5),
                          Visibility(
                            visible: !imageAdded,
                            child: Text(
                              "Please Add image first",
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                          ),
                          Visibility(
                            visible: imageAdded,
                            child: SizedBox.shrink(),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 180,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          onPressed: _pickImage,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Upload Image",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _buildingNameController,
                        decoration: InputDecoration(
                          labelText: "Title",
                          prefixIcon: Icon(
                            Icons.house,
                            color: Colors.green,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color:
                                    const Color.fromARGB(255, 105, 105, 105)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.green),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _buildingAdressController,
                        decoration: InputDecoration(
                          labelText: "Address",
                          prefixIcon: Icon(
                            Icons.gps_fixed,
                            color: Colors.green,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color:
                                    const Color.fromARGB(255, 105, 105, 105)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.green),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _buildingDescriptionController,
                        decoration: InputDecoration(
                          labelText: "Description",
                          prefixIcon: Icon(
                            Icons.edit_note,
                            color: Colors.green,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 105, 105, 105),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 30,
                            horizontal: 16,
                          ),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: 6,
                        minLines: 1,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _buildingAmenitiesController,
                        decoration: InputDecoration(
                          labelText: "Amenities",
                          prefixIcon: Icon(
                            Icons.description,
                            color: Colors.green,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 105, 105, 105),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 30,
                            horizontal: 16,
                          ),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: 7,
                        minLines: 1,
                      ),
                      SizedBox(height: 20),
                      Text("Create your boarding house"),
                      SizedBox(height: 5),
                      SizedBox(
                        width: 400,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          onPressed: () {
                            if (!_isUploading) {
                              if (imageAdded) {
                                _validateBuildingName();
                              }
                            }
                          },
                          child: Text(
                            "Create",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
