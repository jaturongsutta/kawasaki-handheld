import 'package:get/get.dart';
import 'package:kmt/model/leak_no_plan_model.dart';
import 'package:kmt/model/machine_model.dart';
import 'package:kmt/services/base_service.dart';
import 'package:kmt/enum/dio_type.dart';

class CYHLeakTestService extends GetxService {
  final BaseService baseService;
  CYHLeakTestService(this.baseService);

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
