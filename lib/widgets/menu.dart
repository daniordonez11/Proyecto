import 'package:flutter/material.dart';
import 'package:proyecto1/widgets/ingreso.dart';
import 'package:proyecto1/widgets/inventario.dart';
import 'package:proyecto1/widgets/login.dart';
import 'package:proyecto1/widgets/ordenes.dart';
import 'package:proyecto1/widgets/buscar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool? accesoTotal;
  int? usuarioId;
  String? nombre;

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    bool acceso = prefs.getBool('accesoTotal') ?? false;
    int? id = prefs.getInt('usuarioId');
    String? name = prefs.getString('nombre');
    setState(() {
      accesoTotal = acceso;
      usuarioId = id;
      nombre = name;
    });
  }

  void cerrarSesion() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Borra todos los datos guardados
  if (mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false, // Elimina todas las rutas anteriores
    );
  }
}

  @override
  Widget build(BuildContext context) {
    if (accesoTotal == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Menú Principal - ID de Usuario: $usuarioId - Nombre: $nombre'),
      actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Cerrar sesión',
      onPressed: cerrarSesion,
    ),
  ],),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/jds.png',
              height: 100,
            ),
            const SizedBox(height: 100),

            if (accesoTotal == true) ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.computer),
                label: const Text('Registrar equipo'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistroEquipos()),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text('Clasificacion de Ordenes'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VerOrdenesPage()),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
            ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Buscar Orden'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BuscarOrdenPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.inventory),
              label: const Text('Ver Inventario'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InventarioPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

