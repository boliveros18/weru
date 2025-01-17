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

  factory EstadoServicio.fromMap(Map<String, dynamic> map) {
    return EstadoServicio(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String,
    );
  }

  @override
  String toString() {
    return 'EstadoServicio{id: $id, nombre: $nombre, descripcion: $descripcion}';
  }
}
