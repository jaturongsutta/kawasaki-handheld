import 'package:get/get.dart';
import 'package:kmt/model/leak_no_plan_model.dart';
import 'package:kmt/model/leak_test_running_model.dart';
import 'package:kmt/model/machine_model.dart';
import 'package:kmt/services/base_service.dart';
import 'package:kmt/enum/dio_type.dart';

class CYHLeakTestService extends GetxService {
  final BaseService baseService;
  CYHLeakTestService(this.baseService);

  Future<List<String>> fetchWorkType() async {
    final res = await baseService.apiRequest(
      '/leak/worktype',
      queryType: QueryType.get,
    );
    print('coming up fetchWorkType');
    print('res ===> $res');
    if (res['result'] == true && res['data'] != null) {
      final list = (res['data'] as List).cast<String>();
      return list;
    }
    return <String>[];
  }

  Future<ApiResponse<List<LeakTestRunningModel>>> fetchRunningList(
      {required String? machineNo, required String? workType}) async {
    try {
      final res = await baseService.apiRequest(
        '/leak/production-list-running',
        queryType: QueryType.post,
        data: {'Machine_No': machineNo, 'Work_Type': workType},
      );
      print('coming up fetchRunningList');
      print('res ===> $res');
      if (res['result'] == true && res['data'] != null) {
        final outerList = res['data'] as List;
        final innerList = outerList.isNotEmpty ? outerList.first as List : [];

        final value = innerList
            .map((e) =>
                LeakTestRunningModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        print('value ===>  ${value}');
        return ApiResponse<List<LeakTestRunningModel>>(
          ok: true,
          message: '',
          data: value,
        );
      }
      return ApiResponse<List<LeakTestRunningModel>>(
        ok: false,
        message: res['message'],
        data: [],
      );
    } catch (e) {
      print('fetchRunningList error: $e\n');
      return ApiResponse<List<LeakTestRunningModel>>(
        ok: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  Future<Map<String, dynamic>> insertLeakNoPlan(LeakNoPlanModel model) async {
    try {
      final res = await baseService.apiRequest(
        '/leak/save-leak',
        queryType: QueryType.post,
        data: model.toJson(),
      );

      return {
        'result': res['result'] ?? false,
        'message': res['message'] ?? '',
      };
    } catch (e) {
      return {
        'result': false,
        'message': e.toString(),
      };
    }
  }
}

class ApiResponse<T> {
  final bool ok;
  final String message;
  final T? data;

  ApiResponse({required this.ok, required this.message, this.data});
}
