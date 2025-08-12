import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kmt/global_widgets/header_kmt.dart';
import 'package:kmt/modules/login/controllers/login_controller.dart';
import 'package:kmt/util/api_config.dart';

class LoginView extends StatelessWidget {
  final controller = Get.put(LoginController());

  LoginView({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadLines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const KawasakiHeader(
                  notificationCount: 0,
                  isShowNoti: false,
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Line Dropdown

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Line',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Obx(() {
                        if (controller.lineList.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        return DropdownButtonFormField<String>(
                          value: controller.selectedLine.value.isEmpty
                              ? null
                              : controller.selectedLine.value,
                          hint: const Text('Select Line'),
                          items: controller.lineList
                              .map((line) => DropdownMenuItem(
                                    value: line,
                                    child: Text(line),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            controller.selectedLine.value = value ?? '';
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        );
                      }),

                      const SizedBox(height: 16),

                      // Username
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Username',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: controller.usernameController,
                        decoration: InputDecoration(
                          hintText: 'username',
                          border: const OutlineInputBorder(),
                          hintStyle: GoogleFonts.openSans(
                            fontSize: 18,
                            color: const Color.fromARGB(255, 188, 188, 188),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: controller.passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '*********',
                          hintStyle: GoogleFonts.openSans(
                            fontSize: 18,
                            color: const Color.fromARGB(255, 188, 188, 188),
                          ),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // SizedBox(
                      //   width: double.infinity,
                      //   height: 48,
                      //   child: ElevatedButton(
                      //     onPressed: () => {Get.offAllNamed('/test')},
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: const Color(0xFFAAFF88),
                      //       foregroundColor: Colors.black,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       elevation: 4,
                      //     ),
                      //     child: const Text('Test'),
                      //   ),
                      // ),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value ? null : () => controller.login(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFAAFF88),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 4,
                          ),
                          child: Obx(() => controller.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Login')),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            EndpointConfig.currentEndpoint.endpointName,
                            style: TextStyle(
                              fontSize: 9,
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  colors: EndpointConfig.currentEndpoint.colors,
                                ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
