class ImageOrden {
  final int id;
  final String urlImagen;
  final String nombre;

  ImageOrden({required this.id, required this.urlImagen, required this.nombre});

  factory ImageOrden.fromJson(Map<String, dynamic> json) {
    return ImageOrden(
      id: json['id'],
      urlImagen: json['urlImagen'],
      nombre: json['nombre'],
    );
  }
}