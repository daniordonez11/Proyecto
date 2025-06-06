class Inventario {
  final int id;
  final String descripcion;
  final int cantidad;
  final String observacion;

  Inventario({
    required this.id,
    required this.descripcion,
    required this.cantidad,
    required this.observacion,
  });

  factory Inventario.fromJson(Map<String, dynamic> json) {
    return Inventario(
      id: json['id'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      observacion: json['observacion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'observacion': observacion,
    };
  }
}
