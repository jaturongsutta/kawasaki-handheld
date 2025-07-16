import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardButtons extends StatelessWidget {
  final bool canViewProductionStatus;
  final bool canViewNgRecords;
  final bool canViewLineStop;

  const DashboardButtons({
    super.key,
    required this.canViewProductionStatus,
    required this.canViewNgRecords,
    required this.canViewLineStop,
  });

  @override
  Widget build(BuildContext context) {
    // กำหนดขนาดปุ่มกลางๆ เท่ากันหมด
    const buttonWidth = 250.0;
    const buttonHeight = 60.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (canViewProductionStatus)
          _buildFixedSizeButton("Production Status", buttonWidth, buttonHeight,
              () => Get.toNamed('/production-status')),
        const SizedBox(height: 16),
        if (canViewNgRecords)
          _buildFixedSizeButton(
              "NG Records", buttonWidth, buttonHeight, () => Get.toNamed('/ng-information')),
        const SizedBox(height: 16),
        if (canViewLineStop)
          _buildFixedSizeButton("Line Stop Records", buttonWidth, buttonHeight,
              () => Get.toNamed('/line-stop-information')),
      ],
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
            side: const BorderSide(color: Colors.black, width: 1), // ✅ ขอบสีดำ
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
