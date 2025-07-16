import 'package:get/get.dart';

class ProductionStatusManageController extends GetxController {
  var otOptions = ['Yes', 'No'].obs;
  var selectedOt = 'Yes'.obs;

  void setOt() {
    // TODO: implement OT update logic
    print('Set OT: ${selectedOt.value}');
  }

  void stopProduction() {
    // TODO: implement stop production logic
    print('Production stopped.');
  }
}
