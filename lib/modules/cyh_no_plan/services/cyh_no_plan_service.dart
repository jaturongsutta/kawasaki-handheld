import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kmt/model/leak_history_item_model.dart';
import 'package:kmt/model/leak_history_response_model.dart';
import 'package:kmt/model/leak_no_plan_model.dart';
import 'package:kmt/model/leak_test_ng_model.dart';
import 'package:kmt/model/machine_model.dart';
import 'package:kmt/model/machine_predefine_model.dart';
import 'package:kmt/services/base_service.dart';
import 'package:kmt/enum/dio_type.dart';

class CYHNoPlanService extends GetxService {
  final BaseService baseService;
  CYHNoPlanService(this.baseService);

  Future<List<MachineModel>> fetchMachines({required String? lineCd}) async {
    final res = await baseService.apiRequest(
      '/leak/machine-list',
      queryType: QueryType.post,
      data: {
        'Line_CD': lineCd,
      },
    );
    print('coming up fetchMachines');
    print('res ===> $res');
    if (res['result'] == true && res['data'] != null) {
      final list = (res['data'] as List).cast<Map<String, dynamic>>();
      return list.map(MachineModel.fromJson).toList();
    }
    return <MachineModel>[];
  }

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

  Future<List<LeakTestNgModel>> checkMachine(
      {required String? machineNo}) async {
    final res = await baseService.apiRequest(
      '/leak/check-machine',
      queryType: QueryType.post,
      data: {'Machine_No': machineNo},
    );
    print('coming up checkMachine all');
    print('res ===> $res');
    if (res['result'] == true && res['data'] != null) {
      final list = (res['data'] as List).cast<Map<String, dynamic>>();
      return list.map(LeakTestNgModel.fromJson).toList();
    }
    return <LeakTestNgModel>[];
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

  Future<LeakHistoryResponseModel?> fetchHistoricalNoPlan({
    required String machineNo,
    required DateTime date,
    int rowFrom = 1,
    int rowTo = 10,
  }) async {
    final String dateStr = DateFormat('yyyy-MM-dd').format(date);

    final res = await baseService.apiRequest(
      '/leak/noplan-list-record',
      queryType: QueryType.post,
      data: {
        'machine_No': machineNo,
        'Date_NoPlan': dateStr,
        'Row_No_From': rowFrom,
        'Row_No_To': rowTo,
      },
    );

    if (res == null || res['result'] != true || res['data'] == null) {
      return null;
    }
    final rawData = res['data'] as List;
    final records = rawData.isNotEmpty && rawData[0] is List ? rawData[0] as List : [];

    final items =
        records.map((e) => LeakHistoryItemModel.fromJson(e as Map<String, dynamic>)).toList();

    final totalLoss = (res['total_loss_time'] ?? 0) as int;
    final totalRecords = items.length;

    return LeakHistoryResponseModel(
      items: items,
      totalLossTime: totalLoss,
      totalRecords: totalRecords,
    );
  }
}
