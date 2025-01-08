class ValoresIndicador {
  final int id;
  final int idIndicador;
  final String descripcion;

  ValoresIndicador({
    required this.id,
    required this.idIndicador,
    required this.descripcion,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idIndicador': idIndicador,
      'descripcion': descripcion,
    };
  }

  @override
  String toString() {
    return 'ValoresIndicador{id: $id, idIndicador: $idIndicador, descripcion: $descripcion}';
  }
}
