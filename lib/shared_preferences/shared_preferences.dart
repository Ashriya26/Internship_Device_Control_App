import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _usernameKey = 'username';

  // ✅ Save login state
  static Future<void> setLoginState(bool isLoggedIn, {String? username}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
    if (username != null) {
      await prefs.setString(_usernameKey, username);
    }
  }

  // ✅ Get login state
  static Future<bool> getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // ✅ Get stored username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // ✅ Logout (Clear saved data)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_usernameKey);
  }
}
