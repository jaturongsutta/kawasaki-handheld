import 'package:flutter/material.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';

class KeyenceScannerTestPage extends StatefulWidget {
  const KeyenceScannerTestPage({super.key});

  @override
  State<KeyenceScannerTestPage> createState() => _KeyenceScannerTestPageState();
}

class _KeyenceScannerTestPageState extends State<KeyenceScannerTestPage> {
  String scannedCode = '';
  final GlobalKey<KeyenceScannerState> scannerKey = GlobalKey(); // ✅ key สำหรับเข้าถึง State
  @override
  void dispose() {
    scannerKey.currentState?.disposeStream(); // ✅ เรียกหยุดการฟังเมื่อปิดหน้า
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyence Scanner Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Last Scanned Code:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text(
              scannedCode.isEmpty ? 'No code scanned' : scannedCode,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
