class ActividadModelo {
  final int id;
  final int idActividad;
  final int idModelo;

  ActividadModelo({
    required this.id,
    required this.idActividad,
    required this.idModelo,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idActividad': idActividad,
      'idModelo': idModelo,
    };
  }

  @override
  String toString() {
    return 'ActividadModelo{id: $id, idActividad: $idActividad, idModelo: $idModelo}';
  }
}
