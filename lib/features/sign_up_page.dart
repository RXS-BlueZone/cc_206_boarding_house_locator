import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  final String userType;

  const SignUpPage({super.key, required this.userType});

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

                        // Phone Number Text Field (now with validation)
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.925, // to occupy 92.5% of screen width
                          height: 50,
                          child: TextFormField(
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

                        // Password Text Field (now with validation)
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

                        // Confirm Password Text Field (now with validation)
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.9, // to occupy 90% of screen width
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // to home page if validation is successful (not yet implemented)
                          }
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Link to Login (no link yet)
                    const Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: Color.fromARGB(255, 103, 172, 105),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
