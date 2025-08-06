import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyenceScanner extends StatefulWidget {
  final void Function(String) onBarcodeScanned;
  final Widget child;

  const KeyenceScanner({
    super.key,
    required this.onBarcodeScanned,
    required this.child,
  });

  @override
  KeyenceScannerState createState() => KeyenceScannerState();
}

class KeyenceScannerState extends State<KeyenceScanner> {
  StreamSubscription? streamSubscription;
  static const eventChannel = EventChannel('SensorReader');
  final MethodChannel methodChannel = const MethodChannel('KeyenceChannel');

  @override
  void initState() {
    super.initState();
    initSensorReader();
  }

  @override
  void dispose() {
    disposeStream();
    super.dispose();
  }

  void disposeStream() {
    if (streamSubscription != null) {
      streamSubscription?.cancel();
      streamSubscription = null;
      print("🧹 Scanner stream cancelled");
    } else {
      print("⚠️ No active stream to cancel");
    }
  }

  Future<void> stopSensorReader() async {
    try {
      await methodChannel.invokeMethod('stopSensor');
      debugPrint('🛑 Sensor stopped via native');
    } catch (e) {
      debugPrint('❌ Failed to stop sensor: $e');
    }
  }

  /// ✅ เรียกเพื่อเปิด stream ใหม่
  Future<void> initSensorReader() async {
    disposeStream(); // ป้องกัน subscribe ซ้ำซ้อน

    print('🎬 Scanner stream subscribing...');
    streamSubscription = eventChannel.receiveBroadcastStream().listen((event) {
      final String data = event.toString();
      print('📡 event ===> $event');
      widget.onBarcodeScanned(data);
    });

    // เปิด hardware scanner
    try {
      await methodChannel.invokeMethod('initializeSensor');
    } catch (e) {
      print('❌ Failed to initialize sensor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
