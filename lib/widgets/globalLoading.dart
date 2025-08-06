import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kmt/widgets/controller/loadingcontroller.dart';

class GlobalLoading extends StatelessWidget {
  const GlobalLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final loadingController = Get.find<LoadingController>();
    return Obx(() {
      return loadingController.isLoading.value
          ? Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : const SizedBox();
    });
  }
}
