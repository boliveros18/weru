class TipoItem {
  final int id;
  final String descripcion;

  TipoItem({
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
    return 'TipoItem{id: $id, descripcion: $descripcion}';
  }
}
