import 'package:flutter/material.dart';
import 'package:proyecto1/widgets/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetalleOrdenPage extends StatefulWidget {
  final Map orden;

  const DetalleOrdenPage({required this.orden, Key? key}) : super(key: key);

  @override
  State<DetalleOrdenPage> createState() => _DetalleOrdenPageState();
}

class _DetalleOrdenPageState extends State<DetalleOrdenPage> {
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
          children: entradasFiltradas.map((entry) {
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
        ),
      ),
    );
  }
}
