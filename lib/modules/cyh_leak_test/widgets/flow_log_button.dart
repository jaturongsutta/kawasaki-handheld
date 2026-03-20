import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kmt/modules/cyh_leak_test/services/cyh_leak_test_flow_log_service.dart';
import 'package:path_provider/path_provider.dart';

class FlowLogButton extends StatelessWidget {
  const FlowLogButton({super.key});

  CYHLeakTestFlowLogService _resolveService() {
    if (Get.isRegistered<CYHLeakTestFlowLogService>()) {
      return Get.find<CYHLeakTestFlowLogService>();
    }
    return Get.put(CYHLeakTestFlowLogService(), permanent: true);
  }

  String _buildFileName() {
    final now = DateTime.now();
    String pad2(int v) => v.toString().padLeft(2, '0');
    return 'cyh_leak_flow_'
        '${now.year}${pad2(now.month)}${pad2(now.day)}_'
        '${pad2(now.hour)}${pad2(now.minute)}${pad2(now.second)}.txt';
  }

  Future<void> _saveLogsToAppExternalFiles(CYHLeakTestFlowLogService logService) async {
    if (logService.entries.isEmpty) {
      Get.snackbar('Flow Logs', 'No logs to save');
      return;
    }

    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        Get.snackbar('Flow Logs', 'Cannot resolve external files directory');
        return;
      }

      final fileName = _buildFileName();
      final file = File('${dir.path}/$fileName');
      final text = logService.entries.join('\n');
      await file.writeAsString(text, flush: true);

      Get.snackbar('Flow Logs', 'Saved: ${file.path}');
    } catch (e) {
      Get.snackbar('Flow Logs', 'Save failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final logService = _resolveService();
    return IconButton(
      tooltip: 'Flow Log',
      icon: const Icon(Icons.receipt_long_outlined),
      onPressed: () {
        Get.dialog(
          Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 900,
              height: 620,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Flow Logs',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _saveLogsToAppExternalFiles(logService),
                          icon: const Icon(Icons.save_alt, size: 18),
                          label: const Text('Save log'),
                        ),
                        IconButton(
                          onPressed: Get.back,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Obx(() {
                      if (logService.entries.isEmpty) {
                        return const Center(child: Text('No logs yet'));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: logService.entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (_, i) {
                          return SelectableText(
                            logService.entries[i],
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              fontFamily: 'monospace',
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
