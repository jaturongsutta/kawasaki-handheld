import 'package:kmt/enum/dio_type.dart';
import 'package:kmt/model/ng_historical_model.dart';
import 'package:kmt/model/ng_init_data_model.dart';
import 'package:kmt/model/ng_record_model.dart';
import 'package:kmt/model/ng_record_request.dart';
import 'package:kmt/services/base_service.dart';

class NgInformationService {
  final BaseService baseService;

  NgInformationService(this.baseService);

  Future<NgInitDataModel?> fetchNgInitialData(String lineCode) async {
    try {
      final res = await baseService.apiRequest(
        '/ng/running-plan',
        queryType: QueryType.post,
        data: {'Line_CD': lineCode},
      );

      if (res['result'] == true && res['data'] != null) {
        return NgInitDataModel.fromJson(res['data']);
      }
    } catch (e) {
      print("Fetch Error: $e");
    }
    return null;
  }

  Future<bool> saveNgRecord(NgRecordRequest record) async {
    try {
      final response = await baseService.apiRequest(
        '/ng/save-record',
        data: record.toJson(),
        queryType: QueryType.post,
      );

      if (response['result'] == true) {
        return true;
      }
    } catch (e) {
      print('Save NG Record Error: $e');
    }
    return false;
  }

  Future<List<NgRecordModel>> fetchNgRecordList(String lineCd, String planDate) async {
    try {
      final res = await baseService.apiRequest(
        '/ng/list-record',
        data: {
          'Line_CD': lineCd,
          'Plan_Date': planDate,
        },
        queryType: QueryType.post,
      );

      if (res['result'] == true && res['data'] != null) {
        final rawData = res['data'] as List;

        // ดึง List ชั้นใน
        final records = rawData.isNotEmpty && rawData[0] is List ? rawData[0] as List : [];

        return records.map((e) => NgRecordModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Fetch Record List Error: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchHistoricalList({
    required String lineCd,
    required String dateFrom,
    required String dateTo,
    int rowFrom = 1,
    int rowTo = 10,
  }) async {
    try {
      final res = await baseService.apiRequest(
        '/ng/historical-list',
        data: {
          'lineCd': lineCd,
          'dateFrom': dateFrom,
          'dateTo': dateTo,
          'rowFrom': rowFrom,
          'rowTo': rowTo,
        },
        queryType: QueryType.post,
      );

      if (res['result'] == true) {
        return {
          'records': List<HistoricalRecordModel>.from(
            (res['data']['records'] as List).map((e) => HistoricalRecordModel.fromJson(e)),
          ),
          'total': res['data']['total'],
        };
      } else {
        return {
          'records': [],
          'total': 0,
        };
      }
    } catch (e) {
      print('ee===> $e');
      return {
        'records': [],
        'total': 0,
      };
    }
  }
}
