
import 'package:proyecto1/servicios/api_services.dart';

class UsuarioService {
  final ApiService api = ApiService();

  Future<List<dynamic>> obtenerUsuarios() async {
    return await api.get('/');
  }

  Future<dynamic> crearUsuario(Map<String, dynamic> data) async {
    return await api.post('/', data);
  }

  Future<dynamic> actualizarUsuario(int id, Map<String, dynamic> data) async {
    return await api.put('/$id', data);
  }

  Future<dynamic> eliminarUsuario(int id) async {
    return await api.delete('/$id');
  }
}
