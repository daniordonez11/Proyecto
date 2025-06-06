import 'package:flutter/material.dart';
import 'package:proyecto1/widgets/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto1/servicios/imageService.dart';  // Importa tu servicio de imágenes

class DetalleOrdenPage extends StatefulWidget {
  final Map orden;

  const DetalleOrdenPage({required this.orden, Key? key}) : super(key: key);

  @override
  State<DetalleOrdenPage> createState() => _DetalleOrdenPageState();
}

class _DetalleOrdenPageState extends State<DetalleOrdenPage> {
  final ImageService _imageService = ImageService();

  List<dynamic> imagenes = [];
  bool cargandoImagenes = true;
  String? errorImagenes;

  @override
  void initState() {
    super.initState();
    cargarImagenes();
  }

  Future<void> cargarImagenes() async {
    setState(() {
      cargandoImagenes = true;
      errorImagenes = null;
    });
    try {
      // Convierte el id a int, asumiendo que viene como String o dynamic
      int ordenId = widget.orden['id'] is int
          ? widget.orden['id']
          : int.parse(widget.orden['id'].toString());

      final imgs = await _imageService.obtenerImagenesPorOrden(ordenId);
      setState(() {
        imagenes = imgs;
      });
    } catch (e) {
      setState(() {
        errorImagenes = 'Error cargando imágenes: $e';
      });
    } finally {
      setState(() {
        cargandoImagenes = false;
      });
    }
  }

  void cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  String formatoTitulo(String key) {
    Map<String, String> nombresFormales = {
      'usuarioId': 'ID DEL USUARIO',
      'nombreCliente': 'NOMBRE DEL CLIENTE',
      'modeloPc': 'MODELO DEL PC',
      'descripcion': 'DESCRIPCIÓN',
      'cantidad': 'CANTIDAD',
      'createdAt': 'FECHA DE INGRESO DEL EQUIPO',
    };

    if (nombresFormales.containsKey(key)) {
      return nombresFormales[key]!;
    }

    String result = key.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (Match m) => '${m.group(1)} ${m.group(2)}',
    );

    result = result.replaceAll('_', ' ');

    return result.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final entradasFiltradas = widget.orden.entries
        .where((entry) => entry.key.toLowerCase() != 'updatedat')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Orden'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: cerrarSesion,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ...entradasFiltradas.map((entry) {
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    formatoTitulo(entry.key),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    entry.value.toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),
            const Text(
              'Imágenes de la orden:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            if (cargandoImagenes)
              const Center(child: CircularProgressIndicator()),
            if (errorImagenes != null)
              Text(
                errorImagenes!,
                style: const TextStyle(color: Colors.red),
              ),
            if (!cargandoImagenes && imagenes.isEmpty)
              const Text('No hay imágenes para esta orden.'),
            if (!cargandoImagenes && imagenes.isNotEmpty)
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imagenes.length,
                  itemBuilder: (context, index) {
                    final img = imagenes[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          img['urlImagen'] ?? '', // Ajusta según tu json
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              width: 150,
                              height: 150,
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
