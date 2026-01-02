import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
/// CONSTANTS
/// =====================
const String teacherPin = '202512';
const String prefTeacherMode = 'teacher_mode';
const String prefLastUrl = 'last_form_url';

/// =====================
/// START PAGE
/// =====================
class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final TextEditingController linkController = TextEditingController();

  @override
  void dispose() {
    linkController.dispose();
    super.dispose();
  }

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
        builder: (_) => QRScanPage(
          onResult: (value) {
            setState(() => linkController.text = value);
            startExam(value);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isValid = linkController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'ONLINE EXAM',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// LOGO
                  Image.asset('assets/icon/exam.png', height: 90),

                  const SizedBox(height: 16),

                  const Text(
                    'ONLINE EXAM',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Enter the Google Form link\nor scan QR code from the teacher',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// INPUT LINK
                  TextField(
                    controller: linkController,
                    keyboardType: TextInputType.url,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'https://forms.gle/...',
                      prefixIcon: const Icon(Icons.link),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// START BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isValid
                          ? () => startExam(linkController.text.trim())
                          : null,
                      child: const Text(
                        'START EXAM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// DIVIDER
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// SCAN QR BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton.icon(
                      onPressed: openScanner,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('SCAN QR CODE'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// =====================
/// QR SCANNER
/// =====================
class QRScanPage extends StatefulWidget {
  final Function(String) onResult;
  const QRScanPage({super.key, required this.onResult});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: MobileScanner(
        onDetect: (capture) {
          if (scanned) return;

          final code = capture.barcodes.first.rawValue;
          if (code != null) {
            scanned = true;
            Navigator.pop(context);
            widget.onResult(code);
          }
        },
      ),
    );
  }
}

/// =====================
/// EXAM PAGE (KIOSK)
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
  bool isTeacher = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    isTeacher = prefs.getBool(prefTeacherMode) ?? false;

    await platform.invokeMethod('startKiosk');

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            if (isTeacher) {
              await prefs.setString(prefLastUrl, request.url);
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    if (isTeacher && prefs.containsKey(prefLastUrl)) {
      await controller!.loadRequest(Uri.parse(prefs.getString(prefLastUrl)!));
    } else {
      await prefs.remove(prefLastUrl);
      await controller!.loadRequest(Uri.parse(widget.formUrl));
    }

    setState(() {});
  }

  /// =====================
  /// TEACHER PIN
  /// =====================
  void unlockTeacher() {
    final pin = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Teacher PIN'),
        content: TextField(
          controller: pin,
          obscureText: true,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (pin.text == teacherPin) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(prefTeacherMode, true);
                isTeacher = true;

                await platform.invokeMethod('stopKiosk');

                Navigator.pop(context);
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  /// =====================
  /// FINISH EXAM
  /// =====================
  void finishExam() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Exam Finished'),
        content: const Text('Application will exit'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              await platform.invokeMethod('stopKiosk');

              await SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);

              await platform.invokeMethod('exitApp');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  /// =====================
  /// BUILD EXAM PAGE – ENGLISH & LIGHT
  /// =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Image.asset(
            'assets/icon/exam.png',
            height: 32,
          ),
        ),
        title: const Text(
          'Online Exam',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        actions: [
          // Teacher Unlock
          TextButton.icon(
            onPressed: unlockTeacher,
            icon: const Icon(Icons.lock_open_outlined,
                size: 20, color: Colors.white),
            label: const Text(
              'Unlock',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.green.shade600,
            ),
          ),
          const SizedBox(width: 6),
          // Finish Button
          TextButton.icon(
            onPressed: finishExam,
            icon: const Icon(Icons.check_circle_outline,
                size: 20, color: Colors.white),
            label: const Text(
              'Finish',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.redAccent.shade400,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: controller == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.blue),
              ),
            )
          : WebViewWidget(controller: controller!),
    );
  }
}
