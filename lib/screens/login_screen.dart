import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../utils/role_manager.dart';
import '../models/login_model.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  // --- COLORES EXTRAÍDOS DEL XML ---
  final Color bgLight = const Color(0xFFEAF2F8);
  final Color blueLight = const Color(0xFFBDD4E6);
  final Color blueDark = const Color(0xFF42627C);
  final Color navy = const Color(0xFF22344B);
  final Color errorRed = const Color(0xFFC62828);

  dynamic _getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      String payload = parts[1];
      String normalized = base64Url.normalize(payload);
      String resp = utf8.decode(base64Url.decode(normalized));
      final jsonPayload = json.decode(resp);
      return jsonPayload['sub'];
    } catch (e) {
      print('🔴 Error decodificando Token: $e');
      return null;
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Completa usuario y contraseña';
        _isLoading = false;
      });
      return;
    }

    try {
      final request = LoginRequest(username: username, password: password);
      final token = await ApiService.login(request);

      if (token != null) {
        final rawUserId = _getUserIdFromToken(token);
        if (rawUserId != null) {
          final int userId = rawUserId is int ? rawUserId : int.parse(rawUserId.toString());
          final String role = RoleManager.obtenerRolPorId(userId) ?? 'Administrador';

          await SessionManager.saveSession(token, userId, role);

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(username: username, password: password),
              ),
                  (Route<dynamic> route) => false,
            );
          }
        } else {
          setState(() => _errorMessage = 'No se pudo identificar al usuario');
        }
      } else {
        setState(() => _errorMessage = 'Usuario o contraseña inválidos');
      }
    } catch (e) {
      print('🔴 Error al procesar sesión: $e');
      setState(() => _errorMessage = 'Error al iniciar sesión');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          Positioned(
            top: -90,
            left: -90,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(color: blueLight.withOpacity(0.5), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: -130,
            right: -130,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(color: blueLight.withOpacity(0.5), shape: BoxShape.circle),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 32, right: 32, top: 20, bottom: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🫱🏿‍🫲🏾', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 5),
                    Text('Mercado Preso', style: TextStyle(color: navy, fontSize: 34, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text('DISCOVER  ·  REVIEW  ·  SHARE', style: TextStyle(color: blueDark, fontSize: 12, letterSpacing: 1.5)),
                    const SizedBox(height: 55),
                    Text('Member Login', style: TextStyle(color: navy, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Sign in to continue', style: TextStyle(color: blueDark, fontSize: 16)),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _usernameController,
                      style: TextStyle(color: navy, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Usuario',
                        hintStyle: TextStyle(color: blueDark),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: navy, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        hintStyle: TextStyle(color: blueDark),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navy,
                        minimumSize: const Size(double.infinity, 58),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('SIGN IN', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 15),
                    Text(_errorMessage, style: TextStyle(color: errorRed, fontSize: 14)),
                    const SizedBox(height: 25),
                    Text('MovieReviews', style: TextStyle(color: blueDark, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}