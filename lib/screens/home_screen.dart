import 'package:flutter/material.dart';
import '../services/session_manager.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String password;

  const HomeScreen({Key? key, required this.username, required this.password}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _role = 'Cargando...';

  // --- COLORES EXTRAÍDOS DEL XML ---
  final Color bgLight = const Color(0xFFEAF2F8);
  final Color blueLight = const Color(0xFFBDD4E6);
  final Color blueDark = const Color(0xFF42627C);
  final Color navy = const Color(0xFF22344B);

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await SessionManager.getRole();
    setState(() {
      _role = role ?? 'Administrador';
    });
  }

  Future<void> _handleLogout() async {
    await SessionManager.clearSession();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: blueDark, fontSize: 13)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final maskedPassword = widget.password.isNotEmpty ? '•' * widget.password.length : '••••••••';

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 28, right: 28, top: 45, bottom: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MovieReviews', style: TextStyle(color: navy, fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('ADMINISTRATOR PANEL', style: TextStyle(color: blueDark, fontSize: 12, letterSpacing: 1.5)),
              const SizedBox(height: 35),
              Text('Bienvenido', style: TextStyle(color: navy, fontSize: 26, fontWeight: FontWeight.bold)),
              Text('Panel de administración', style: TextStyle(color: blueDark, fontSize: 16)),
              const SizedBox(height: 28),

              // Tarjeta API
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fake Store API', style: TextStyle(color: navy, fontSize: 19, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: blueLight.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                      child: Text('●  Conectado', style: TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Text('https://fakestoreapi.com/', style: TextStyle(color: blueDark, fontSize: 13)),
                  ],
                ),
              ),

              // Tarjeta Cuenta
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Información de la cuenta', style: TextStyle(color: navy, fontSize: 19, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    _buildInfoRow('Usuario', widget.username),
                    _buildInfoRow('Contraseña', maskedPassword),
                    _buildInfoRow('Rol', _role),
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: navy,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 25),
              Center(child: Text('MovieReviews · Administrator', style: TextStyle(color: blueDark, fontSize: 12))),
            ],
          ),
        ),
      ),
    );
  }
}