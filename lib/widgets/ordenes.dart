import 'package:flutter/material.dart';
import 'package:proyecto1/clases/orden.dart';
import 'package:proyecto1/servicios/orderService.dart';

class VerOrdenesPage extends StatefulWidget {
  const VerOrdenesPage({super.key});

  @override
  State<VerOrdenesPage> createState() => _VerOrdenesPageState();
}

class _VerOrdenesPageState extends State<VerOrdenesPage> {
  final OrdenService _ordenService = OrdenService();
  List<Orden> todasOrdenes = [];
  bool isLoading = true;

  final List<String> estadosOrden = [
    'En proceso',
    'Listo para entrega',
    'Recientemente entregado',
  ];

  Map<String, List<Orden>> _agruparPorEstado(List<Orden> lista) {
    Map<String, List<Orden>> mapa = {};
    for (var orden in lista) {
      mapa.putIfAbsent(orden.estado, () => []);
      mapa[orden.estado]!.add(orden);
    }
    return mapa;
  }

  Future<void> cargarOrdenes() async {
    try {
      final respuesta = await _ordenService.obtenerOrdenes();
      final ordenes = respuesta.map<Orden>((json) => Orden.fromJson(json)).toList();
      setState(() {
        todasOrdenes = ordenes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar órdenes: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    cargarOrdenes();
  }

  @override
  Widget build(BuildContext context) {
    final ordenesPorEstado = _agruparPorEstado(todasOrdenes);

    return Scaffold(
      appBar: AppBar(title: Text('Órdenes por Estado')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: cargarOrdenes,
              child: ListView.builder(
                itemCount: estadosOrden.length,
                itemBuilder: (context, index) {
                  final estado = estadosOrden[index];
                  final listaEstado = ordenesPorEstado[estado] ?? [];

                  return ExpansionTile(
                    title: Text('$estado (${listaEstado.length})'),
                    initiallyExpanded: true,
                    children: listaEstado.isEmpty
                        ? [ListTile(title: Text('No hay órdenes'))]
                        : listaEstado.map((orden) {
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: ListTile(
                                leading: Icon(Icons.build),
                                title: Text('Orden ID: ${orden.id}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Nombre cliente: ${orden.nombreCliente}'),
                                    Text('Teléfono: ${orden.telefonoCliente}'),
                                    Text('Email: ${orden.emailCliente}'),
                                    Text('Modelo PC: ${orden.modeloPc}'),
                                    Text('Serie PC: ${orden.numeroSeriePc}'),
                                    Text('Estado inicial: ${orden.estadoInicial}'),
                                    Text('Accesorios: ${orden.accesoriosEntregados}'),
                                    Text('Estado actual: ${orden.estado}'),
                                    Text('Fecha ingreso: ${orden.fechaHora.toLocal().toString().split(".")[0]}'),
                                  ],
                                ),
                                onTap: () {
                                  // Acción futura aquí
                                },
                              ),
                            );
                          }).toList(),
                  );
                },
              ),
            ),
    );
  }
}
