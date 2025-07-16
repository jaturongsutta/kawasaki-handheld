import 'package:flutter/services.dart';

class EnterKeyChannelManager {
  static const MethodChannel _channel = MethodChannel('EnterkeyChannel');

  static void setupMethodChannel(Future<dynamic> Function(MethodCall)? methodCallHandler) {
    _channel.setMethodCallHandler(methodCallHandler);
  }

  static void disposeMethodChannel() {
    _channel.setMethodCallHandler(null);
  }
}
