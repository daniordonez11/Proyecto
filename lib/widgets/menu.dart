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
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4B30),
        title: Row(
          children: [
            Image.asset(
              'assets/images/jds.png',
              height: 40,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Bienvenido, $nombre',
                style: const TextStyle(fontSize: 16, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: cerrarSesion,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF0B4B30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/jds.png', height: 60),
                  const SizedBox(height: 10),
                  Text(
                    'Usuario: $nombre',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    'ID: $usuarioId',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.computer),
              title: const Text('Registrar equipo'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => RegistroEquipos()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Clasificación de Ordenes'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => VerOrdenesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Buscar Orden'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => BuscarOrdenPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Inventario General'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => InventarioPage()));
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fondo.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Panel Principal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (accesoTotal == true) ...[
                    customButton(Icons.computer, 'Registrar equipo', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => RegistroEquipos()));
                    }),
                    const SizedBox(height: 20),
                    customButton(Icons.list_alt, 'Clasificación de Ordenes', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => VerOrdenesPage()));
                    }),
                    const SizedBox(height: 20),
                  ],

                  customButton(Icons.search, 'Buscar Orden', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => BuscarOrdenPage()));
                  }),
                  const SizedBox(height: 20),
                  customButton(Icons.inventory, 'Ver Inventario', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => InventarioPage()));
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget customButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0B4B30),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
      ),
      icon: Icon(icon, size: 24),
      label: Text(label, style: const TextStyle(fontSize: 16)),
      onPressed: onPressed,
    );
  }
}
