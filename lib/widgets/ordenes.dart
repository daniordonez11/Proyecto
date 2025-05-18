import 'package:flutter/material.dart';
import 'package:proyecto1/clases/orden.dart';

class VerOrdenesPage extends StatelessWidget {
  VerOrdenesPage({super.key});
  final List<Orden> ordenes = [
    Orden(
      id: '1',
      fechaHora: DateTime.now().subtract(Duration(days: 2)),
      comentarioTecnico: 'Revisado y reparado problema de pantalla.',
      tecnicoResponsable: 'Técnico A',
      estadoEquipo: 'En proceso',
    ),
    Orden(
      id: '2',
      fechaHora: DateTime.now().subtract(Duration(days: 1)),
      comentarioTecnico: 'Actualización del sistema operativo.',
      tecnicoResponsable: 'Técnico B',
      estadoEquipo: 'Listo para entrega',
    ),
    Orden(
      id: '3',
      fechaHora: DateTime.now().subtract(Duration(hours: 10)),
      comentarioTecnico: 'Cambio de disco duro completado.',
      tecnicoResponsable: 'Técnico C',
      estadoEquipo: 'Recientemente entregado',
    ),
    Orden(
      id: '4',
      fechaHora: DateTime.now().subtract(Duration(days: 3)),
      comentarioTecnico: 'Diagnóstico inicial.',
      tecnicoResponsable: 'Técnico A',
      estadoEquipo: 'En proceso',
    ),
    // Puedes añadir más órdenes
  ];

  // Agrupa las órdenes por estado
  Map<String, List<Orden>> _agruparPorEstado(List<Orden> lista) {
    Map<String, List<Orden>> mapa = {};
    for (var orden in lista) {
      mapa.putIfAbsent(orden.estadoEquipo, () => []);
      mapa[orden.estadoEquipo]!.add(orden);
    }
    return mapa;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Orden>> ordenesPorEstado = _agruparPorEstado(ordenes);

    // Estados ordenados para mostrar en ese orden
    final List<String> estadosOrden = [
      'En proceso',
      'Listo para entrega',
      'Recientemente entregado'
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Órdenes por Estado')),
      body: ListView.builder(
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
                    return ListTile(
                      leading: Icon(Icons.computer),
                      title: Text('Técnico: ${orden.tecnicoResponsable}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fecha: ${orden.fechaHora.toLocal().toString().split(".")[0]}'),
                          Text('Nota: ${orden.comentarioTecnico}'),
                        ],
                      ),
                    );
                  }).toList(),
          );
        },
      ),
    );
  }
}
