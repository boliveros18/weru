class EstadoServicio {
  final int id;
  final String nombre;
  final String descripcion;

  EstadoServicio({
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
    return 'EstadoServicio{id: $id, nombre: $nombre, descripcion: $descripcion}';
  }
}
