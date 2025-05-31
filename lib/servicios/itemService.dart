import 'package:proyecto1/servicios/api_services.dart';

class ItemService {
  final ApiService api = ApiService();

  Future<List<dynamic>> obtenerItems() async {
    return await api.get('/item');
  }

  Future<dynamic> crearItem(Map<String, dynamic> data) async {
    return await api.post('/item', data);
  }

  Future<dynamic> actualizarItem(int id, Map<String, dynamic> data) async {
    return await api.put('/item/$id', data);
  }

  Future<dynamic> eliminarItem(int id) async {
    return await api.delete('/item/$id');
  }
}
