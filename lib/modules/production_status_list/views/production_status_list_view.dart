/// 1. production_status_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../controllers/production_status_list_controller.dart';

class ProductionStatusListView extends GetView<ProductionStatusListController> {
  const ProductionStatusListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Production Status List')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            // _buildTitle('Production Status'),
            const SizedBox(height: 10),
            Obx(() => Column(
                  children: controller.statusList
                      .map((status) => _buildStatusCard(
                            line: status.line,
                            planDate: status.planDate,
                            shift: status.shift,
                            shiftTime: status.shiftTime,
                            ot: status.ot,
                            model: status.model,
                            status: status.status,
                            statusColor: status.status == 'Running' ? Colors.blue : Colors.black,
                            statusBold: status.status != 'Running',
                          ))
                      .toList(),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String line,
    required String planDate,
    required String shift,
    required String shiftTime,
    required String ot,
    required String model,
    required String status,
    required Color statusColor,
    required bool statusBold,
  }) {
    return InkWell(
      onTap: () async {
        // await
        // print('1');
        await EasyLoading.show(maskType: EasyLoadingMaskType.black);
        await Future.delayed(const Duration(seconds: 2));

        Get.toNamed('/production-status-manage');
        await EasyLoading.dismiss();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          children: [
            _buildRow('Line', line),
            _buildRow('Plan Date', planDate),
            _buildRow('Shift', shift),
            _buildRow('Shift Time', shiftTime),
            _buildRow('OT', ot),
            _buildRow('Model', model),
            _buildRow('Status', status, color: statusColor, isBold: statusBold),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
