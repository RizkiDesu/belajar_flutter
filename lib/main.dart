import 'package:flutter/material.dart';

void main() {
  runApp(const MyApps());
}

class MyApps extends StatelessWidget {
  const MyApps({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hilangkan tulisan DEBUG
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue, // Warna AppBar
          title: const Text(
            'My Apps',
            style: TextStyle(
              color: Colors.white, // Warna title
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true, // Title di tengah
        ),
        body: const Center(
          child: Text(
            'Hello World',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
