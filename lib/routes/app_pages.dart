import 'package:get/get.dart';
import 'package:kmt/modules/alert/bindings/notification_binding.dart';
import 'package:kmt/modules/alert/views/notification_screen.dart';
import 'package:kmt/modules/line_stop_information/bindings/line_stop_bindings.dart';
import 'package:kmt/modules/line_stop_information/views/line_stop_information_view.dart';
import 'package:kmt/modules/login/views/login_view.dart';
import 'package:kmt/modules/menu_two/bindings/menu_two_binding.dart';
import 'package:kmt/modules/menu_two/views/menu_two_view.dart';
import 'package:kmt/modules/menu_two/views/test_view.dart';
import 'package:kmt/modules/ng_information/bindings/ng_information_binding.dart';
import 'package:kmt/modules/ng_information/views/ng_information_view.dart';
import 'package:kmt/modules/production_status_list/bindings/production_status_list_binding.dart';
import 'package:kmt/modules/production_status_list/views/production_status_list_view.dart';
import 'package:kmt/modules/production_status_manage/bindings/production_status_manage_binding.dart';
import 'package:kmt/modules/production_status_manage/views/production_status_manage_view.dart';
import 'package:kmt/routes/app_routes.dart';
import 'package:kmt/splash_screen.dart';

class AppPages {
  static const initial = '/';

  static final routes = [
    // GetPage(
    //   name: AppRoutes.menu,
    //   page: () => const MenuView(),
    //   binding: MenuBinding(),
    // ),
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => LoginView()),
    GetPage(name: AppRoutes.test, page: () => const KeyenceScannerTestPage()),

    GetPage(
      name: AppRoutes.menu,
      page: () => const MenuTwoView(),
      binding: MenuTwoBinding(),
    ),
    GetPage(
      name: AppRoutes.productionStatusListView,
      page: () => const ProductionStatusView(),
      binding: ProductionStatusListBinding(),
    ),
    GetPage(
      name: AppRoutes.productionStatusManage,
      page: () => const ProductionStatusManageView(),
      binding: ProductionStatusManageBinding(),
    ),
    GetPage(
      name: AppRoutes.ngInformation,
      page: () => const NgInformationView(),
      binding: NgInformationBinding(),
    ),
    GetPage(
      name: AppRoutes.lineStopInformation,
      page: () => LineStopInformationView(),
      binding: LineStopInformationBinding(),
    ),
    GetPage(
      name: AppRoutes.alert,
      page: () => const NotificationScreen(),
      binding: AlertBinding(),
    ),
  ];
}
