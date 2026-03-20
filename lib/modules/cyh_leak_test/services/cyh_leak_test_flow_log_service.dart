import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class CYHLeakTestFlowLogService extends GetxService {
  static const _maxEntries = 500;
  final entries = <String>[].obs;

  void restart(String reason, {Map<String, dynamic>? data}) {
    entries.clear();
    final payload = <String, dynamic>{'reason': reason};
    if (data != null) payload.addAll(data);
    add('SYSTEM', 'restart', data: payload);
  }

  void add(String source, String step, {Map<String, dynamic>? data}) {
    final payload = data == null ? '' : ' | $data';
    _push('[${_timeNow()}][$source][$step]$payload');
  }

  void addError(
    String source,
    String step,
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? data,
  }) {
    final payload = data == null ? '' : ' | $data';
    _push('[${_timeNow()}][$source][$step][ERROR] $error$payload');
    _push(stackTrace.toString());
  }

  void clearLogs() {
    entries.clear();
  }

  String _timeNow() {
    final now = DateTime.now();
    String pad2(int v) => v.toString().padLeft(2, '0');
    final ms = now.millisecond.toString().padLeft(3, '0');
    return '${pad2(now.hour)}:${pad2(now.minute)}:${pad2(now.second)}.$ms';
  }

  void _push(String line) {
    entries.add(line);
    if (entries.length > _maxEntries) {
      entries.removeRange(0, entries.length - _maxEntries);
    }
    debugPrint(line);
  }
}
