class Orden {
  final String id;
  final DateTime fechaHora;
  final String comentarioTecnico;
  final String tecnicoResponsable;
  final String estadoEquipo;

  Orden({
    required this.id,
    required this.fechaHora,
    required this.comentarioTecnico,
    required this.tecnicoResponsable,
    required this.estadoEquipo,
  });
}