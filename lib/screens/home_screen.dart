import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart'; // Crearemos este archivo en el siguiente paso

class HomeScreen extends StatefulWidget {
  final String username;
  final String password;

  const HomeScreen({Key? key, required this.username, required this.password}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _role = 'Cargando...';

  // Variables del catálogo (US03 y US04)
  List<Product> _products = [];
  List<String> _categories = ['Ver todos'];
  String _selectedCategory = 'Ver todos';
  bool _isLoading = true;
  bool _hasError = false;

  // --- COLORES EXTRAÍDOS DEL XML ---
  final Color bgLight = const Color(0xFFEAF2F8);
  final Color blueLight = const Color(0xFFBDD4E6);
  final Color blueDark = const Color(0xFF42627C);
  final Color navy = const Color(0xFF22344B);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final role = await SessionManager.getRole();
    setState(() => _role = role ?? 'Administrador');

    await _fetchCategories();
    await _fetchProducts(null);
  }

  Future<void> _fetchCategories() async {
    final cats = await ApiService.getCategories();
    if (cats != null && mounted) {
      setState(() {
        _categories = ['Ver todos', ...cats];
      });
    }
  }

  Future<void> _fetchProducts(String? category) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _products.clear(); // Limpieza en memoria requerida por la US04
    });

    final results = category == null || category == 'Ver todos'
        ? await ApiService.getProducts()
        : await ApiService.getProductsByCategory(category);

    if (mounted) {
      if (results != null) {
        setState(() {
          _products = results;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
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
        child: CustomScrollView(
          slivers: [
            // --- ENCABEZADO Y TARJETAS ORIGINALES ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 28, right: 28, top: 45, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mercado Preso', style: TextStyle(color: navy, fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('ADMINISTRATOR PANEL', style: TextStyle(color: blueDark, fontSize: 12, letterSpacing: 1.5)),
                    const SizedBox(height: 35),
                    Text('Bienvenido', style: TextStyle(color: navy, fontSize: 26, fontWeight: FontWeight.bold)),
                    Text('Panel de administración', style: TextStyle(color: blueDark, fontSize: 16)),
                    const SizedBox(height: 28),

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

                    // --- SECCIÓN DE CATÁLOGO (US03 y US04) ---
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Catálogo', style: TextStyle(color: navy, fontSize: 22, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: blueLight)
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              icon: Icon(Icons.arrow_drop_down, color: navy),
                              style: TextStyle(color: navy, fontWeight: FontWeight.bold),
                              items: _categories.map((String cat) {
                                return DropdownMenuItem(value: cat, child: Text(cat.toUpperCase(), style: const TextStyle(fontSize: 12)));
                              }).toList(),
                              onChanged: (value) {
                                if (value != null && value != _selectedCategory) {
                                  setState(() => _selectedCategory = value);
                                  _fetchProducts(value == 'Ver todos' ? null : value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),

            // --- GRID RECICLABLE DE PRODUCTOS ---
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            if (!_isLoading && _hasError)
              SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    children: [
                      const Text('Error al cargar el catálogo.', style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _fetchProducts(_selectedCategory == 'Ver todos' ? null : _selectedCategory),
                        style: ElevatedButton.styleFrom(backgroundColor: navy),
                        child: const Text('REINTENTAR', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
              ),
            if (!_isLoading && !_hasError)
              SliverPadding(
                padding: const EdgeInsets.only(left: 28, right: 28, bottom: 40),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final product = _products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(productId: product.id),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Image.network(product.image, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: navy, fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.green[700], fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _products.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}