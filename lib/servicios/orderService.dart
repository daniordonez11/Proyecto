import 'package:proyecto1/servicios/api_services.dart';

class OrdenService {
  final ApiService api = ApiService();

  Future<List<dynamic>> obtenerOrdenes() async {
    return await api.get('order');
  }

  Future<dynamic> crearOrden(Map<String, dynamic> data) async {
    return await api.post('order', data);
  }

  Future<dynamic> actualizarOrden(int id, Map<String, dynamic> data) async {
    return await api.put('order/$id', data);
  }

  Future<dynamic> eliminarOrden(int id) async {
    return await api.delete('order/$id');
  }
}
