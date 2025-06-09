class Orden {
  final int usuarioId;
  final int id;
  final String nombreCliente;
  final int telefonoCliente;
  final String emailCliente;
  final String modeloPc;
  final int numeroSeriePc;
  final String estadoInicial;
  final String accesoriosEntregados;
  final String estado;
  final DateTime fechaHora;

  Orden({
    required this.usuarioId,
    required this.id,
    required this.nombreCliente,
    required this.telefonoCliente,
    required this.emailCliente,
    required this.modeloPc,
    required this.numeroSeriePc,
    required this.estadoInicial,
    required this.accesoriosEntregados,
    required this.estado,
    required this.fechaHora,
  });

  factory Orden.fromJson(Map<String, dynamic> json) {
    return Orden(
      usuarioId: int.tryParse(json['usuarioId'].toString()) ?? 0,
      id: int.tryParse(json['id'].toString()) ?? 0,
      nombreCliente: json['nombreCliente'] ?? '',
      telefonoCliente: int.tryParse(json['telefonoCliente'].toString()) ?? 0,
      emailCliente: json['emailCliente'] ?? '',
      modeloPc: json['modeloPc'] ?? '',
      numeroSeriePc: int.tryParse(json['numeroSeriePc'].toString()) ?? 0,
      estadoInicial: json['estadoInicial'] ?? '',
      accesoriosEntregados: json['accesoriosEntregados'] ?? '',
      estado: json['estado'] ?? '',
      fechaHora: DateTime.parse(json['createdAt']),
    );
  }
}
