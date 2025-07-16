import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

late final Logger logger;

// 🛠 เพิ่ม Printer ที่ใส่ Timestamp
class TimeStampedPrinter extends LogPrinter {
  final LogPrinter realPrinter;

  TimeStampedPrinter(this.realPrinter);

  @override
  List<String> log(LogEvent event) {
    final now = DateTime.now();
    final timestamp = '[${now.toIso8601String().replaceFirst('T', ' ').split('.').first}]';
    final lines = realPrinter.log(event);
    return lines.map((line) => '$timestamp $line').toList();
  }
}

class MultiOutput extends LogOutput {
  final LogOutput consoleOutput;
  final LogOutput fileOutput;

  MultiOutput({required this.consoleOutput, required this.fileOutput});

  @override
  void output(OutputEvent event) {
    consoleOutput.output(event);
    fileOutput.output(event);
  }
}

// 🛠 FileOutput ที่แยกไฟล์ตามวัน
class FileLogOutput extends LogOutput {
  late final Future<File> _logFile;

  FileLogOutput() {
    _logFile = _initLogFile();
  }

  Future<File> _initLogFile() async {
    final directory =
        await getExternalStorageDirectory(); // ✅ เปลี่ยนจาก getApplicationDocumentsDirectory
    final now = DateTime.now();
    final formattedDate = '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}';
    final fileName = 'log_$formattedDate.txt';

    final path =
        directory!.path; // เช่น /storage/self/primary/Android/data/com.example.bmt_mobile/files
    final file = File('$path/$fileName');

    logger.i('📂 Log file will be saved at: $path/$fileName'); // ดู path ตอนรัน

    return file;
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  void output(OutputEvent event) async {
    final file = await _logFile;
    for (var line in event.lines) {
      await file.writeAsString('$line\n', mode: FileMode.append, encoding: utf8);
    }
  }
}

Future<void> setupLogger() async {
  logger = Logger(
      printer: TimeStampedPrinter(PrettyPrinter(
        methodCount: 5, // อยากให้เห็น StackTrace กี่บรรทัด (เพิ่มได้)
        errorMethodCount: 5,
        lineLength: 120,
        colors: false, // ไม่ต้องมีสี (จะได้อ่านง่ายในไฟล์)
        printEmojis: kDebugMode,
      )),
      output: MultiOutput(
        consoleOutput: ConsoleOutput(), // พิมพ์ออก Console เหมือนเดิม
        fileOutput: FileLogOutput(), // พิมพ์ลงไฟล์ด้วย
      ),
      level: Level.debug // <<< ตรงนี้สำคัญ! ระบุ Level.verbose แม้ Release
      );
  logger.i('🔔 Logger setup complete: Running in ${kReleaseMode ? 'RELEASE' : 'DEBUG'} mode');
}
