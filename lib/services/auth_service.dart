// auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String keyLogin = 'is_logged_in';

  // Simpan status login
  static Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLogin, true);
  }

  // Cek status login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyLogin) ?? false;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyLogin);
  }
}
