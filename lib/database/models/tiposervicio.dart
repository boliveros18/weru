class TipoServicio {
  final int id;
  final String descripcion;

  TipoServicio({
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
    return 'TipoServicio{id: $id, descripcion: $descripcion}';
  }
}
