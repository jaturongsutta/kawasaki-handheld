import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final RouteObserver<ModalRoute<void>> keyenceScannerRouteObserver =
    RouteObserver<ModalRoute<void>>();

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

class KeyenceScannerState extends State<KeyenceScanner> with RouteAware {
  static const eventChannel = EventChannel('SensorReader');
  static const MethodChannel _methodChannel = MethodChannel('KeyenceChannel');

  static StreamSubscription? _sharedStreamSubscription;
  static final Map<int, void Function(String)> _handlersBySession = {};
  static int? _activeSessionId;
  static int _sessionSeed = 0;

  int _sessionId = 0;
  ModalRoute<dynamic>? _route;

  // ✅ โฟกัสสำหรับจับ hardkey
  final FocusNode _focusNode = FocusNode(debugLabel: 'KeyenceScannerFocus');

  @override
  void initState() {
    super.initState();
    _sessionId = ++_sessionSeed;
    _handlersBySession[_sessionId] = widget.onBarcodeScanned;
    initSensorReader();
  }

  @override
  void didUpdateWidget(covariant KeyenceScanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handlersBySession[_sessionId] = widget.onBarcodeScanned;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && _route != route) {
      if (_route != null) {
        keyenceScannerRouteObserver.unsubscribe(this);
      }
      _route = route;
      keyenceScannerRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPush() {
    initSensorReader();
  }

  @override
  void didPopNext() {
    initSensorReader();
  }

  @override
  void didPushNext() {
    disposeStream();
  }

  @override
  void didPop() {
    disposeStream();
  }

  @override
  void dispose() {
    keyenceScannerRouteObserver.unsubscribe(this);
    _handlersBySession.remove(_sessionId);
    disposeStream();
    _focusNode.dispose(); // ✅ เพิ่ม
    super.dispose();
  }

  static Future<void> _initializeSensor() async {
    try {
      await _methodChannel.invokeMethod('initializeSensor');
    } catch (e) {
      // ignore: avoid_print
      print('❌ Failed to initialize sensor: $e');
    }
  }

  static Future<void> _stopSensor() async {
    try {
      await _methodChannel.invokeMethod('stopSensor');
      debugPrint('🛑 Sensor stopped via native');
    } catch (e) {
      debugPrint('⚠️ Ignore sensor stop error: $e');
    }
  }

  static Future<void> _shutdownIfInactive() async {
    if (_activeSessionId != null) return;
    final sub = _sharedStreamSubscription;
    _sharedStreamSubscription = null;
    if (sub != null) {
      await sub.cancel().catchError((e) {
        debugPrint('⚠️ Ignore scanner cancel error: $e');
      });
      // ignore: avoid_print
      print('🧹 Scanner stream cancelled');
    }
    await _stopSensor();
  }

  void disposeStream() {
    if (_activeSessionId == _sessionId) {
      _activeSessionId = null;
      // ignore: avoid_print
      print("🧹 Scanner handler detached");
    }
    _shutdownIfInactive();
  }

  Future<void> stopSensorReader() async {
    await _stopSensor();
  }

  /// ✅ เรียกเพื่อเปิด stream ใหม่
  Future<void> initSensorReader() async {
    _activeSessionId = _sessionId;
    _handlersBySession[_sessionId] = widget.onBarcodeScanned;

    if (_sharedStreamSubscription == null) {
      // ignore: avoid_print
      print('🎬 Scanner stream subscribing...');
      _sharedStreamSubscription =
          eventChannel.receiveBroadcastStream().listen((event) {
        final String data = event.toString();
        // ignore: avoid_print
        print('📡 event ===> $event');
        final activeSession = _activeSessionId;
        if (activeSession == null) return;
        _handlersBySession[activeSession]?.call(data);
      }, onError: (error) {
        debugPrint('❌ Scanner stream error: $error');
      }, onDone: () {
        _sharedStreamSubscription = null;
        debugPrint('ℹ️ Scanner stream closed');
      });
    } else {
      // ignore: avoid_print
      print('♻️ Scanner stream already active, switched handler');
    }

    await _initializeSensor();
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
