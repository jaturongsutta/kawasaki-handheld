import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyenceScanner extends StatefulWidget {
  final void Function(String) onBarcodeScanned;
  final VoidCallback? onEnterPressed; // ✅ เพิ่ม
  final Widget child;

  const KeyenceScanner({
    super.key,
    required this.onBarcodeScanned,
    required this.child,
    this.onEnterPressed,
  });

  @override
  KeyenceScannerState createState() => KeyenceScannerState();
}

class KeyenceScannerState extends State<KeyenceScanner> {
  StreamSubscription? streamSubscription;
  static const eventChannel = EventChannel('SensorReader');
  final MethodChannel methodChannel = const MethodChannel('KeyenceChannel');

  // ✅ โฟกัสสำหรับจับ hardkey
  final FocusNode _focusNode = FocusNode(debugLabel: 'KeyenceScannerFocus');

  @override
  void initState() {
    super.initState();
    initSensorReader();
  }

  @override
  void dispose() {
    disposeStream();
    _focusNode.dispose(); // ✅ เพิ่ม
    super.dispose();
  }

  void disposeStream() {
    if (streamSubscription != null) {
      streamSubscription?.cancel();
      streamSubscription = null;
      // ignore: avoid_print
      print("🧹 Scanner stream cancelled");
    } else {
      // ignore: avoid_print
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

    // ignore: avoid_print
    print('🎬 Scanner stream subscribing...');
    streamSubscription = eventChannel.receiveBroadcastStream().listen((event) {
      final String data = event.toString();
      // ignore: avoid_print
      print('📡 event ===> $event');
      widget.onBarcodeScanned(data);
    });

    // เปิด hardware scanner
    try {
      await methodChannel.invokeMethod('initializeSensor');
    } catch (e) {
      // ignore: avoid_print
      print('❌ Failed to initialize sensor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ครอบด้วย Focus เพื่อจับ Enter hardkey
    return Focus(
      autofocus: true,
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        // จับเฉพาะตอนกดลง (กันยิงซ้ำตอนปล่อย)
        if (event is KeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.enter ||
              key == LogicalKeyboardKey.numpadEnter) {
            widget.onEnterPressed?.call();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}
