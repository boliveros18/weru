class Indicador {
  final int id;
  final int idEstadoIndicador;
  final String descripcion;
  final double valorMin;
  final double valorMax;
  final String tipo;
  final String icono;

  Indicador({
    required this.id,
    required this.idEstadoIndicador,
    required this.descripcion,
    required this.valorMin,
    required this.valorMax,
    required this.tipo,
    required this.icono,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idEstadoIndicador': idEstadoIndicador,
      'descripcion': descripcion,
      'valorMin': valorMin,
      'valorMax': valorMax,
      'tipo': tipo,
      'icono': icono,
    };
  }

  @override
  String toString() {
    return 'Indicador{id: $id, idEstadoIndicador: $idEstadoIndicador, descripcion: $descripcion, valorMin: $valorMin, valorMax: $valorMax, tipo: $tipo, icono: $icono}';
  }
}
