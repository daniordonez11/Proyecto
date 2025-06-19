import 'package:flutter/material.dart';
import 'package:proyecto1/clases/item.dart';
import 'package:proyecto1/clases/orden.dart';
import 'package:proyecto1/servicios/itemService.dart';
import 'package:proyecto1/servicios/orderService.dart';
import 'package:proyecto1/widgets/buscar.dart';
import 'package:proyecto1/widgets/ingreso.dart';
import 'package:proyecto1/widgets/inventario.dart';
import 'package:proyecto1/widgets/login.dart';
import 'package:proyecto1/widgets/ordenes.dart';
import 'package:proyecto1/widgets/editarOrden.dart';
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

  late Future<List<Inventario>> _inventarioBajoFuture;
  List<Orden> todasOrdenes = [];
  bool cargandoOrdenes = true;

  final List<String> categorias = [
    'Recien llegado',
    'En proceso',
    'Listo para entrega',
    'Recientemente entregado',
  ];

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
    cargarOrdenesRecientes();
    _inventarioBajoFuture = obtenerInventarioBajo();
  }

  Future<List<Inventario>> obtenerInventarioBajo() async {
  final items = await ItemService().obtenerItems();
  return items
      .map((e) => Inventario.fromJson(e))
      .where((item) => item.cantidad < 5)
      .toList();
}

  Future<void> cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      accesoTotal = prefs.getBool('accesoTotal') ?? false;
      usuarioId = prefs.getInt('usuarioId');
      nombre = prefs.getString('nombre');
    });
  }

  Future<void> cargarOrdenesRecientes() async {
    try {
      final data = await OrdenService().obtenerOrdenes();
      final ordenes = data.map<Orden>((json) => Orden.fromJson(json)).toList();

      ordenes.sort(
        (a, b) => b.fechaHora.compareTo(a.fechaHora),
      ); // más recientes primero

      setState(() {
        todasOrdenes = ordenes;
        cargandoOrdenes = false;
      });
    } catch (e) {
      setState(() {
        cargandoOrdenes = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar órdenes: $e')));
    }
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4B30),
        title: Row(
          children: [
            Image.asset('assets/images/jds.png', height: 40),
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
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: cerrarSesion,
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white.withOpacity(0.95),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0B4B30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/jds.png', height: 60),
                  const SizedBox(height: 10),
                  Text(
                    'Usuario: $nombre',
                    style: const TextStyle(color: Colors.white),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegistroEquipos()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Clasificación de Ordenes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VerOrdenesPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Buscar Orden'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BuscarOrdenPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Inventario General'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => InventarioPage()),
                );
                setState(() {
      _inventarioBajoFuture = obtenerInventarioBajo();
    });
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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  const SizedBox(height: 30),

                  if (accesoTotal == true) ...[
                    customButton(Icons.computer, 'Registrar equipo', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegistroEquipos()),
                      );
                    }),
                    const SizedBox(height: 20),
                    customButton(
                      Icons.list_alt,
                      'Clasificación de Ordenes',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => VerOrdenesPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  customButton(Icons.search, 'Buscar Orden', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BuscarOrdenPage()),
                    );
                  }),
                  const SizedBox(height: 20),
                  customButton(Icons.inventory, 'Ver Inventario', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => InventarioPage()),
                    );
                  }),
                  const SizedBox(height: 30),
                  FutureBuilder<List<Inventario>>(
                    future: _inventarioBajoFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error al cargar inventario: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox(); // No mostrar nada si no hay stock bajo
                      }

                      final inventarioBajo = snapshot.data!;
                      return Card(
                        color: Colors.red.shade50.withOpacity(0.95),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Inventario con stock bajo (menos de 5)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                              ),
                              const Divider(),
                              ...inventarioBajo.map(
                                (item) => ListTile(
                                  leading: const Icon(
                                    Icons.warning,
                                    color: Colors.red,
                                  ),
                                  title: Text(item.descripcion),
                                  trailing: Text('Cantidad: ${item.cantidad}'),
                                  subtitle: Text('Obs: ${item.observacion}'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  if (!cargandoOrdenes) ...[
                    Text(
                      'Órdenes más recientes por estado',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...categorias.map((categoria) {
                      final filtradas =
                          todasOrdenes
                              .where((o) => o.estado == categoria)
                              .take(3)
                              .toList();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        color: Colors.white.withOpacity(0.95),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categoria,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B4B30),
                                ),
                              ),
                              const Divider(),
                              if (filtradas.isEmpty)
                                Text(
                                  'Sin órdenes recientes',
                                  style: TextStyle(color: Colors.black54),
                                )
                              else
                                ...filtradas.map(
                                  (orden) => ListTile(
                                    dense: true,
                                    leading: Icon(
                                      Icons.assignment,
                                      color: Colors.grey[700],
                                    ),
                                    title: Text(
                                      'Orden #${orden.id} - ${orden.nombreCliente}',
                                    ),
                                    subtitle: Text(
                                      'Fecha: ${orden.fechaHora.toLocal().toString().split(".")[0]}',
                                    ),
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => editarOrden(orden: orden),
                                        ),
                                      );
                                      await cargarOrdenesRecientes();
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
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
