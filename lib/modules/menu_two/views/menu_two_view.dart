import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kmt/global_widgets/header_kmt.dart';
import 'package:kmt/modules/alert/controllers/notification_controller.dart';
import 'package:kmt/modules/line_stop_information/controllers/line_stop_information_controller.dart';
import 'package:kmt/modules/menu_two/controllers/menu_two_controller.dart';
import 'package:kmt/modules/ng_information/controllers/ng_information_controller.dart';
import 'package:kmt/modules/production_status_list/controllers/production_status_list_controller.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';
import 'package:kmt/widgets/controller/loadingcontroller.dart';
import 'package:kmt/widgets/globalLoading.dart';

class MenuTwoView extends StatefulWidget {
  const MenuTwoView({super.key});

  @override
  State<MenuTwoView> createState() => _MenuTwoViewState();
}

class _MenuTwoViewState extends State<MenuTwoView> {
  final GlobalKey<KeyenceScannerState> scannerKey = GlobalKey();
  final loadingController = Get.put(LoadingController());
  final controller = Get.find<MenuTwoController>();
  final notificationController = Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    notificationController.loadNotifications(reset: true);
  }

  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const buttonWidth = 250.0;
    const buttonHeight = 60.0;

    return KeyenceScanner(
      key: scannerKey,
      onBarcodeScanned: (scannedCode) {
        print('menu page');
        String codeToCheck;
        if (scannedCode.contains('|')) {
          final parts = scannedCode.split('|');
          if (parts.length >= 2) {
            codeToCheck = parts[0];
            if (codeToCheck == "NG") {
              controller.selectedNGTempProcess.value = parts[1];
              controller.selectedNGTempReason.value = parts[2];
            }
            if (codeToCheck == "LS") {
              controller.selectedLineTempProcess.value = parts[1];
              controller.selectedLineTempReason.value = parts[2];
            }
          } else {
            codeToCheck = scannedCode;
          }
        } else {
          codeToCheck = scannedCode;
        }
        switch (codeToCheck) {
          case 'H1001':
            loadingController.showLoading();
            Get.toNamed('/production-status')?.then((_) async {
              await Future.delayed(const Duration(seconds: 1));
              loadingController.hideLoading();
              Get.delete<ProductionStatusController>();

              scannerKey.currentState?.initSensorReader();
            });
            break;

          case 'NG':
            loadingController.showLoading();
            Get.toNamed('/ng-information')?.then((_) async {
              await Future.delayed(const Duration(seconds: 1));
              loadingController.hideLoading();
              Get.delete<NgInformationController>();

              scannerKey.currentState?.initSensorReader();
            });
            break;

          case 'LS':
            loadingController.showLoading();
            Get.toNamed('/line-stop-information')?.then((_) async {
              await Future.delayed(const Duration(seconds: 1));
              loadingController.hideLoading();
              Get.delete<LineStopInformationController>();

              scannerKey.currentState?.initSensorReader();
            });
            break;

          default:
            Get.snackbar('Invalid Code', 'ไม่พบเมนูสำหรับรหัสนี้');
        }
      },
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => KawasakiHeader(
                    notificationCount: notificationController.unread.value,
                  )),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildFixedSizeButton("Production Status", buttonWidth, buttonHeight, () {
                      loadingController.showLoading();
                      Get.toNamed('/production-status')?.then((_) async {
                        await Future.delayed(const Duration(seconds: 1));
                        loadingController.hideLoading();
                        Get.delete<ProductionStatusController>();

                        scannerKey.currentState?.initSensorReader();
                      });
                    }),
                    const SizedBox(height: 16),
                    _buildFixedSizeButton("NG Records", buttonWidth, buttonHeight, () {
                      loadingController.showLoading();
                      Get.toNamed('/ng-information')?.then((_) async {
                        await Future.delayed(const Duration(seconds: 1));
                        loadingController.hideLoading();
                        Get.delete<NgInformationController>();

                        scannerKey.currentState?.initSensorReader();
                      });
                    }),
                    const SizedBox(height: 16),
                    _buildFixedSizeButton("Line Stop Records", buttonWidth, buttonHeight, () {
                      loadingController.showLoading();
                      Get.toNamed('/line-stop-information')?.then((_) async {
                        await Future.delayed(const Duration(seconds: 1));
                        loadingController.hideLoading();
                        Get.delete<LineStopInformationController>();

                        scannerKey.currentState?.initSensorReader();
                      });
                    }),
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
          const GlobalLoading(),
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
