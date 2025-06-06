import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:proyecto1/servicios/api_services.dart';

class ImageService {
  final ApiService api = ApiService();

  // Obtener imágenes por orden
  Future<List<dynamic>> obtenerImagenesPorOrden(int ordenId) async {
    return await api.get('images/orden/$ordenId');
  }

  Future<dynamic> crearImagen(Map<String, dynamic> data) async {
    return await api.post('images', data);
  }

  Future<dynamic> actualizarImagen(int id, Map<String, dynamic> data) async {
    return await api.put('images/$id', data);
  }

  Future<dynamic> eliminarImagen(int id) async {
    return await api.delete('images/$id');
  }

 Future<bool> subirArchivoImagen(File imagen, int ordenId) async {
  try {
    final uri = Uri.parse('${ApiService.baseUrl}images/upload');

    var request = http.MultipartRequest('POST', uri);
    request.fields['ordenId'] = ordenId.toString();

    var multipartFile = await http.MultipartFile.fromPath(
      'image',
      imagen.path,
      filename: basename(imagen.path),
    );
    request.files.add(multipartFile);

    var response = await request.send();

    print('Status code: ${response.statusCode}');
    final responseBody = await response.stream.bytesToString();
    print('Response body: $responseBody');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print('Excepción subirArchivoImagen: $e');
    return false;
  }
}

}
