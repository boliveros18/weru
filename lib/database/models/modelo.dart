class Modelo {
  final int id;
  final String descripcion;

  Modelo({
    required this.id,
    required this.descripcion,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
    };
  }

  @override
  String toString() {
    return 'Modelo{id: $id, descripcion: $descripcion}';
  }
}
