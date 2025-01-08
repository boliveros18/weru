class Novedad {
  final int id;
  final String descripcion;
  final int estado;

  Novedad({
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
    return 'Novedad{id: $id, descripcion: $descripcion, estado: $estado}';
  }
}
