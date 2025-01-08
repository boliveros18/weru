class NovedadServicio {
  final int id;
  final int idServicio;
  final int idNovedad;

  NovedadServicio({
    required this.id,
    required this.idServicio,
    required this.idNovedad,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idServicio': idServicio,
      'idNovedad': idNovedad,
    };
  }

  @override
  String toString() {
    return 'NovedadServicio{id: $id, idServicio: $idServicio, idNovedad: $idNovedad}';
  }
}
