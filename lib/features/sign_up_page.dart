import 'package:cc_206_boarding_house_locator/features/login_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required String userType});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>(); // Key to validate the form
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // to get inputs from both fields and compare
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Added controllers for email and phone
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameController = TextEditingController(); // Added controller for name

  String userType =
      ''; // This will store the user type passed from the previous page

  // Retrieve the userType from the ModalRoute
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) {
      setState(() {
        userType = args; // Store the user type in the state
      });
    }
  }

  // for email validation
  String? _checkEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailValidFormat =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailValidFormat.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // for phone number validation specific
  String? _checkPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    final phoneNumberFormat = RegExp(r'^(?:\+63|0)\d{10}$');
    if (!phoneNumberFormat.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _checkPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    // to check the password for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    // to check for at least one number
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  String? _checkConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // for name validation
  String? _checkName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

// Function to handle user registration
  Future<void> _registerUser() async {
    try {
      // Register the user in Supabase with email and password
      final response = await Supabase.instance.client.auth.signUp(
        _emailController.text, // Get email from the controller
        _passwordController.text, // Get password from the controller
      );

      if (response.error == null) {
        // Retrieve the user ID from the response
        final userId = response.user?.id;

        if (userId == null) {
          // Handle the case where userId is unexpectedly null
          print('User ID is null after registration');
          showDialog(
            context: context,
            builder: (BuildContext) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Failed to retrieve user ID. Please try again.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          return; // Stop execution if the user ID is null
        }

        // Log the user type and user ID to ensure they're correct
        print('User Type: $userType'); // Debugging line
        print('User ID: $userId'); // Debugging line

        // Save additional user details into the 'users' table
        final insertResponse =
            await Supabase.instance.client.from('users').insert([
          {
            'id': userId, // Use the retrieved user ID
            'full_name': _nameController.text,
            'email': _emailController.text,
            'phone_number': _phoneController.text,
            'user_type': userType, // Use the selected role
          }
        ]).execute(); // Call .execute() to actually send the request

        // Check for errors in the insert response
        if (insertResponse.error != null) {
          // Log the error details for debugging
          print('Insert Error: ${insertResponse.error?.message}');
          showDialog(
            context: context,
            builder: (BuildContext) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(
                    'Failed to save user details: ${insertResponse.error?.message ?? 'Unknown error'}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          return; // Stop execution if user details failed to insert
        }

        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext) {
            return AlertDialog(
              title: Text('Registration Successful'),
              content: Text(
                  'Your account has been created and successfully registered!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    // Optionally, navigate to another page here
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Handle registration errors
        print('SignUp Error: ${response.error?.message}');
        showDialog(
          context: context,
          builder: (BuildContext) {
            return AlertDialog(
              title: Text('Registration Failed'),
              content: Text(response.error!.message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle unexpected errors
      print('Error during registration: $e');
      showDialog(
        context: context,
        builder: (BuildContext) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An unexpected error occurred. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.green,
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey, // key for the form
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Name Text Field
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.925, // to occupy 92.5% of screen width
                          height: 50,
                          child: TextFormField(
                            controller:
                                _nameController, // Added controller for name
                            decoration: InputDecoration(
                              labelText: 'Name',
                              prefixIcon:
                                  const Icon(Icons.person, color: Colors.green),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.5),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            keyboardType: TextInputType.name,
                            validator: _checkName,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Email Text Field (now with validation)
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.925, // to occupy 92.5% of screen width
                          height: 50,
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon:
                                  const Icon(Icons.email, color: Colors.green),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.5),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: _checkEmail,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Phone Text Field
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.925, // to occupy 92.5% of screen width
                          height: 50,
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon:
                                  const Icon(Icons.phone, color: Colors.green),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.5),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: _checkPhoneNumber,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Password Text Field
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.925, // to occupy 92.5% of screen width
                          height: 50,
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.green),
                              // IconButton for eye icon
                              suffixIcon: IconButton(
                                icon: Icon(
                                  // for eye icon
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  setState(() {
                                    // for eye icon logic to see password
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.5),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            validator: _checkPassword,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Confirm Password Text Field
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.925, // to occupy 92.5% of screen width
                          height: 50,
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.green),
                              // IconButton for eye icon
                              suffixIcon: IconButton(
                                icon: Icon(
                                  // for eye icon
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  setState(() {
                                    // for eye icon logic to see password
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.5),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.green, width: 2.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            validator: _checkConfirmPassword,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: true, // just for placeholder
                          onChanged: (value) {
                            // Checkbox logic (not yet implemented)
                          },
                          activeColor: Colors.green,
                        ),
                        const Expanded(
                          child: Text(
                            'By registering, you are agreeing with our Terms of Use and Privacy Policy',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Register Button
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _registerUser();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(370, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            "Log in",
                            style: TextStyle(
                              color: Color.fromARGB(255, 103, 172, 105),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
