import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const MethodChannel platform = MethodChannel('kiosk_mode');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiosk App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_open),
            onPressed: () async {
              await platform.invokeMethod('stopKiosk');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Aplikasi terkunci\nTidak bisa keluar sebelum klik tombol',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
