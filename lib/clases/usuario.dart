class Usuario {
  final int id;
  final String nombre;
  final bool accesoTotal;

  Usuario({required this.id, required this.nombre, required this.accesoTotal});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      accesoTotal: json['accesoTotal'] ?? false,
    );
  }
}
