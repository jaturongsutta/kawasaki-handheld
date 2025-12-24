import 'package:get/get.dart';
import 'package:kmt/model/leak_cyh_model.dart';
import 'package:kmt/model/leak_no_plan_model.dart';
import 'package:kmt/model/leak_test_running_model.dart';
import 'package:kmt/model/machine_predefine_model.dart';
import 'package:kmt/services/base_service.dart';
import 'package:kmt/enum/dio_type.dart';

class CYHLeakTestService extends GetxService {
  final BaseService baseService;
  CYHLeakTestService(this.baseService);

  Future<List<MachinePredefineModel>> fetchMachinesAll() async {
    final res = await baseService.apiRequest(
      '/leak/machine-all',
      queryType: QueryType.post,
    );
    print('coming up fetchMachines all');
    print('res ===> $res');
    if (res['result'] == true && res['data'] != null) {
      final list = (res['data'] as List).cast<Map<String, dynamic>>();
      return list.map(MachinePredefineModel.fromJson).toList();
    }
    return <MachinePredefineModel>[];
  }

  Future<List<LeakCYH>> checkTestResult({required String? machineNo}) async {
    try {
      final res = await baseService.apiRequest(
        '/leak/check-test-result',
        queryType: QueryType.post,
        data: {'Machine_No': machineNo},
      );
      print('check-test-result API');
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

      if (res != null && res['result'] == true && res['data'] != null) {
        final list = res['data'] as List;

        final value = list
            .map((e) => LeakTestRunningModel.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList();

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
