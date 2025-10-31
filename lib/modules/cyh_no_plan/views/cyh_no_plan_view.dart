import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';
import '../controllers/cyh_no_plan_controller.dart';

class CYHNoPlanView extends GetView<CYHNoPlanController> {
  const CYHNoPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FB),
      appBar: AppBar(
        title: const Text('No Plan', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Obx(() {
        return KeyenceScanner(
          onBarcodeScanned: (String scannedCode) {
            controller.scanQrForMachine(scannedCode);
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 82,
                            child: Text(
                              'Machine',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: controller.selectedMachineNo.value,
                              items: controller.machines
                                  .map((m) => DropdownMenuItem<String>(
                                        value: m.machineNo,
                                        child: Text(m.machineNo),
                                      ))
                                  .toList(),
                              onChanged: (val) => controller.selectedMachineNo.value = val,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                          // const SizedBox(width: 8),
                          // IconButton(
                          //   onPressed: controller.scanQrForMachine,
                          //   icon: const Icon(Icons.qr_code_2_rounded),
                          //   tooltip: 'Scan QR',
                          // ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 44,
                        child: FilledButton(
                          onPressed: controller.goToForm,
                          child: const Text('Confirm'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.isLoading.value)
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
            ],
          ),
        );
      }),
    );
  }
}
