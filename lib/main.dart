import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

/// =====================
/// APP ROOT
/// =====================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartPage(),
    );
  }
}

/// =====================
/// KONSTANTA
/// =====================
const String guruPin      = '1234';
const String prefGuruMode = 'guru_mode';
const String prefLastUrl  = 'last_form_url';

/// =====================
/// HALAMAN AWAL
/// =====================
class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final TextEditingController linkController = TextEditingController();

  void startExam(String url) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExamPage(formUrl: url),
      ),
    );
  }

  void openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRScanPage(onResult: startExam),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UJIAN ONLINE')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Masukkan Link Google Form\natau Scan QR dari Guru',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: linkController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'https://forms.gle/...',
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                if (linkController.text.isNotEmpty) {
                  startExam(linkController.text);
                }
              },
              child: const Text('MULAI UJIAN'),
            ),
            const SizedBox(height: 20),
            const Divider(),
            ElevatedButton.icon(
              onPressed: openScanner,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('SCAN QR'),
            ),
          ],
        ),
      ),
    );
  }
}

/// =====================
/// QR SCANNER
/// =====================
class QRScanPage extends StatelessWidget {
  final Function(String) onResult;
  const QRScanPage({super.key, required this.onResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: MobileScanner(
        onDetect: (barcode) {
          final code = barcode.barcodes.first.rawValue;
          if (code != null) {
            Navigator.pop(context);
            onResult(code);
          }
        },
      ),
    );
  }
}

/// =====================
/// HALAMAN UJIAN (KIOSK)
/// =====================
class ExamPage extends StatefulWidget {
  final String formUrl;
  const ExamPage({super.key, required this.formUrl});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  static const MethodChannel platform = MethodChannel('kiosk_mode');

  WebViewController? controller;
  bool isGuru = false;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState() async {
    final prefs = await SharedPreferences.getInstance();
    // isGuru = prefs.getBool(prefGuruMode) ?? false;

    // if (!isGuru) {
    //   await platform.invokeMethod('startKiosk'); // 🔒 SISWA
    // }
    await platform.invokeMethod('startKiosk');
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            if (isGuru) {
              await prefs.setString(prefLastUrl, request.url);
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    if (isGuru && prefs.containsKey(prefLastUrl)) {
      await controller!.loadRequest(
        Uri.parse(prefs.getString(prefLastUrl)!),
      );
    } else {
      await prefs.remove(prefLastUrl);
      await controller!.loadRequest(Uri.parse(widget.formUrl));
    }

    setState(() {});
  }

  /// =====================
  /// PIN GURU
  /// =====================
  void bukaGuru() {
    final pin = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('PIN Guru'),
        content: TextField(
          controller: pin,
          obscureText: true,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (pin.text == guruPin) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(prefGuruMode, true);

                isGuru = true;
                Navigator.pop(context);

                // 🔓 GURU BEBAS
                platform.invokeMethod('stopKiosk');
              }
            },
            child: const Text('BUKA'),
          ),
        ],
      ),
    );
  }

  /// =====================
  /// SET SELESAI (SISWA)
  /// =====================
  void setSelesai() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Selesai Ujian?'),
        content: const Text('Aplikasi akan ditutup'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // ❌ RESET TOTAL
              await platform.invokeMethod('exitApp');
            },
            child: const Text('SELESAI'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UJIAN'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: setSelesai,
          ),
          IconButton(
            icon: const Icon(Icons.lock_open),
            onPressed: bukaGuru,
          ),
        ],
      ),
      body: controller == null
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: controller!),
    );
  }
}
