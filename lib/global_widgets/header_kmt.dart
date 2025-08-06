import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KawasakiHeader extends StatelessWidget {
  final int notificationCount;

  const KawasakiHeader({super.key, required this.notificationCount});

  @override
  Widget build(BuildContext context) {
    print('notificationCount ==> $notificationCount');
    return SizedBox(
      // color: Colors.amber,
      height: 120,
      child: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          Stack(
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Kawasaki",
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        "Let the Good Times Roll",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Align(
                alignment: const Alignment(0.8, 0.0),
                child: InkWell(
                  onTap: () {
                    Get.toNamed('/alert');
                  },
                  child: SizedBox(
                    height: 90,
                    width: 60,
                    child: Stack(
                      alignment: const Alignment(0, 0),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFB7F48D), // เขียวอ่อน
                            shape: BoxShape.circle,
                          ),
                          child:
                              const Icon(Icons.notifications_none, size: 18, color: Colors.black),
                        ),
                        if (notificationCount > 0)
                          Positioned(
                            right: -0.5,
                            top: 18,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$notificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
