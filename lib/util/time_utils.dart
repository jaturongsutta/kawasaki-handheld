// lib/utils/time_utils.dart
import 'package:intl/intl.dart';

class TimeUtils {
  /// คืนค่าเวลาแบบ "HH:mm" จากสตริงเวลา/วันที่หลากหลายรูปแบบ
  /// รองรับ: ISO 8601 (เช่น "1970-01-01T20:00:00.000Z"), "HH:mm:ss", "HH:mm",
  /// และเลขล้วน "HHmm" / "HHmmss" (เช่น "1228", "122810")
  static String toHhmm(String? input, {bool useLocal = false, String fallback = '-'}) {
    if (input == null) return fallback;
    final t = input.trim();
    if (t.isEmpty) return fallback;

    try {
      // กรณีเป็น ISO datetime (มี 'T' หรือมี '-' บ่งบอกวันที่)
      if (t.contains('T') || t.contains('-')) {
        final dt = DateTime.parse(t);
        final base = useLocal ? dt.toLocal() : dt.toUtc();
        return DateFormat('HH:mm').format(base);
      }

      // ไม่ใช่ ISO → normalize ให้เป็น HH:mm:ss ก่อน
      final normalized = _normalizeToHHmmss(t);
      final parsed = DateFormat('HH:mm:ss').parseStrict(normalized); // วันที่ dummy
      return DateFormat('HH:mm').format(parsed);
    } catch (_) {
      return fallback;
    }
  }

  /// แปลง "HH:mm" → "HH:mm:ss" / "HHmm" → "HH:mm:00" / "HHmmss" → "HH:mm:ss"
  static String _normalizeToHHmmss(String raw) {
    final r = raw.replaceAll(' ', '');

    if (r.contains(':')) {
      final parts = r.split(':');
      if (parts.length == 2) return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:00';
      if (parts.length >= 3) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:${parts[2].padLeft(2, '0')}';
      }
    }

    // เลขล้วน
    final digits = r.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 4) {
      return '${digits.substring(0, 2)}:${digits.substring(2, 4)}:00';
    }
    if (digits.length == 6) {
      return '${digits.substring(0, 2)}:${digits.substring(2, 4)}:${digits.substring(4, 6)}';
    }

    throw const FormatException('Unsupported time format');
  }
}
