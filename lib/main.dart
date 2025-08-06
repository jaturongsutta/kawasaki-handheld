import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kmt/modules/alert/controllers/notification_controller.dart';
import 'package:kmt/modules/login/controllers/login_controller.dart';
import 'package:kmt/routes/app_pages.dart';
import 'package:kmt/routes/app_routes.dart';
import 'package:kmt/services/inject.dart';
import 'package:kmt/widgets/customLog.dart';
import 'package:kmt/widgets/setupDialogUi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLogger();
  configureInjection();
  setupDialogUi();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await GetStorage.init();
  Get.put(GetStorage());
  Get.put(LoginController());
  Get.put(NotificationController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const EventChannel _eventChannel = EventChannel('factory_alert_event');
  final MethodChannel methodChannel = const MethodChannel('KeyenceChannel');
  static const MethodChannel _navigateChannel = MethodChannel('navigate_channel');

  @override
  void initState() {
    super.initState();
    _listenForAlerts();
    _navigateChannel.setMethodCallHandler((call) async {
      if (call.method == 'goToNotification') {
        Get.toNamed(AppRoutes.alert); // ✅ route ที่เปิด Notification List
      }
    });
    initSensorReader();
  }

  Future<void> initSensorReader() async {
    return await methodChannel.invokeMethod('initializeSensor');
  }

  void _listenForAlerts() {
    _eventChannel.receiveBroadcastStream().listen((event) {
      // final alertController = Get.put(NotificationController(), permanent: true);
      // alertController.addAlert(event.toString());
      print("📥 รับแจ้งเตือน: $event");
    }, onError: (err) {
      print("❌ รับข้อความผิดพลาด: $err");
    });
  }

  Future<void> setupLoggerAndErrorHandling() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      logger.e('Flutter Error', error: details.exception, stackTrace: details.stack);
      FlutterError.presentError(details);
    };

    runZonedGuarded(() {
      // ไม่ต้องทำอะไร เพราะ runApp เรียกไปแล้ว
    }, (error, stackTrace) {
      logger.e('Zone Error', error: error, stackTrace: stackTrace);
    }, zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        logger.i(line);
        parent.print(zone, line);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: EasyLoading.init(),
      title: 'KMT',
      debugShowCheckedModeBanner: false,
      // initialRoute: AppRoutes.menuTwo,
      initialRoute: AppRoutes.splash,
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
