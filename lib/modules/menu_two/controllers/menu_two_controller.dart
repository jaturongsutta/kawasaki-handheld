import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kmt/model/menu_model.dart';

class MenuTwoController extends GetxController {
  final lineOptions = <String>[].obs;
  final selectedLine = ''.obs;
  final menuList = <MenuModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final box = GetStorage();

    // อ่านไลน์
    final user = box.read('user');
    if (user != null) {
      final List<String> lines = List<String>.from(user['lineOptions'] ?? []);
      lineOptions.assignAll(lines);
      final savedLine = box.read('selectedLine');
      selectedLine.value = savedLine ?? (lines.isNotEmpty ? lines.first : '');
    }

    // อ่านสิทธิ์เมนูจาก Storage
    final rawMenuList = box.read('menuPermissions');
    if (rawMenuList != null) {
      menuList.assignAll(
        List<Map<String, dynamic>>.from(rawMenuList).map((e) => MenuModel.fromJson(e)).toList(),
      );
    }
  }

  bool hasMenu(String menuNo) {
    return menuList.any((menu) => menu.menuNo == menuNo);
  }
}
