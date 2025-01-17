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

  factory Modelo.fromMap(Map<String, dynamic> map) {
    return Modelo(
      id: map['id'] as int,
      descripcion: map['descripcion'] as String,
    );
  }

  @override
  String toString() {
    return 'Modelo{id: $id, descripcion: $descripcion}';
  }
}
