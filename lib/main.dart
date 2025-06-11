import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:kmt/modules/alert/controllers/alert_controller.dart';
import 'package:kmt/routes/app_pages.dart';
import 'package:kmt/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const MethodChannel _methodChannel = MethodChannel('factory_alert_service');
  static const EventChannel _eventChannel = EventChannel('factory_alert_event');

  @override
  void initState() {
    super.initState();
    _startService();
    _listenForAlerts();
  }

  void _startService() async {
    try {
      await _methodChannel.invokeMethod('startService');
      print("✅ Service started");
    } on PlatformException catch (e) {
      print("❌ ไม่สามารถเริ่ม Service: ${e.message}");
    }
  }

  void _listenForAlerts() {
    _eventChannel.receiveBroadcastStream().listen((event) {
      final alertController = Get.put(AlertController(), permanent: true);
      alertController.addAlert(event.toString());
      print("📥 รับแจ้งเตือน: $event");
    }, onError: (err) {
      print("❌ รับข้อความผิดพลาด: $err");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: EasyLoading.init(),
      title: 'KMT GetX App',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.menuTwo,
      getPages: AppPages.routes,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Arial',
        primaryColor: const Color(0xFF6CC24A),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF6CC24A),
          secondary: const Color(0xFFC8102E),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6CC24A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF6CC24A), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        focusColor: const Color.fromARGB(82, 108, 194, 74),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14),
          labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
