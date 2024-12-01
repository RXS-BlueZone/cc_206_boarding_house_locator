import 'package:flutter/material.dart';

class BoarderHomePage extends StatefulWidget {
  const BoarderHomePage({super.key});

  @override
  State<BoarderHomePage> createState() => _BoarderHomePageState();
}

class _BoarderHomePageState extends State<BoarderHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boarder Home Page'),
      ),
      body: const Center(
        child: Text(
          'This is the BOARDER homepage',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
