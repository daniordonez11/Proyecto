import 'dart:async';
import 'package:proyecto1/clases/item.dart';
import 'package:proyecto1/clases/orden.dart';
import 'package:proyecto1/servicios/itemService.dart';
import 'package:proyecto1/servicios/orderService.dart';

class OrdenInventarioNotifier {
  static final OrdenInventarioNotifier _instance = OrdenInventarioNotifier._internal();
  factory OrdenInventarioNotifier() => _instance;
  OrdenInventarioNotifier._internal();

  final _inventarioController = StreamController<List<Inventario>>.broadcast();
  final _ordenesController = StreamController<List<Orden>>.broadcast();

  Stream<List<Inventario>> get inventarioStream => _inventarioController.stream;
  Stream<List<Orden>> get ordenesStream => _ordenesController.stream;

  Future<void> actualizarInventario() async {
    final items = await ItemService().obtenerItems();
    final bajos = items
        .map((e) => Inventario.fromJson(e))
        .where((item) => item.cantidad < 5)
        .toList();
    _inventarioController.add(bajos);
  }

  Future<void> actualizarOrdenes() async {
    final data = await OrdenService().obtenerOrdenes();
    final ordenes = data.map<Orden>((e) => Orden.fromJson(e)).toList();
    ordenes.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
    _ordenesController.add(ordenes);
  }

  void dispose() {
    _inventarioController.close();
    _ordenesController.close();
  }
}
