import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kmt/enum/dio_type.dart';
import 'package:kmt/model/notification_model.dart';
import 'package:kmt/modules/alert/service/notification_service.dart';
import 'package:kmt/services/base_service.dart';
import 'package:kmt/services/inject.dart';
import 'package:kmt/widgets/customLog.dart';

class NotificationController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  final service = NotificationService();
  final _baseService = getIt<BaseService>();

  var total = 0.obs;
  var unread = 0.obs;
  var isLoading = false.obs;
  final int pageSize = 10;
  int currentTo = 0;

  @override
  void onInit() {
    super.onInit();
    loadNotifications(reset: true);
    _scheduleAutoRefresh();
  }

  Future<void> loadNotifications({bool reset = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final from = reset ? 1 : currentTo + 1;
      final to = from + pageSize - 1;

      final result = await service.fetchNotifications(from: from, to: to);
      print('result===> $result');
      logger.i(result);
      final List<dynamic> data = result['data'] ?? [];
      List<NotificationModel> list = [];
      if ((result['data'] as List).isNotEmpty) {
        list = data.map((e) => NotificationModel.fromJson(e)).toList();
      }

      if (reset) {
        notifications.assignAll(list);
        currentTo = to;
      } else {
        notifications.addAll(list);
        currentTo = to;
      }
      total.value = result['total'] ?? 0;
      unread.value = result['unread'] ?? 0;
    } catch (e, s) {
      print("❌ load error: $e");
      print("❌ load sssss: $s");
    } finally {
      isLoading.value = false;
    }
  }

  void loadMore() {
    loadNotifications();
  }

  void _scheduleAutoRefresh() {
    Future.doWhile(() async {
      await Future.delayed(Duration(minutes: 10));
      loadNotifications(reset: true);
      return true;
    });
  }

  Future<void> markAsRead(int id) async {
    try {
      final user = GetStorage().read('user');
      final userId = user?['userId'] ?? '';

      await _baseService.apiRequest(
        '/alert/mark-read',
        queryType: QueryType.post,
        data: {
          'ID_Ref': id,
          'CREATED_BY': userId,
        },
      );

      await loadNotifications(reset: true);
    } catch (e) {
      print("❌ markAsRead error: $e");
    }
  }
}
