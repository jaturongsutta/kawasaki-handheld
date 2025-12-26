import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kmt/widgets/KeyenceScanner.dart';
import '../controllers/cyh_no_plan_controller.dart';

class CYHNoPlanView extends GetView<CYHNoPlanController> {
  const CYHNoPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5FB),
        appBar: AppBar(
          title: const Text('No Plan',
              style: TextStyle(fontWeight: FontWeight.w700)),
          centerTitle: true,
          bottom: TabBar(
            controller: controller.tabController,
            tabs: const [
              Tab(text: 'Records'),
              Tab(text: 'Historical'),
            ],
          ),
        ),
        body: TabBarView(
          controller: controller.tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _RecordTab(controller: controller, theme: theme),
            const _HistoryTab(),
          ],
        ),
      ),
    );
  }
}

class _RecordTab extends StatelessWidget {
  const _RecordTab({
    super.key,
    required this.controller,
    required this.theme,
  });

  final CYHNoPlanController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return KeyenceScanner(
        onBarcodeScanned: (String scannedCode) {
          controller.scanQrForMachine(scannedCode);
        },
        onEnterPressed: () => controller.goToForm(),
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
                                      value: m.value,
                                      child: Text(m.title ?? ''),
                                    ))
                                .toList(),
                            onChanged: (val) => {
                              controller.selectedMachineNo.value = val,
                              controller.checkMachine()
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
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
                        onPressed: controller.isEnabled.value
                            ? controller.goToForm
                            : null,
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
    });
  }
}

class _HistoryTab extends GetView<CYHNoPlanController> {
  const _HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    TextStyle labelGrey = const TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.w500,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Date',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF3D7BFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 100),
              Expanded(
                child: Obx(
                  () => InkWell(
                    onTap: () => controller.pickHistoryDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(controller.historyDateDisplay),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final lineCd = controller.currentLineCd;
            final totalLoss = controller.historyTotalLoss.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'Line',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          lineCd,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Total Loss Time: ${totalLoss.toStringAsFixed(0)} min',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 8),
              ],
            );
          }),
          const Divider(),
          Expanded(
            child: Obx(() {
              if (controller.isHistoryLoading.value &&
                  controller.historyItems.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.historyItems.isEmpty) {
                return const Center(child: Text('No data'));
              }

              final items = controller.historyItems;
              final hasMore = controller.historyHasMore.value;

              return ListView.separated(
                controller: controller.historyScrollController,
                itemCount: items.length + (hasMore ? 1 : 0),
                separatorBuilder: (_, index) {
                  if (index >= items.length) return const SizedBox.shrink();
                  return const Divider();
                },
                itemBuilder: (_, i) {
                  if (i >= items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final item = items[i];
                  final startDT = DateTime.parse(item.startDateTimeRaw);
                  final endDT = DateTime.parse(item.endDateTimeRaw);
                  final fmt = DateFormat('dd/MM/yyyy HH:mm');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Machine', style: labelGrey),
                          const SizedBox(width: 16),
                          Text(
                            item.machineNo,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Start Date Time', style: labelGrey),
                          const SizedBox(width: 16),
                          Text(
                            fmt.format(startDT),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('End Date Time', style: labelGrey),
                          const SizedBox(width: 16),
                          Text(
                            fmt.format(endDT),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Loss Time', style: labelGrey),
                          const SizedBox(width: 16),
                          Text(
                            item.lossTime.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'min',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
