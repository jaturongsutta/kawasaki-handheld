import 'package:get/get.dart';
import 'package:kmt/model/leak_test_model.dart';
import 'package:kmt/model/leak_test_ng_model.dart';
import 'package:kmt/services/base_service.dart';
import 'package:kmt/enum/dio_type.dart';

class CYHLeakTestOKService extends GetxService {
  final BaseService baseService;
  CYHLeakTestOKService(this.baseService);

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

  Future<List<LeakTestNgModel>> getOKNG({required String? machineNo}) async {
    try {
      final res = await baseService.apiRequest(
        '/leak/get-ok-ng',
        queryType: QueryType.post,
        data: {'Machine_No': machineNo},
      );
      print('get-ok-ng API');
      print('res ===> $res');
      if (res['result'] == true && res['data'] != null) {
        final list = (res['data'] as List).cast<Map<String, dynamic>>();
        return list.map(LeakTestNgModel.fromJson).toList();
      }
      return <LeakTestNgModel>[];
    } catch (e) {
      print("error ${e}");
      return <LeakTestNgModel>[];
    }
  }

  Future<Map<String, dynamic>> updateLeakTestOK(LeakTestModel model) async {
    try {
      final res = await baseService.apiRequest(
        '/leak/update-leak-test-ok-cyh',
        queryType: QueryType.post,
        data: model.toJson(),
      );
      return {
        'result': res['result'] ?? false,
        'message': res['message'] ?? '',
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
