import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_model.dart';

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  static Future<String?> login(LoginRequest request) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      print('🟢 STATUS DE RESPUESTA: ${response.statusCode}');
      print('🟢 CUERPO DE RESPUESTA: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        return null;
      }
    } catch (e) {
      print('🔴 ERROR GRAVE DE RED: $e');
      return null;
    }
  }
}