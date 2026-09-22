import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_model.dart';
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  // 1. Iniciar sesión (Intacto)
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

  // 2. Obtener todo el catálogo (US03)
  static Future<List<Product>?> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        Iterable list = jsonDecode(response.body);
        return list.map((model) => Product.fromJson(model)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 3. Obtener las categorías (US04)
  static Future<List<String>?> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/categories'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 4. Obtener productos filtrados (US04)
  static Future<List<Product>?> getProductsByCategory(String category) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/category/$category'));
      if (response.statusCode == 200) {
        Iterable list = jsonDecode(response.body);
        return list.map((model) => Product.fromJson(model)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 5. Obtener el detalle de un producto específico (US05)
  static Future<Product?> getProduct(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$id'));
      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 6. Actualizar un producto (US05 - Solo Admin)
  static Future<bool> updateProduct(int id, Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 7. Eliminar un producto (US05 - Solo Admin)
  static Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}