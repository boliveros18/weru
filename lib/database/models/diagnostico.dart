class Diagnostico {
  final int id;
  final String descripcion;
  final int estado;

  Diagnostico({
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
    return 'Diagnostico{id: $id, descripcion: $descripcion, estado: $estado}';
  }
}
