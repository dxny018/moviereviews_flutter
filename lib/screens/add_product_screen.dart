import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _catCtrl = TextEditingController();

  bool _isSubmitting = false;
  bool _isCheckingRole = true;

  final Color bgLight = const Color(0xFFEAF2F8);
  final Color navy = const Color(0xFF22344B);

  @override
  void initState() {
    super.initState();
    _verifyAdminRole();
  }

  // US06 - Escenario 3: Bloquear acceso a usuarios sin rol de Administrador
  Future<void> _verifyAdminRole() async {
    final role = await SessionManager.getRole();
    if (mounted) {
      if (role != 'Administrador') {
        Navigator.pop(context); // Redirige inmediatamente al catálogo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acceso restringido: Solo Administradores')),
        );
      } else {
        setState(() {
          _isCheckingRole = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    _catCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // US06 - Escenario 2: Validaciones Frontend locales antes de enviar la petición
    if (!_formKey.currentState!.validate()) {
      return; // Resalta en rojo los campos obligatorios o erróneos
    }

    setState(() => _isSubmitting = true);

    final productData = {
      'title': _titleCtrl.text.trim(),
      'price': double.parse(_priceCtrl.text.trim()),
      'description': _descCtrl.text.trim(),
      'image': _imageCtrl.text.trim(),
      'category': _catCtrl.text.trim(),
    };

    final response = await ApiService.addProduct(productData);

    if (mounted) {
      setState(() => _isSubmitting = false);

      // US06 - Escenario 1: Creación exitosa y respuesta simulada de la API
      if (response != null && response.containsKey('id')) {
        final newId = response['id'];
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Producto Creado', style: TextStyle(color: navy)),
            content: Text('El producto fue registrado exitosamente con el ID asignado: $newId'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra la alerta
                  _formKey.currentState!.reset(); // Limpia los campos del formulario
                  _titleCtrl.clear();
                  _priceCtrl.clear();
                  _descCtrl.clear();
                  _imageCtrl.clear();
                  _catCtrl.clear();
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar la petición a la API')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingRole) {
      return Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(backgroundColor: navy, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text('Agregar Nuevo Producto', style: TextStyle(fontSize: 18)),
        backgroundColor: navy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Registro de Inventario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: navy)),
                const SizedBox(height: 20),

                // Campo: Título
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título del producto *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo: Precio
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Precio *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (double.tryParse(val.trim()) == null) {
                      return 'Ingresa un precio numérico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo: Categoría
                TextFormField(
                  controller: _catCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Categoría *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo: URL Imagen
                TextFormField(
                  controller: _imageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL de la Imagen *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    final uri = Uri.tryParse(val.trim());
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'Ingresa una URL con formato válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo: Descripción
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botón Guardar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: navy),
                    onPressed: _isSubmitting ? null : _submitForm,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('GUARDAR PRODUCTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}