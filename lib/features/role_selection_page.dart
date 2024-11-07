import 'package:flutter/material.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  _RoleSelectionPageState createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  bool showTapText = false;
  double tapTextOpacity = 1.0; // initial opacity after tapping

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome to',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'BoardM8.',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showTapText = true;
                            tapTextOpacity =
                                1.0; // Show the text instantly and reset opacity to 1
                          });
                          // to fade out the text after 2 seconds by changing the opacity
                          Future.delayed(const Duration(seconds: 2), () {
                            setState(() {
                              tapTextOpacity = 0.0;
                            });
                          });
                        },
                        child: SizedBox(
                          width: 300.0,
                          height: 300.0,
                          child: Image.asset(
                            'lib/assets/role_selection_illustration.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Discover your ideal boarding house.',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    clipBehavior: Clip
                        .none, // to ensure the text isn't clipped in the stack
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.99,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.green, width: 2.0),
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 14.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () {
                                // Logic to identify type of user for boarder
                              },
                              child: const Text(
                                'Are you a boarder?',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.green),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.99,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 14.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () {
                                // Logic to identify type of user for owner
                              },
                              child: const Text(
                                'Are you an owner?',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (showTapText)
                        Positioned(
                          top: -40, // put the text above the buttons
                          left: 0,
                          right: 0,
                          child: AnimatedOpacity(
                            opacity: tapTextOpacity,
                            duration: const Duration(seconds: 2),
                            child: const Text(
                              'Pick your role',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
