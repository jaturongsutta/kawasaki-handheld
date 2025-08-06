import 'package:kmt/enum/dio_type.dart';
import 'package:kmt/model/plan_search_model.dart';
import 'package:kmt/model/production_detail_model.dart';
import 'package:kmt/model/production_plan_model.dart';
import 'package:kmt/services/base_service.dart';
import 'package:kmt/widgets/customLog.dart';

class ProductionStatusService {
  final BaseService baseService;

  ProductionStatusService(this.baseService);

  Future<List<ProductionPlanModel>> fetchTodayPlan(String lineCd) async {
    try {
      final res = await baseService.apiRequest(
        '/production-status/current-plan',
        data: {'Line_CD': lineCd},
        queryType: QueryType.post,
      );

      if (res['result'] == true) {
        final rawOuterList = res['data'];
        if (rawOuterList is List && rawOuterList.isNotEmpty && rawOuterList[0] is List) {
          final rawList = rawOuterList[0] as List<dynamic>;
          return rawList.map((e) => ProductionPlanModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print("Error fetching plan: $e");
    }

    return [];
  }

  Future<ProductionDetailModel?> fetchProductionDetail(int id) async {
    try {
      final res = await baseService.apiRequest(
        '/production-status/detail',
        data: {'id': id},
        queryType: QueryType.post,
      );
      logger.i(res);

      if (res['result'] == true) {
        return ProductionDetailModel.fromJson(res['data']);
      }
    } catch (e) {
      print('Error fetching detail: $e');
    }
    return null;
  }

  Future<bool> updateOT({
    required int planId,
    required bool isOT,
    required num timeMins,
    required num updatedBy,
  }) async {
    final res = await baseService.apiRequest(
      '/production-status/update-ot',
      data: {
        'plan_id': planId,
        'is_ot': isOT,
        'time_mins': timeMins,
        'updated_by': updatedBy,
      },
      queryType: QueryType.post,
    );

    return res['result'] == true;
  }

  Future<Map<String, dynamic>?> fetchOTData(int planId) async {
    final res = await baseService.apiRequest(
      '/production-status/check-ot',
      data: {'plan_id': planId},
      queryType: QueryType.post,
    );

    if (res['result'] == true && res['data'] != null && res['data'].isNotEmpty) {
      return res['data'][0];
    }
    return null;
  }

  Future<bool> stopPlan(int planId, num updatedBy) async {
    try {
      final res = await baseService.apiRequest(
        '/production-status/stop-plan',
        data: {
          'plan_id': planId,
          'updated_by': updatedBy,
        },
        queryType: QueryType.post,
      );
      return res['result'] == true;
    } catch (e) {
      print('Error stopping plan: $e');
      return false;
    }
  }

/////// Other ///////

  Future<List<PlanSearchModel>> fetchPlans({
    required String lineCd,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? modelCd,
    String? status,
    int from = 1,
    int to = 10,
  }) async {
    try {
      final res = await baseService.apiRequest(
        '/production-status/search',
        data: {
          'Line_CD': lineCd,
          'Plan_Date_From': dateFrom?.toIso8601String(),
          'Plan_Date_To': dateTo?.toIso8601String(),
          'Model_CD': modelCd,
          'Status': status,
          'Row_No_From': from,
          'Row_No_To': to,
        },
        queryType: QueryType.post,
      );

      if (res['result']) {
        final recordList = res['data']['records'][0] as List<dynamic>;
        return recordList.map((e) => PlanSearchModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e, s) {
      print('eeeeee ====> $e');
      print('ssssss ====> $s');

      return [];
    }
  }

  Future<ProductionDetailModel?> fetchOtherProductionDetail(int id) async {
    try {
      final res = await baseService.apiRequest(
        '/production-status/detail',
        data: {'id': id},
        queryType: QueryType.post,
      );

      if (res['result'] == true) {
        return ProductionDetailModel.fromJson(res['data']);
      }
    } catch (e) {
      print('Error fetching detail: $e');
    }
    return null;
  }

  Future<bool> updateOTOther({
    required int planId,
    required bool isOT,
    required num timeMins,
    required num updatedBy,
  }) async {
    final res = await baseService.apiRequest(
      '/production-status/update-ot',
      data: {
        'plan_id': planId,
        'is_ot': isOT,
        'time_mins': timeMins,
        'updated_by': updatedBy,
      },
      queryType: QueryType.post,
    );

    return res['result'] == true;
  }

  Future<Map<String, dynamic>?> fetchOTDataOther(int planId) async {
    final res = await baseService.apiRequest(
      '/production-status/check-ot',
      data: {'plan_id': planId},
      queryType: QueryType.post,
    );

    if (res['result'] == true && res['data'] != null && res['data'].isNotEmpty) {
      return res['data'][0];
    }
    return null;
  }
}
