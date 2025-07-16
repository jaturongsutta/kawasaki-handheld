import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kmt/global_widgets/header_kmt.dart';
import 'package:kmt/modules/menu_two/controllers/menu_two_controller.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';

class MenuTwoView extends StatefulWidget {
  const MenuTwoView({super.key});

  @override
  State<MenuTwoView> createState() => _MenuTwoViewState();
}

class _MenuTwoViewState extends State<MenuTwoView> {
  final GlobalKey<KeyenceScannerState> scannerKey = GlobalKey();

  @override
  void dispose() {
    // หยุด Scanner เมื่อหน้านี้ถูกปิดจริง ๆ
    scannerKey.currentState?.stopSensorReader();
    print('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const buttonWidth = 250.0;
    const buttonHeight = 60.0;
    final controller = Get.find<MenuTwoController>();

    return KeyenceScanner(
      key: scannerKey,
      onBarcodeScanned: (code) {
        print('code==>> $code');
        switch (code) {
          case 'H1001':
            if (controller.hasMenu('H1001')) {
              Get.toNamed('/production-status');
            }
            break;

          case 'H1002':
            if (controller.hasMenu('H1002')) {
              Get.toNamed('/ng-information');
            }
            break;

          case 'H1003':
            Get.toNamed('/line-stop-information');
            break;

          default:
            Get.snackbar('Invalid Code', 'ไม่พบเมนูสำหรับรหัสนี้');
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const KawasakiHeader(notificationCount: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFixedSizeButton("Production Status", buttonWidth, buttonHeight,
                    () => Get.toNamed('/production-status')),
                const SizedBox(height: 16),
                _buildFixedSizeButton(
                    "NG Records", buttonWidth, buttonHeight, () => Get.toNamed('/ng-information')),
                const SizedBox(height: 16),
                _buildFixedSizeButton("Line Stop Records", buttonWidth, buttonHeight,
                    () => Get.toNamed('/line-stop-information')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  final box = Get.find<GetStorage>();
                  box.erase();
                  Get.offAllNamed('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedSizeButton(String text, double width, double height, VoidCallback onPressed) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.black, width: 1),
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
