import 'package:get/get.dart';
import 'package:kmt/model/leak_cyh_model.dart';
import 'package:kmt/model/leak_test_model.dart';
import 'package:kmt/services/base_service.dart';
import 'package:kmt/enum/dio_type.dart';

class CYHLeakTestSerialService extends GetxService {
  final BaseService baseService;
  CYHLeakTestSerialService(this.baseService);

  Future<List<LeakCYH>> getLeakCYH(
      {required String? serialNo, required String? modelCd}) async {
    try {
      final res = await baseService.apiRequest(
        '/leak/get-leak-cyh',
        queryType: QueryType.post,
        data: {'Serial_No': serialNo, 'Model_CD': modelCd},
      );
      print('get-leak-cyh API');
      print('res ===> $res');
      if (res['result'] == true && res['data'] != null) {
        final list = (res['data'] as List).cast<Map<String, dynamic>>();
        return list.map(LeakCYH.fromJson).toList();
      }
      return <LeakCYH>[];
    } catch (e) {
      print("error ${e}");
      return <LeakCYH>[];
    }
  }

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

  Future<Map<String, dynamic>> insertLeakTest(LeakTestModel model) async {
    try {
      final res = await baseService.apiRequest(
        '/leak/save-leak-test-cyh',
        queryType: QueryType.post,
        data: model.toJson(),
      );

      return {
        'result': res['result'] ?? false,
        'message': res['message'] ?? '',
        'data': res['data'],
        'type': res['type']
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
