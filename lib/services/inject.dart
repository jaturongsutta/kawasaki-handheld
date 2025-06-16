import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:kmt/services/inject.config.dart';

var getIt = GetIt.instance;

// กำหนดตัวสำหรับตั้งค่า get_it
// ฟังก์ชันที่ชื่อ $initGetIt จะถูกสร้างเมื่อเราสั่ง build_runner

@injectableInit
void configureInjection() => getIt.init();
