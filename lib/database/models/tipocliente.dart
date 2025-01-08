class TipoCliente {
  final int id;
  final String nombre;
  final String descripcion;

  TipoCliente({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  @override
  String toString() {
    return 'TipoCliente{id: $id, nombre: $nombre, descripcion: $descripcion}';
  }
}
