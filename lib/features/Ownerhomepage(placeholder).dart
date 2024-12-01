import 'package:flutter/material.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Home Page'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          'This is the OWNER homepage',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
