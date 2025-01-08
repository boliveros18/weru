class AdjuntoServicio {
  final int id;
  final String idServicio;
  final int idTecnico;
  final String titulo;
  final String descripcion;
  final String tipo;

  AdjuntoServicio({
    required this.id,
    required this.idServicio,
    required this.idTecnico,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idServicio': idServicio,
      'idTecnico': idTecnico,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
    };
  }

  @override
  String toString() {
    return 'AdjuntoServicio{id: $id, idServicio: $idServicio, idTecnico: $idTecnico, titulo: $titulo, descripcion: $descripcion, tipo: $tipo}';
  }
}
