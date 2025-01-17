class IndicadorServicio {
  final int id;
  final int idIndicador;
  final int idServicio;
  final int idTecnico;
  final String valor;

  IndicadorServicio({
    required this.id,
    required this.idIndicador,
    required this.idServicio,
    required this.idTecnico,
    required this.valor,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idIndicador': idIndicador,
      'idServicio': idServicio,
      'idTecnico': idTecnico,
      'valor': valor,
    };
  }

  @override
  String toString() {
    return 'IndicadorServicio{id: $id, idIndicador: $idIndicador, idServicio: $idServicio, idTecnico: $idTecnico, valor: $valor}';
  }
}
