import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kmt/routes/app_routes.dart';
import 'package:kmt/services/base_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    await Future.delayed(
        const Duration(seconds: 2)); // แสดง Splash อย่างน้อย 2 วิ

    final hasSession = await baseService.restoreSessionFromStorage();
    if (!mounted) {
      return;
    }
    if (hasSession) {
      Get.offAllNamed(AppRoutes.menu); // ✅ ไปหน้าเมนู
    } else {
      Get.offAllNamed(AppRoutes.login); // ✅ ไปหน้า login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/icons/app_icon.png', // ✅ เปลี่ยน path ให้ตรง
          width: 150,
        ),
      ),
    );
  }
}
