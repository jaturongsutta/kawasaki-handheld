import 'package:flutter/material.dart';

enum WorkTab { Production, Master }

class WorkTypeSelector extends StatelessWidget {
  final WorkTab value;
  final ValueChanged<WorkTab> onChanged;
  final String label;
  final double radius;

  const WorkTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Work Type',
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(radius),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label ด้านบน
          Padding(
            padding: const EdgeInsets.only(left: 0, bottom: 6),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),

          // แถบเทาอ่อนครอบปุ่ม (เต็มความกว้าง + โค้งเท่ากรอบนอก)
          Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias, // << สำคัญ: ตัดขอบให้โค้งเท่ากัน
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
            decoration: BoxDecoration(
              color: const Color(0xFFE6E6E6),
              borderRadius: BorderRadius.circular(radius), // << โค้งเท่ากรอบนอก
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final segmentWidth = constraints.maxWidth / 2; // 2 ปุ่ม
                return SegmentedButton<WorkTab>(
                  segments: [
                    ButtonSegment(
                      value: WorkTab.Production,
                      label: SizedBox(
                        width: segmentWidth,
                        child: const Center(child: Text('Production')),
                      ),
                    ),
                    ButtonSegment(
                      value: WorkTab.Master,
                      label: SizedBox(
                        width: segmentWidth,
                        child: const Center(child: Text('Master')),
                      ),
                    ),
                  ],
                  selected: {value},
                  onSelectionChanged: (s) =>
                      onChanged(s.first), // << event ออกไป

                  showSelectedIcon: false,
                  style: ButtonStyle(
                    // ทำให้พื้นหลังของ segment ที่ "ไม่ถูกเลือก" โปร่งใส
                    // จะเห็นเป็นพื้นเทาอ่อนของ container
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white; // ปุ่มที่ถูกเลือกเป็นสีขาว
                      }
                      return Colors.transparent;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.green; // สีตัวอักษรปุ่มที่เลือก
                      }
                      return Colors.grey[700];
                    }),
                    side: WidgetStateProperty.all(
                      const BorderSide(color: Colors.transparent),
                    ),
                    // โค้ง "เท่ากับ" กรอบนอก เพื่อไม่ให้ดูหลุดทรง
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
