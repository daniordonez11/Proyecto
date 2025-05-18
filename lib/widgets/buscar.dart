import 'package:flutter/material.dart';
import 'package:proyecto1/clases/orden.dart';
//import 'package:proyecto1/widgets/ordenes.dart';

class BuscarOrdenPage extends StatefulWidget {
  const BuscarOrdenPage({super.key});
  @override
  _BuscarOrdenPageState createState() => _BuscarOrdenPageState();
}

class _BuscarOrdenPageState extends State<BuscarOrdenPage> {
  final List<Orden> todasOrdenes = [
    Orden(
      id: '1',
      fechaHora: DateTime.now().subtract(Duration(days: 2)),
      comentarioTecnico: 'Reparación pantalla',
      tecnicoResponsable: 'Técnico A',
      estadoEquipo: 'En proceso',
    ),
    Orden(
      id: '2',
      fechaHora: DateTime.now().subtract(Duration(days: 1)),
      comentarioTecnico: 'Actualización sistema',
      tecnicoResponsable: 'Técnico B',
      estadoEquipo: 'Listo para entrega',
    ),
    Orden(
      id: '3',
      fechaHora: DateTime.now().subtract(Duration(hours: 10)),
      comentarioTecnico: 'Cambio disco duro',
      tecnicoResponsable: 'Técnico C',
      estadoEquipo: 'Recientemente entregado',
    ),
  ];

  String filtroEstado = 'Todos';
  String filtroTecnico = 'Todos';
  DateTime? filtroFecha;
  String busqueda = '';

  List<String> estados = ['Todos', 'En proceso', 'Listo para entrega', 'Recientemente entregado'];
  List<String> tecnicos = ['Todos', 'Técnico A', 'Técnico B', 'Técnico C'];

  List<Orden> get ordenesFiltradas {
    return todasOrdenes.where((orden) {
      final cumpleEstado = filtroEstado == 'Todos' || orden.estadoEquipo == filtroEstado;
      final cumpleTecnico = filtroTecnico == 'Todos' || orden.tecnicoResponsable == filtroTecnico;
      final cumpleFecha = filtroFecha == null ||
          (orden.fechaHora.year == filtroFecha!.year &&
           orden.fechaHora.month == filtroFecha!.month &&
           orden.fechaHora.day == filtroFecha!.day);

      final cumpleBusqueda = busqueda.isEmpty ||
          orden.comentarioTecnico.toLowerCase().contains(busqueda.toLowerCase()) ||
          orden.id.contains(busqueda);

      return cumpleEstado && cumpleTecnico && cumpleFecha && cumpleBusqueda;
    }).toList();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: filtroFecha ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        filtroFecha = picked;
      });
    }
  }

  void _limpiarFiltros() {
    setState(() {
      filtroEstado = 'Todos';
      filtroTecnico = 'Todos';
      filtroFecha = null;
      busqueda = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Orden'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _limpiarFiltros,
            tooltip: 'Limpiar filtros',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo búsqueda
            TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por ID o comentario',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => busqueda = val),
            ),
            SizedBox(height: 15),

            // Filtros de estado y técnico
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: filtroEstado,
                    items: estados
                        .map((e) => DropdownMenuItem(child: Text(e), value: e))
                        .toList(),
                    onChanged: (val) => setState(() => filtroEstado = val ?? 'Todos'),
                    decoration: InputDecoration(labelText: 'Estado'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: filtroTecnico,
                    items: tecnicos
                        .map((e) => DropdownMenuItem(child: Text(e), value: e))
                        .toList(),
                    onChanged: (val) => setState(() => filtroTecnico = val ?? 'Todos'),
                    decoration: InputDecoration(labelText: 'Técnico'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Filtro por fecha
            Row(
              children: [
                Expanded(
                  child: Text(
                    filtroFecha == null
                        ? 'Fecha ingreso: Todos'
                        : 'Fecha ingreso: ${filtroFecha!.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _seleccionarFecha(context),
                  child: Text('Seleccionar fecha'),
                ),
                if (filtroFecha != null)
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () => setState(() => filtroFecha = null),
                    tooltip: 'Limpiar fecha',
                  ),
              ],
            ),
            SizedBox(height: 20),

            // Lista de resultados
            ordenesFiltradas.isEmpty
                ? Center(child: Text('No se encontraron órdenes'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: ordenesFiltradas.length,
                    itemBuilder: (context, index) {
                      final orden = ordenesFiltradas[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Icon(Icons.build),
                          title: Text('Orden ID: ${orden.id}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fecha: ${orden.fechaHora.toLocal().toString().split(".")[0]}'),
                              Text('Estado: ${orden.estadoEquipo}'),
                              Text('Técnico: ${orden.tecnicoResponsable}'),
                              Text('Nota: ${orden.comentarioTecnico}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}