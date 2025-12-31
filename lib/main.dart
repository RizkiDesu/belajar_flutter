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
          title: Text(
            'My Apps',
            style: TextStyle(
              fontFamily: 'GoogleSans',
              color: Colors.white, // Warna title
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true, // Title di tengah
        ),
        body: Center(
          child: Text(
            'Hello World, This apps using Flutter Framework, and Flutter is a framework for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              backgroundColor: Colors.amber,
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 10,
              fontFamily: 'GoogleSans',
              decoration: TextDecoration.lineThrough,
              decorationStyle: TextDecorationStyle.wavy,
              decorationColor: Colors.white,
              decorationThickness: 2,
            ),
          ),
        ),
      ),
    );
  }
}
