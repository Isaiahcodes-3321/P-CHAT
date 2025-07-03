

import 'package:shared_preferences/shared_preferences.dart';


class Pref {
  Pref._();
  static SharedPreferences? _pref;
  static SharedPreferences? get pref => _pref;

  static Future init() async {
    _pref = await SharedPreferences.getInstance();
  }

  static Future<bool> setStringValue(String key, String data) async {
    return await _pref!.setString(key, data);
  }

  static Future<String> getStringValue(String key) async {
    return _pref!.getString(key) ?? "";
  }

  static Future<bool> setIntValue(String key, int data) async {
    return await _pref!.setInt(key, data);
  }

  static Future<int?> getIntValue(String key) async {
    return _pref!.getInt(key);
  }

  static Future<bool> setBoolValue(String key, bool data) async {
    return await _pref!.setBool(key, data);
  }

  static Future<bool?> getBoolValue(String key) async {
    return _pref!.getBool(key);
  }

  // set list of string dataType
  static Future<bool> setStringListValue(String key, List<String> data) async {
    return await _pref!.setStringList(key, data);
  }

  // get list of string value
  static Future<List<String>> getStringListValue(String key) async {
    return _pref!.getStringList(key) ?? [];
  }

  // Method to remove a key-value pair from storage
  static Future<bool> removeDateFromStorage(String key) async {
    if (_pref == null) {
      throw Exception("SharedPreferences not initialized. Call Pref.init() first.");
    }
    return await _pref!.remove(key);
  }
}