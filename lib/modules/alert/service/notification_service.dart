import 'package:get_storage/get_storage.dart';
import 'package:kmt/services/base_service.dart';
import 'package:kmt/services/inject.dart';
import 'package:kmt/enum/dio_type.dart';

class NotificationService {
  final _baseService = getIt<BaseService>();
  final box = GetStorage();

  Future<Map<String, dynamic>> fetchNotifications({
    required int from,
    required int to,
  }) async {
    final lineCd = box.read('selectedLine') ?? '';

    final response = await _baseService.apiRequest(
      '/alert/info-alert',
      queryType: QueryType.post,
      data: {
        'Line_CD': lineCd,
        'Row_No_From': from,
        'Row_No_To': to,
      },
    );

    if (response['result']) {
      final data = response['data'];
      return {
        'data': List<Map<String, dynamic>>.from(data['records'] ?? []),
        'total': data['total'] ?? 0,
        'unread': data['unread'] ?? 0,
      };
    } else {
      throw Exception(response['message'] ?? 'Failed to fetch alerts');
    }
  }
}
