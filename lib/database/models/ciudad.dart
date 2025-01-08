class Ciudad {
  final int id;
  final String nombre;
  final int estado;

  Ciudad({
    required this.id,
    required this.nombre,
    required this.estado,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'estado': estado,
    };
  }

  @override
  String toString() {
    return 'Ciudad{id: $id, nombre: $nombre, estado: $estado}';
  }
}
