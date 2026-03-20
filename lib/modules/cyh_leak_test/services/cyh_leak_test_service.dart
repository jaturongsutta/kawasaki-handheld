import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:kmt/model/leak_cyh_model.dart';
import 'package:kmt/model/leak_no_plan_model.dart';
import 'package:kmt/model/leak_test_ng_model.dart';
import 'package:kmt/model/leak_test_running_model.dart';
import 'package:kmt/model/machine_predefine_model.dart';
import 'package:kmt/modules/cyh_leak_test/services/cyh_leak_test_flow_log_service.dart';
import 'package:kmt/services/base_service.dart';
import 'package:kmt/enum/dio_type.dart';

class CYHLeakTestService extends GetxService {
  final BaseService baseService;
  CYHLeakTestService(this.baseService);

  CYHLeakTestFlowLogService get _flowLog {
    if (Get.isRegistered<CYHLeakTestFlowLogService>()) {
      return Get.find<CYHLeakTestFlowLogService>();
    }
    return Get.put(CYHLeakTestFlowLogService(), permanent: true);
  }

  void _log(String step, {Map<String, dynamic>? data}) {
    final payload = data == null ? '' : ' | $data';
    debugPrint('[CYHLeakTestService][$step]$payload');
    _flowLog.add('CYHLeakTestService', step, data: data);
  }

  void _logError(
    String step,
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? data,
  }) {
    final payload = data == null ? '' : ' | $data';
    debugPrint('[CYHLeakTestService][$step][ERROR] $error$payload');
    debugPrint(stackTrace.toString());
    _flowLog.addError('CYHLeakTestService', step, error, stackTrace,
        data: data);
  }

  Future<List<MachinePredefineModel>> fetchMachinesAll() async {
    _log('fetchMachinesAll.request',
        data: {'endpoint': '/leak/machine-all', 'payload': null});
    try {
      final res = await baseService.apiRequest(
        '/leak/machine-all',
        queryType: QueryType.post,
      );
      final hasData =
          res is Map && res['result'] == true && res['data'] is List;
      final count = hasData ? (res['data'] as List).length : 0;
      _log('fetchMachinesAll.response', data: {
        'result': res is Map ? res['result'] : null,
        'message': res is Map ? res['message'] : null,
        'count': count,
        'raw': res,
      });

      if (hasData) {
        final list = (res['data'] as List).cast<Map<String, dynamic>>();
        return list.map(MachinePredefineModel.fromJson).toList();
      }
      return <MachinePredefineModel>[];
    } catch (e, st) {
      _logError('fetchMachinesAll.catch', e, st);
      return <MachinePredefineModel>[];
    }
  }

  Future<List<LeakTestNgModel>> checkMachine(
      {required String? machineNo}) async {
    _log('checkMachine.request', data: {
      'endpoint': '/leak/check-machine',
      'Machine_No': machineNo,
    });
    try {
      final res = await baseService.apiRequest(
        '/leak/check-machine',
        queryType: QueryType.post,
        data: {'Machine_No': machineNo},
      );
      final hasData =
          res is Map && res['result'] == true && res['data'] is List;
      final count = hasData ? (res['data'] as List).length : 0;
      _log('checkMachine.response', data: {
        'result': res is Map ? res['result'] : null,
        'message': res is Map ? res['message'] : null,
        'count': count,
        'raw': res,
      });
      if (hasData) {
        final list = (res['data'] as List).cast<Map<String, dynamic>>();
        return list.map(LeakTestNgModel.fromJson).toList();
      }
      return <LeakTestNgModel>[];
    } catch (e, st) {
      _logError('checkMachine.catch', e, st, data: {'Machine_No': machineNo});
      return <LeakTestNgModel>[];
    }
  }

  Future<List<LeakCYH>> checkTestResult({required String? machineNo}) async {
    _log('checkTestResult.request', data: {
      'endpoint': '/leak/check-test-result',
      'Machine_No': machineNo,
    });
    try {
      final res = await baseService.apiRequest(
        '/leak/check-test-result',
        queryType: QueryType.post,
        data: {'Machine_No': machineNo},
      );
      final hasData =
          res != null && res['result'] == true && res['data'] is List;
      final count = hasData ? (res['data'] as List).length : 0;
      _log('checkTestResult.response', data: {
        'result': res?['result'],
        'message': res?['message'],
        'count': count,
        'raw': res,
      });
      if (res['result'] == true && res['data'] != null) {
        final list = (res['data'] as List).cast<Map<String, dynamic>>();
        return list.map(LeakCYH.fromJson).toList();
      }
      return <LeakCYH>[];
    } catch (e, st) {
      _logError('checkTestResult.catch', e, st,
          data: {'Machine_No': machineNo});
      return <LeakCYH>[];
    }
  }

  Future<List<String>> fetchWorkType() async {
    _log('fetchWorkType.request',
        data: {'endpoint': '/leak/worktype', 'payload': null});
    try {
      final res = await baseService.apiRequest(
        '/leak/worktype',
        queryType: QueryType.get,
      );
      final hasData =
          res is Map && res['result'] == true && res['data'] is List;
      _log('fetchWorkType.response', data: {
        'result': res is Map ? res['result'] : null,
        'message': res is Map ? res['message'] : null,
        'count': hasData ? (res['data'] as List).length : 0,
        'raw': res,
      });
      if (hasData) {
        final list = (res['data'] as List).cast<String>();
        return list;
      }
      return <String>[];
    } catch (e, st) {
      _logError('fetchWorkType.catch', e, st);
      return <String>[];
    }
  }

  Future<ApiResponse<List<LeakTestRunningModel>>> fetchRunningList(
      {required String? machineNo, required String? workType}) async {
    _log('fetchRunningList.request', data: {
      'endpoint': '/leak/production-list-running',
      'Machine_No': machineNo,
      'Work_Type': workType,
    });
    try {
      final res = await baseService.apiRequest(
        '/leak/production-list-running',
        queryType: QueryType.post,
        data: {'Machine_No': machineNo, 'Work_Type': workType},
      );
      final hasData =
          res != null && res['result'] == true && res['data'] is List;
      final count = hasData ? (res['data'] as List).length : 0;
      _log('fetchRunningList.response', data: {
        'result': res?['result'],
        'message': res?['message'],
        'count': count,
        'raw': res,
      });

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
    } catch (e, st) {
      _logError('fetchRunningList.catch', e, st, data: {
        'Machine_No': machineNo,
        'Work_Type': workType,
      });
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
