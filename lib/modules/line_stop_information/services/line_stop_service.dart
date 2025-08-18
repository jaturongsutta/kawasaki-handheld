import 'package:kmt/enum/dio_type.dart';
import 'package:kmt/model/line_stop_historical_model.dart';
import 'package:kmt/model/line_stop_init_data_model.dart';
import 'package:kmt/model/line_stop_record_model.dart';
import 'package:kmt/model/line_stop_record_request.dart';
import 'package:kmt/services/base_service.dart';

class LineStopInformationService {
  final BaseService baseService;

  LineStopInformationService(this.baseService);

  Future<LineStopInitDataModel?> fetchLineStopInitialData(String lineCode) async {
    try {
      final res = await baseService.apiRequest(
        '/line-stop/running-plan',
        queryType: QueryType.post,
        data: {'Line_CD': lineCode},
      );

      if (res['result'] == true && res['data'] != null) {
        return LineStopInitDataModel.fromJson(res['data']);
      }
    } catch (e) {
      print("Fetch Error: $e");
    }
    return null;
  }

  Future<String> saveLineStopRecord(LineStopRecordRequest record) async {
    try {
      final response = await baseService.apiRequest(
        '/line-stop/save-record',
        data: record.toJson(),
        queryType: QueryType.post,
      );

      if (response['result'] == true) {
        return '';
      } else {
        return response['message'];
      }
    } catch (e) {
      print('Save NG Record Error: $e');
      return 'Save NG Record Error: $e';
    }
  }

  Future<List<LineStopRecordModel>> fetchLineStopRecordList(String lineCd, String planDate) async {
    try {
      final res = await baseService.apiRequest(
        '/line-stop/list-record',
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

        return records.map((e) => LineStopRecordModel.fromJson(e as Map<String, dynamic>)).toList();
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
        '/line-stop/historical-list',
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
          'records': List<LineStopHistoricalRecordModel>.from(
            (res['data']['records'] as List).map((e) => LineStopHistoricalRecordModel.fromJson(e)),
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
