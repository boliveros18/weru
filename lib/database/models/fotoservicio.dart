class FotoServicio {
  final int id;
  final int idServicio;
  final String archivo;
  final String comentario;

  FotoServicio({
    required this.id,
    required this.idServicio,
    required this.archivo,
    required this.comentario,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idServicio': idServicio,
      'archivo': archivo,
      'comentario': comentario,
    };
  }

  @override
  String toString() {
    return 'FotoServicio{id: $id, idServicio: $idServicio, archivo: $archivo, comentario: $comentario}';
  }
}
