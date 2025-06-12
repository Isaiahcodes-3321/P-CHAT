

import 'package:shared_preferences/shared_preferences.dart';

class Pref {
  Pref._();
  static SharedPreferences? _pref;
  static SharedPreferences? get pref => _pref;

  // initialize storage
  static Future init() async {
    _pref = await SharedPreferences.getInstance();
  }

  // set String dataType
  static Future<bool> setStringValue(String key, String data) async {
    return await _pref!.setString(key, data);
  }

  // get String value
  static Future<String> getStringValue(String key) async {
    return _pref!.getString(key) ?? "";
  }

  // set int dataType
  static Future<bool> setIntValue(String key, int data) async {
    return await _pref!.setInt(key, data);
  }

  // get int value
  static Future<int?> getIntValue(String key) async {
    return _pref!.getInt(key);
  }

    // set bool dataType
  static Future<bool> setBoolValue(String key, bool data) async {
    return await _pref!.setBool(key, data);
  }

  // get bool value
  static Future<bool?> getBoolValue(String key) async {
    return _pref!.getBool(key);
  }

  // clear Storage by key
  static Future<bool> removeDateFromStorage(String key) async {
    return await _pref!.remove(key);
  }
}