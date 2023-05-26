import 'package:shared_preferences/shared_preferences.dart';


class MySharedPreferences {
  static late SharedPreferences prefs;
  // String
  static Future<void> saveString(String key, String value) async {

    prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key, [String? defaultValue]) async {

    prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }
  // Double
  static Future<void> saveDouble(String key, double value) async {

    prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  static Future<double?> getDouble(String key, [double? defaultValue]) async {

    prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key) ?? defaultValue;
  }
  // Clear
  static Future<void> clearValue(String key) async {

    prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

}
