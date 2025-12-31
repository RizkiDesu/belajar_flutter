import 'package:flutter/material.dart';

void main() {
  runApp(myApps());
}

class myApps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "My Apps",
            style: TextStyle(
              color: Colors.white, // warna title
            ),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Text(
            "Hello World",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
