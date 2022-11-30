import 'package:shared_preferences/shared_preferences.dart';

import '../enums/shared_preferences_keys.enum.dart';

abstract class SharedPreferencesService {
  static late final SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setPlainAuthPrefs(
    int expiryDate,
    String id,
    String password,
  ) async {
    await prefs.setInt(SharedPreferencesKeys.expiryDate.name, expiryDate);
    await prefs.setString(SharedPreferencesKeys.identifier.name, id);
    await prefs.setString(SharedPreferencesKeys.password.name, password);
  }
}
