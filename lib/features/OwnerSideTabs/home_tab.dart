import 'dart:typed_data';
import 'dart:math';
import 'package:cc_206_boarding_house_locator/features/OwnerSideTabs/hometab_folder/boarding_house_lists.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://wwnayjgntdptacsbsnus.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3bmF5amdudGRwdGFjc2JzbnVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI5NTU0MzMsImV4cCI6MjA0ODUzMTQzM30.w3E77UKpHnnhpe7Q3IEBXJhMdB3UP7Fvux9PQf7dxi0');
  runApp(const HomeTab(userId: ''));
}

FocusNode _focusNode = FocusNode();

class HomeTab extends StatefulWidget {
  final String userId;

  const HomeTab({super.key, required this.userId});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Uint8List? _webImage;
  late final SupabaseClient supabase;
  late Future<String> _imageUrl;
  String userFullName = "";
  String userPhoneNumber = "";
  String userEmail = "";
  String? userType;

  // Future function to fetch user data
  Future<void> fetchUserData() async {
    try {
      final response = await Supabase.instance.client
          .from('USERS')
          .select('user_fullname, user_phonenumber, user_email, user_type')
          .eq('user_id', widget.userId)
          .single();

      //  to set the users information in the database to the screen
      if (response.isNotEmpty) {
        setState(() {
          userFullName = response['user_fullname'];
          userPhoneNumber = response['user_phonenumber'];
          userEmail = response['user_email'];
          userType = response['user_type'];
        });
      } else {
        throw Exception('No user data found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching user data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool refreshBoardingHouses = false;

//---------------------update user details-------------------------//

// Controllers for the text fields
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  Future<void> updateUserDetails({
    required String userId,
    required String fullname,
    required String email,
    required String phoneNumber,
  }) async {
    // Update user details in the USERS table

    final response = await supabase
        .from('USERS')
        .update({
          'user_fullname': fullname,
          'user_email': email,
          'user_phonenumber': phoneNumber,
        })
        .eq('user_id', userId)
        .select();

    print(fullname);

    if (response.isNotEmpty) {
      throw Exception('Failed to update user details.');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _initializeData();

    final bucketfolder = 'uploads';
    final bucketName = 'user-images';

    final random = Random();
    int randomNumber = random.nextInt(4) + 1;
    final added = randomNumber;
    final filePath = "$bucketfolder/profile$added.jpg";

    _imageUrl = _fetchImageUrl(bucketName, filePath);
  }

  Future<void> _initializeData() async {
    await fetchUserData();
    supabase = Supabase.instance.client;

    final bucketfolder = 'uploads';
    final bucketName = 'user-images';
    final random = Random();
    int randomNumber = random.nextInt(5) + 1;
    final added = randomNumber;

    final filePath = "$bucketfolder/profile$added.jpg";

    _imageUrl = _fetchImageUrl(bucketName, filePath);
    _fetchImageUrl(bucketName, filePath);
  }

  //a function to check the email address if follows the correct format
  checkEmail(String? email) {
    if (email == null || email.isEmpty) {
      return false;
    }

    final emailValidFormat =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailValidFormat.hasMatch(email)) {
      SnackBar(content: Text("Enter valid email address"));
      return false;
    }
    return true;
  }

  // Function to fetch image URL from Supabase Storage
  Future<String> _fetchImageUrl(String bucketName, String filePath) async {
    try {
      final response =
          await supabase.storage.from(bucketName).getPublicUrl(filePath);

      if (response.isEmpty) {
        throw Exception('Error fetching image URL');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    return Scaffold(
      body: SafeArea(
        child: Stack(children: <Widget>[
          Positioned(
            child: SingleChildScrollView(
              child: Column(children: [
                Container(
                  height: 150,
                  width: 500,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              FutureBuilder<String>(
                                future: _imageUrl,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.green,
                                      ),
                                    );
                                  } else {
                                    final imageUrl = snapshot.data!;
                                    return ClipOval(
                                      child: Image.network(
                                        imageUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                        FutureBuilder(
                            future: supabase
                                .from('USERS')
                                .select(
                                    'user_fullname, user_phonenumber, user_email, user_type')
                                .eq('user_id', widget.userId)
                                .single(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData) {
                                return const Center(
                                    child: Text('No user data found.'));
                              } else {
                                final user =
                                    snapshot.data as Map<String, dynamic>;
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${user['user_fullname']}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(Icons.email,
                                              color: Colors.white),
                                          SizedBox(width: 10),
                                          Text(
                                            ' ${user['user_email']}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            ' ${user['user_phonenumber']}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom,
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
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
                                            Text('Update User Profile'),
                                            SizedBox(height: 10),
                                            Container(
                                              width: 350,
                                              height: 180,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                color: const Color.fromARGB(
                                                    255, 105, 105, 105),
                                                width: 1.0,
                                              )),
                                              child: Center(
                                                child: _webImage == null
                                                    ? FutureBuilder<String>(
                                                        future: _imageUrl,
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return const CircularProgressIndicator();
                                                          } else if (snapshot
                                                              .hasError) {
                                                            return CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Icon(
                                                                Icons.person,
                                                                size: 40,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            );
                                                          } else {
                                                            final imageUrl =
                                                                snapshot.data!;
                                                            return SizedBox(
                                                              child:
                                                                  Image.network(
                                                                imageUrl,
                                                                width: 380,
                                                                height: 180,
                                                                fit: BoxFit
                                                                    .cover,
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
                                            SizedBox(height: 10),
                                            Padding(
                                                padding: EdgeInsets.all(20.0),
                                                child: Column(
                                                  children: [
                                                    TextField(
                                                      controller:
                                                          fullnameController,
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: userFullName,
                                                        prefixIcon: Icon(
                                                          Icons.person,
                                                          color: Colors.green,
                                                        ),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide: BorderSide(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  105,
                                                                  105,
                                                                  105)),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .green),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    TextField(
                                                      controller:
                                                          emailController,
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: userEmail,
                                                        prefixIcon: Icon(
                                                          Icons.email,
                                                          color: Colors.green,
                                                        ),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide: BorderSide(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  105,
                                                                  105,
                                                                  105)),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .green),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    TextField(
                                                      controller:
                                                          phoneController,
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            userPhoneNumber,
                                                        prefixIcon: Icon(
                                                          Icons.phone,
                                                          color: Colors.green,
                                                        ),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide: BorderSide(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  105,
                                                                  105,
                                                                  105)),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .green),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      "Update your profile",
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                    ),
                                                    SizedBox(height: 5),
                                                    SizedBox(
                                                      width: 400,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.green,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      20,
                                                                  vertical: 16),
                                                        ),
                                                        onPressed: () async {
                                                          bool emailChecker =
                                                              checkEmail(
                                                                  emailController
                                                                      .text);

                                                          if (fullnameController
                                                                  .text
                                                                  .isEmpty &&
                                                              emailController
                                                                  .text
                                                                  .isEmpty &&
                                                              phoneController
                                                                  .text
                                                                  .isEmpty) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    "Fill all the fields"),
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                            );
                                                            Navigator.pop(
                                                                context, true);
                                                            return;
                                                          }
                                                          if (!emailChecker) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    "Enter a valid email address"),
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                            );
                                                            Navigator.pop(
                                                                context, true);
                                                            return;
                                                          }

                                                          if (int.tryParse(
                                                                  phoneController
                                                                      .text) ==
                                                              null) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'Please input a valid phone number'),
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                            );
                                                            Navigator.pop(
                                                                context, true);
                                                            return;
                                                          }

                                                          try {
                                                            await updateUserDetails(
                                                              userId:
                                                                  widget.userId,
                                                              fullname:
                                                                  fullnameController
                                                                      .text,
                                                              email:
                                                                  emailController
                                                                      .text,
                                                              phoneNumber:
                                                                  phoneController
                                                                      .text,
                                                            );

                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'Profile updated successfully!'),
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                              ),
                                                            );

                                                            _initializeData();
                                                          } catch (e) {
                                                            // Handle error and show message
                                                            // ScaffoldMessenger
                                                            //         .of(context)
                                                            //     .showSnackBar(
                                                            //   SnackBar(
                                                            //     content: Text(
                                                            //         'An error occurred while updating the profile.'),
                                                            //     backgroundColor:
                                                            //         Colors.red,
                                                            // ),
                                                            // );
                                                          }

                                                          Navigator.pop(
                                                              context, true);
                                                          fetchUserData();
                                                        },
                                                        child: Text(
                                                          "Update Details",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.edit,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 450,
                    height: 620,
                    child: BoardingHouseLists(
                        userId: widget.userId, refresh: refreshBoardingHouses),
                  ),
                ),
              ]),
            ),
          ),
          Positioned(
            bottom: 70,
            right: 5,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(171, 76, 175, 79),
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/add_boarding_house',
                  arguments: widget.userId,
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
