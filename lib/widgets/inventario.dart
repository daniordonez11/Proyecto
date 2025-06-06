import 'package:flutter/material.dart';
import 'package:proyecto1/clases/item.dart';
import 'package:proyecto1/servicios/itemService.dart'; // Asegúrate de tener este archivo

class InventarioPage extends StatefulWidget {
  const InventarioPage({Key? key}) : super(key: key);

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final ItemService itemService = ItemService();
  late Future<List<Inventario>> _inventarioFuture;

  @override
  void initState() {
    super.initState();
    _inventarioFuture = cargarInventario();
  }

  Future<List<Inventario>> cargarInventario() async {
    final datos = await itemService.obtenerItems();
    return datos.map<Inventario>((item) => Inventario.fromJson(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
      ),
      body: FutureBuilder<List<Inventario>>(
        future: _inventarioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay datos de inventario.'));
          }

          final inventario = snapshot.data!;

          return ListView.builder(
            itemCount: inventario.length,
            itemBuilder: (context, index) {
              final item = inventario[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(item.descripcion, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cantidad: ${item.cantidad}'),
                      Text('Observación: ${item.observacion}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
