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

  factory Ciudad.fromMap(Map<String, dynamic> map) {
    return Ciudad(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      estado: map['estado'] as int,
    );
  }

  @override
  String toString() {
    return 'Ciudad{id: $id, nombre: $nombre, estado: $estado}';
  }
}
