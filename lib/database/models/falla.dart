class Falla {
  final int id;
  final String descripcion;
  final int estado;

  Falla({
    required this.id,
    required this.descripcion,
    required this.estado,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
      'estado': estado,
    };
  }

  @override
  String toString() {
    return 'Falla{id: $id, descripcion: $descripcion, estado: $estado}';
  }
}
