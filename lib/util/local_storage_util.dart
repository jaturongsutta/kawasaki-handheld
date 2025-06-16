import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static List<String> ignoreKeys = [
    'is_noti',
  ];

  static Future getLocalStorageKeys() async {
    final localStorage = await SharedPreferences.getInstance();
  }

  static Future setLocalStorage({required String key, required object}) async {
    if (object.runtimeType == bool) {
      final localStorage = await SharedPreferences.getInstance();
      localStorage.setString(key, jsonEncode(object));
      return getLocalStorage(key: key);
    } else if (object.isNotEmpty) {
      final localStorage = await SharedPreferences.getInstance();
      localStorage.setString(key, jsonEncode(object));
      return getLocalStorage(key: key);
    }
  }

  static Future insertLocalStorage({
    required String key,
    required object,
  }) async {
    if (object.isNotEmpty) {
      final localStorage = await SharedPreferences.getInstance();
      final data = await getLocalStorage(key: key);

      if (data is List) {
        object = [...data, object];
      } else {
        if (data != null) {
          object = [data, object];
        } else {
          object = [object];
        }
      }

      await localStorage.setString(key, jsonEncode(object));

      return getLocalStorage(key: key);
    }
  }

  static Future updateLocalStorage<T>({
    required String key,
    required object,
    String? pkKey,
    dynamic pkId,
  }) async {
    if (object.isNotEmpty) {
      final localStorage = await SharedPreferences.getInstance();
      var data = await getLocalStorage(key: key);
      if (data is List) {
        pkId = pkId ?? object[pkKey];
        if (pkKey != null && pkId != null) {
          final results = data.where((x) => x[pkKey] == pkId).toList();
          if (results.isNotEmpty) {
            final current = results.first;
            await object.forEach((key, value) {
              current[key] = value;
            });
          }

          // print('_results: $_data');
        }
      } else {
        await object.forEach((key, value) {
          data[key] = value;
        });
      }

      localStorage.setString(key, jsonEncode(data));
      return getLocalStorage(key: key);
    }
  }

  static Future getLocalStorage({required String key}) async {
    final localStorage = await SharedPreferences.getInstance();
    final data = localStorage.getString(key);
    return data != null ? jsonDecode(data) : null;
  }

  static Future<bool> deleteLocalStorage({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }

  static Future getLocalStorageByPK({
    required String key,
    required String pkKey,
    required String pkId,
  }) async {
    var data = await getLocalStorage(key: key);
    if (data == null) {
      return null;
    }
    if (data is List) {
      var payment = data.where((x) => x[pkKey] == pkId).toList();
      if (payment.isNotEmpty) {
        return payment.first;
      } else {
        return null;
      }
    } else {
      if (data[pkKey] == pkId) {
        return data;
      } else {
        return null;
      }
    }
  }

  static Future removeLocalStorage({required String key}) async {
    final localStorage = await SharedPreferences.getInstance();
    localStorage.remove(key);

    return null;
  }

  static Future removeLocalStorageById({
    required String key,
    required String? pkKey,
    required dynamic pkId,
  }) async {
    // final _localStorage = await SharedPreferences.getInstance();
    var data = await getLocalStorage(key: key);

    if (data != null) {
      await data.removeWhere((x) => x[pkKey] == pkId);

      if (data.isNotEmpty) {
        data = await LocalStorage.setLocalStorage(
          key: key,
          object: data,
        );
      } else {
        data = await LocalStorage.removeLocalStorage(key: key);
      }
    }

    return data ?? null;
  }

  static void clearLocalStorage() async {
    final localStorage = await SharedPreferences.getInstance();
    var keys = localStorage.getKeys();
    for (var key in keys) {
      if (!ignoreKeys.contains(key)) localStorage.remove(key);
    }
  }
}
