import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  String _userRole = '';

  final Color bgLight = const Color(0xFFEAF2F8);
  final Color navy = const Color(0xFF22344B);

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final role = await SessionManager.getRole();
    _userRole = role ?? '';

    final result = await ApiService.getProduct(widget.productId);
    if (mounted) {
      if (result != null) {
        setState(() {
          _product = result;
          _isLoading = false;
        });
      } else {
        _showUnavailableAndReturn();
      }
    }
  }

  void _showUnavailableAndReturn() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Producto no disponible', style: TextStyle(color: navy)),
        content: const Text('Regresando al catálogo...'),
      ),
    );
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context); // Cierra el diálogo
        Navigator.pop(context); // Cierra la pantalla de detalles
      }
    });
  }

  // US07: Editar información del producto
  void _showEditDialog() {
    final titleCtrl = TextEditingController(text: _product!.title);
    final priceCtrl = TextEditingController(text: _product!.price.toString());
    final descCtrl = TextEditingController(text: _product!.description);
    final catCtrl = TextEditingController(text: _product!.category);
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: !isSaving,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Editar producto', style: TextStyle(color: navy)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Título'),
                    enabled: !isSaving,
                  ),
                  TextField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: 'Precio'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: !isSaving,
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    enabled: !isSaving,
                  ),
                  TextField(
                    controller: catCtrl,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    enabled: !isSaving,
                  ),
                ],
              ),
            ),
            actions: [
              if (!isSaving)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: navy),
                onPressed: isSaving ? null : () async {
                  final priceParsed = double.tryParse(priceCtrl.text);

                  // Validación Frontend (Precio numérico y sin campos vacíos)
                  if (titleCtrl.text.trim().isEmpty ||
                      priceCtrl.text.trim().isEmpty ||
                      priceParsed == null ||
                      descCtrl.text.trim().isEmpty ||
                      catCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ingresa un precio válido y completa todos los campos')),
                    );
                    return;
                  }

                  setDialogState(() => isSaving = true);

                  final updated = Product(
                    id: _product!.id,
                    title: titleCtrl.text.trim(),
                    price: priceParsed,
                    description: descCtrl.text.trim(),
                    category: catCtrl.text.trim(),
                    image: _product!.image,
                    rating: _product!.rating,
                  );

                  final success = await ApiService.updateProduct(_product!.id, updated);

                  if (mounted) {
                    if (success) {
                      setState(() => _product = updated);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Producto actualizado (Simulación)')),
                      );
                    } else {
                      setDialogState(() => isSaving = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al actualizar el producto')),
                      );
                    }
                  }
                },
                child: isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text('Guardar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // US08: Eliminar producto
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Eliminar producto', style: TextStyle(color: navy)),
        content: const Text('¿Estás seguro de eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () async {
              Navigator.pop(context); // Cierra el cuadro de diálogo

              final success = await ApiService.deleteProduct(_product!.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Producto eliminado exitosamente')),
                );
                Navigator.pop(context); // Redirige al usuario de vuelta al catálogo general
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al eliminar el producto')),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(backgroundColor: navy, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text('Detalle del Artículo', style: TextStyle(fontSize: 18)),
        backgroundColor: navy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Image.network(_product!.image, height: 220, fit: BoxFit.contain),
            ),
            const SizedBox(height: 25),
            Text('\$${_product!.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 32, color: Colors.green[700], fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_product!.title, style: TextStyle(fontSize: 22, color: navy, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFBDD4E6), borderRadius: BorderRadius.circular(8)),
              child: Text(_product!.category.toUpperCase(), style: TextStyle(color: navy, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 25),
            Text('Descripción', style: TextStyle(fontSize: 18, color: navy, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_product!.description, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[600], size: 20),
                const SizedBox(width: 5),
                Text('${_product!.rating.rate} (${_product!.rating.count} reseñas)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 35),

            // US05, US07, US08: Visibles únicamente para rol Administrador
            if (_userRole == 'Administrador')
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showEditDialog,
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('EDITAR PRODUCTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navy,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    label: const Text('ELIMINAR PRODUCTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}