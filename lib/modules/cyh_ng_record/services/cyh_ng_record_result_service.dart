import 'package:get/get.dart';
import 'package:kmt/model/leak_test_model.dart';
import 'package:kmt/model/leak_test_ng_model.dart';
import 'package:kmt/services/base_service.dart';
import 'package:kmt/enum/dio_type.dart';

class CYHNGRecordResultService extends GetxService {
  final BaseService baseService;
  CYHNGRecordResultService(this.baseService);

  Future<String> fetchGSCount(
      {required String? modelCd, required String? serialNo}) async {
    final res = await baseService.apiRequest(
      '/leak/gs-count',
      queryType: QueryType.get,
      data: {'Model_CD': modelCd, 'Serial_No': serialNo},
    );
    print('coming up fetchGSCount');
    print('res ===> $res');
    if (res['result'] == true && res['data'] != null) {
      final String str = '${res['data']}';
      return str;
    }
    return '0';
  }

  Future<Map<String, dynamic>> updateLeakTest(LeakTestModel model) async {
    try {
      final res = await baseService.apiRequest(
        '/leak/update-leak-test-cyh',
        queryType: QueryType.post,
        data: model.toJson(),
      );

      LeakTestNgModel? leakData;
      if (res['data'] != null && res['data'] is Map<String, dynamic>) {
        leakData = LeakTestNgModel.fromJson(res['data']);
      }

      return {
        'result': res['result'] ?? false,
        'message': res['message'] ?? '',
        'data': leakData,
      };
    } catch (e) {
      return {'result': false, 'message': e.toString(), 'data': null};
    }
  }
}

class ApiResponse<T> {
  final bool ok;
  final String message;
  final T? data;

  ApiResponse({required this.ok, required this.message, this.data});
}
