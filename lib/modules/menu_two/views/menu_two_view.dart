import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kmt/modules/menu_two/controllers/menu_two_controller.dart';

class MenuTwoView extends GetView<MenuTwoController> {
  const MenuTwoView({super.key});

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: SafeArea(
    //     child: const KawasakiHeader(
    //       notificationCount: 10,
    //     ),
    //   ),
    // );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: 100,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/header.jpg'), // <-- เปลี่ยนตาม path
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Color.fromARGB(129, 255, 255, 255),
              height: 100,
            ),
            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              children: [
                // 🔧 Header Image + Title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        // 🟢 ขอบ (border)
                        Text(
                          'Production Line',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = Colors.white, // สีขอบเขียว
                          ),
                        ),
                        // ⚪ ตัวอักษรสีด้านใน
                        const Text(
                          'Production Line',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // หรือเปลี่ยนเป็นดำก็ได้
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Stack(
                      children: [
                        // 🟢 ขอบ (border)
                        Text(
                          'Production Recording',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = Colors.white, // สีขอบเขียว
                          ),
                        ),
                        // ⚪ ตัวอักษรสีด้านใน
                        const Text(
                          'Production Recording',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // หรือเปลี่ยนเป็นดำก็ได้
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 🔽 Line Dropdown
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedLine.value,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF6CC24A), width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: controller.lineOptions
                        .map((line) => DropdownMenuItem(value: line, child: Text(line)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) controller.selectedLine.value = value;
                    },
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ Menu List
                _menuTile(
                  icon: Icons.play_arrow,
                  iconColor: Colors.green,
                  label: 'Production Status',
                  onTap: () => Get.toNamed('/production-status'),
                ),
                _menuTile(
                  icon: Icons.inventory,
                  iconColor: Colors.grey.shade800,
                  label: 'NG Records',
                  onTap: () => Get.toNamed('/ng-information'),
                ),
                _menuTile(
                  icon: Icons.report_problem,
                  iconColor: Colors.red.shade400,
                  label: 'Line Stop Records',
                  onTap: () => Get.toNamed('/line-stop-information'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 28, color: iconColor),
      ),
      title: Text(label, style: const TextStyle(fontSize: 18)),
      onTap: onTap,
    );
  }
}
