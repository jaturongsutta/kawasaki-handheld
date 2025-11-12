import 'package:get/get.dart';
import 'package:kmt/model/leak_no_plan_model.dart';
import 'package:kmt/model/leak_test_model.dart';
import 'package:kmt/model/leak_test_ng_model.dart';
import 'package:kmt/model/leak_test_running_model.dart';
import 'package:kmt/model/machine_model.dart';
import 'package:kmt/services/base_service.dart';
import 'package:kmt/enum/dio_type.dart';

class CYHLeakTestSerialService extends GetxService {
  final BaseService baseService;
  CYHLeakTestSerialService(this.baseService);

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

  // Future<ApiResponse<List<LeakTestRunningModel>>> fetchRunningList(
  //     {required String? machineNo, required String? workType}) async {
  //   try {
  //     final res = await baseService.apiRequest(
  //       '/leak/production-list-running',
  //       queryType: QueryType.post,
  //       data: {'Machine_No': machineNo, 'Work_Type': workType},
  //     );
  //     print('coming up fetchRunningList');
  //     print('res ===> $res');
  //     if (res['result'] == true && res['data'] != null) {
  //       final outerList = res['data'] as List;
  //       final innerList = outerList.isNotEmpty ? outerList.first as List : [];

  //       final value = innerList
  //           .map((e) =>
  //               LeakTestRunningModel.fromJson(Map<String, dynamic>.from(e)))
  //           .toList();

  //       print('value ===>  ${value}');
  //       return ApiResponse<List<LeakTestRunningModel>>(
  //         ok: true,
  //         message: '',
  //         data: value,
  //       );
  //     }
  //     return ApiResponse<List<LeakTestRunningModel>>(
  //       ok: false,
  //       message: res['message'],
  //       data: [],
  //     );
  //   } catch (e) {
  //     print('fetchRunningList error: $e\n');
  //     return ApiResponse<List<LeakTestRunningModel>>(
  //       ok: false,
  //       message: e.toString(),
  //       data: [],
  //     );
  //   }
  // }

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
