import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/production_status_manage_controller.dart';

class ProductionStatusManageView extends GetView<ProductionStatusManageController> {
  const ProductionStatusManageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Production Status Manage')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black26),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _row('Line', 'Cylinder Head 6'),
                _row('Plan Date', '03/04/2025 08:00'),
                _row('Shift', 'Team A'),
                _row('Shift Time', 'Day (08:00 - 20:00)'),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('OT', style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(
                      height: 45,
                      width: 80,
                      child: DropdownButtonFormField<String>(
                        value: controller.selectedOt.value,
                        items: controller.otOptions
                            .map((item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) controller.selectedOt.value = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: controller.setOt,
                        child: const Text('Set'),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                _row('Model', 'EX400'),
                _row('Cycle Time', '10 mins'),
                _row('Part Name', 'Cylinder Head XX'),
                _row('Part No', '11001-5031'),
                _row('Part Upper', '10001-00031'),
                _row('Part Lower', '10001-0231'),
                _row('Man Power', '1 person'),
                _row('Status', 'Running', color: Colors.blue, isBold: true),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: Get.back,
                      child: const Text('Stop'),
                    ),
                    ElevatedButton(
                      onPressed: Get.back,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 196, 196, 196),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Back'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w400)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: isBold ? FontWeight.bold : FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
