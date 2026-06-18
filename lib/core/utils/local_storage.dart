import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
// ignore_for_file: unnecessary_null_comparison

class LocalStorage {
  static Future<dynamic> get(String key, [Type type = String]) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    dynamic data;

    if (storage.containsKey(key)) {
      if (type == String) {
        data = storage.getString(key);
      }
      if (type == int) {
        data = storage.getInt(key);
      }
      if (type == bool) {
        data = storage.getBool(key);
      }
      if (type == Map) {
        data = storage.getString(key);
        data = json.decode(data);
      }
    }

    return data;

    //////////////////////////////////////////////////////////////////
  }

  static Future<void> set(String key, val) async {
    SharedPreferences storage = await SharedPreferences.getInstance();

    if (storage != null) {
      if (val is String) {
        await storage.setString(key, val);
      } else if (val is int) {
        await storage.setInt(key, val);
      } else if (val is bool) {
        await storage.setBool(key, val);
      } else if (val is Map) {
        val = json.encode(val); // attempt to converts data to json

        await storage.setString(key, val);
      } else {
        await storage.setString(key, val);
      }
    }
  }

  static Future<void> delete(String key) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.remove(key);

    //////////////////////////////////////////////////////////////////
  }
}
