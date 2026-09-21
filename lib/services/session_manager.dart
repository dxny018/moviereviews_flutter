import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Guarda token, ID y rol idéntico a Kotlin.
  static Future<void> saveSession(String token, int userId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setInt('userId', userId);
    await prefs.setString('role', role);
  }

  // Obtiene el token guardado.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Obtiene el rol guardado.
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  // Obtiene el ID guardado (devuelve -1 si no existe, como en Kotlin).
  static Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? -1;
  }

  // Borra completamente la sesión.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}