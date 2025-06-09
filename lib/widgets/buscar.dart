import 'package:flutter/material.dart';
import 'package:proyecto1/clases/orden.dart';
import 'package:proyecto1/servicios/orderService.dart';
import 'package:proyecto1/widgets/editarOrden.dart';

class BuscarOrdenPage extends StatefulWidget {
  const BuscarOrdenPage({super.key});
  @override
  _BuscarOrdenPageState createState() => _BuscarOrdenPageState();
}

class _BuscarOrdenPageState extends State<BuscarOrdenPage> {
  final OrdenService _ordenService = OrdenService();
  List<Orden> todasOrdenes = [];
  bool isLoading = true;

  String filtroEstado = 'Todos';
  String filtroTecnico = 'Todos';
  DateTime? filtroFecha;
  String busqueda = '';

  List<String> estados = [
    'Todos',
    'Recien llegada',
    'En proceso',
    'Listo para entrega',
    'Recientemente entregado',
  ];
  List<String> tecnicos = ['Todos'];

  List<Orden> get ordenesFiltradas {
    return todasOrdenes.where((orden) {
      final cumpleEstado =
          filtroEstado == 'Todos' || orden.estado == filtroEstado;
      final cumpleTecnico =
          filtroTecnico == 'Todos'; // No hay técnico en la nueva estructura
      final cumpleFecha =
          filtroFecha == null ||
          (orden.fechaHora.year == filtroFecha!.year &&
              orden.fechaHora.month == filtroFecha!.month &&
              orden.fechaHora.day == filtroFecha!.day);
      final cumpleBusqueda =
          busqueda.isEmpty ||
          orden.nombreCliente.toLowerCase().contains(busqueda.toLowerCase()) ||
          orden.id.toString().contains(busqueda);
      return cumpleEstado && cumpleTecnico && cumpleFecha && cumpleBusqueda;
    }).toList();
  }

  Future<void> cargarOrdenes() async {
    try {
      final respuesta = await _ordenService.obtenerOrdenes();
      final ordenes =
          respuesta.map<Orden>((json) => Orden.fromJson(json)).toList();

      setState(() {
        todasOrdenes = ordenes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    cargarOrdenes();
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
            icon: Icon(Icons.refresh),
            onPressed: cargarOrdenes,
            tooltip: 'Refrescar órdenes',
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _limpiarFiltros,
            tooltip: 'Limpiar filtros',
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: cargarOrdenes,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Buscar por ID o nombre del cliente',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => setState(() => busqueda = val),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: filtroEstado,
                              items:
                                  estados
                                      .map(
                                        (e) => DropdownMenuItem(
                                          child: Text(e),
                                          value: e,
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (val) => setState(
                                    () => filtroEstado = val ?? 'Todos',
                                  ),
                              decoration: InputDecoration(labelText: 'Estado'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
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
                              onPressed:
                                  () => setState(() => filtroFecha = null),
                              tooltip: 'Limpiar fecha',
                            ),
                        ],
                      ),
                      SizedBox(height: 20),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nombre cliente: ${orden.nombreCliente}',
                                      ),
                                      Text(
                                        'Teléfono: ${orden.telefonoCliente}',
                                      ),
                                      Text('Email: ${orden.emailCliente}'),
                                      Text('Modelo PC: ${orden.modeloPc}'),
                                      Text('Serie PC: ${orden.numeroSeriePc}'),
                                      Text(
                                        'Estado inicial: ${orden.estadoInicial}',
                                      ),
                                      Text(
                                        'Accesorios: ${orden.accesoriosEntregados}',
                                      ),
                                      Text('Estado actual: ${orden.estado}'),
                                      Text(
                                        'Fecha ingreso: ${orden.fechaHora.toLocal().toString().split(".")[0]}',
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                editarOrden(orden: orden),
                                      ),
                                    );
                                    // Acción futura
                                  },
                                ),
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ),
    );
  }
}
