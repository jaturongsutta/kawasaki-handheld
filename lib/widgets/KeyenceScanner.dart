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
    _initializeMethodChannel();
  }

  @override
  void dispose() {
    disposeStream();
    super.dispose();
  }

  void disposeStream() {
    streamSubscription?.cancel();
    print("🧹 Scanner stream cancelled");
  }

  Future<void> stopSensorReader() async {
    try {
      await methodChannel.invokeMethod('stopSensor');
      debugPrint('🛑 Sensor stopped via native');
    } catch (e) {
      debugPrint('❌ Failed to stop sensor: $e');
    }
  }

  Future<void> initSensorReader() async {
    return await methodChannel.invokeMethod('initializeSensor');
  }

  Future<void> _initializeMethodChannel() async {
    try {
      print('initializeMethodChannel');
      streamSubscription = eventChannel.receiveBroadcastStream().listen((event) {
        final String data = event.toString();
        print('event ===>$event');
        widget.onBarcodeScanned(data);
      });
    } on PlatformException catch (e) {
      print('Failed to invoke method: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
