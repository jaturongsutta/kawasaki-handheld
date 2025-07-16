import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kmt/modules/menu/controllers/menu_controller.dart';

class MenuView extends GetView<MenuPageController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
              )
            ],
            color: Colors.white,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Line',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Obx(() {
                return DropdownButtonFormField<String>(
                  value: controller.selectedLine.value,
                  isExpanded: true,
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
                  items: controller.lines
                      .map((line) => DropdownMenuItem(
                            value: line,
                            child: Text(line),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedLine.value = value;
                    }
                  },
                );
              }),
              const SizedBox(height: 20),
              // _buildButton(
              //   label: 'Production Status',
              //   color: const Color(0xFF6CC24A), // Kawasaki Green
              // ),
              // _buildButton(
              //   label: 'NG Records',
              //   color: const Color(0xFFC8102E), // Kawasaki Red
              // ),
              // _buildButton(
              //   label: 'Line Stop Records',
              //   color: const Color(0xFF6CC24A),
              // ),

              // 🔄 Slideable menu here!
              SizedBox(
                height: 180,
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (OverscrollIndicatorNotification overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: PageView(
                    controller: PageController(viewportFraction: 0.8),
                    // physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _slideItem(
                        label: 'Production Status List',
                        color: const Color(0xFF6CC24A),
                        icon: Icons.build,
                      ),
                      // _slideItem(
                      //   label: 'Production Status Manage',
                      //   color: const Color(0xFF6CC24A),
                      //   icon: Icons.settings,
                      // ),
                      _slideItem(
                        label: 'NG Records',
                        color: const Color(0xFF6CC24A),
                        icon: Icons.cancel,
                      ),
                      _slideItem(
                        label: 'Line Stop Records',
                        color: const Color(0xFF6CC24A),
                        icon: Icons.warning,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'v 1.0.0',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required String label, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _slideItem({required String label, required Color color, required IconData icon}) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // Add navigation or action here
          // if (label == 'Production Status List') {
          //   Get.toNamed('/production-status');
          // }
          if (label == 'Production Status List') {
            Get.toNamed('/menuTwo');
          }
          // if (label == 'Production Status Manage') {
          //   Get.toNamed('/production-status-manage');
          // }
          if (label == 'NG Records') {
            Get.toNamed('/ng-information');
          }
          if (label == 'Line Stop Records') {
            Get.toNamed('/line-stop-information');
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 68),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
