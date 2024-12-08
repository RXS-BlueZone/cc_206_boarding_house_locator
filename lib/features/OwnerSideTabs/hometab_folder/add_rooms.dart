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
  runApp(const AddRooms(buildId: 0, buildName: 'Abo Nai Dormitories'));
}

class AddRooms extends StatefulWidget {
  final int buildId;
  final String buildName;
  const AddRooms({super.key, required this.buildId, required this.buildName});

  @override
  State<AddRooms> createState() => _AddRoomsState();
}

class _AddRoomsState extends State<AddRooms> {
  final _formKey = GlobalKey<FormState>();
  Uint8List? _webImage;
  bool _isUploading = false;
//---------------------update details to database---------------------//
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _roomPriceController = TextEditingController();
  final TextEditingController _roomDescriptionController =
      TextEditingController();

  String RoomName = 'Abo Nai Dormitories';
  bool imageAdded = false;

  Future<void> _validateBuildingName() async {
    if (_formKey.currentState!.validate()) {
      final name = _roomNameController.text;
      try {
        final response = await Supabase.instance.client
            .from('ROOMS')
            .select('room_name')
            .eq('room_name', name)
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
              content: Text('Room name is available!'),
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
    final roomName = _roomNameController.text;
    final roomPrice = _roomPriceController.text;
    final roomDescription = _roomDescriptionController.text;

    RoomName = roomName;

    if (roomName.isEmpty || roomPrice.isEmpty || roomDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    try {
      await Supabase.instance.client.from('ROOMS').insert({
        'room_name': roomName,
        'room_price': roomPrice,
        'room_description': roomDescription,
        'build_id': widget.buildId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room added successfully!')),
      );

      _roomNameController.clear();
      _roomPriceController.clear();
      _roomDescriptionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _roomPriceController.dispose();
    _roomDescriptionController.dispose();
    _webImage = null;
    super.dispose();
  }

//------------------upload images----------------------//
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

  Future<void> _uploadImage() async {
    String FileFolderName = widget.buildName;

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
      final filePath = '$FileFolderName/$RoomName.jpg';

      final storageResponse = await supabase.storage
          .from('boarding-house-images')
          .uploadBinary(filePath, _webImage!);

      if (storageResponse.isNotEmpty) {
        print("uploaded successfully");
      }

      final publicUrl =
          supabase.storage.from('boarding-house-images').getPublicUrl(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully! URL: $publicUrl')),
      );
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
                  padding: EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Room Name Information",
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 300,
                        height: 150,
                        decoration: BoxDecoration(
                            border: Border.all(
                          color: const Color.fromARGB(255, 105, 105, 105),
                          width: 1,
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
                              SizedBox(width: 8),
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
                        controller: _roomNameController,
                        decoration: InputDecoration(
                          labelText: "Room Name",
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
                        controller: _roomPriceController,
                        decoration: InputDecoration(
                          labelText: "Room Price",
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
                          controller: _roomDescriptionController,
                          decoration: InputDecoration(
                            labelText: "Room Description",
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
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          minLines: 1),
                      SizedBox(height: 20),
                      Text("Create Room"),
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