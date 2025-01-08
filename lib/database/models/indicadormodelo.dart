class IndicadorModelo {
  final int id;
  final int idIndicador;
  final int idModelo;

  IndicadorModelo({
    required this.id,
    required this.idIndicador,
    required this.idModelo,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idIndicador': idIndicador,
      'idModelo': idModelo,
    };
  }

  @override
  String toString() {
    return 'IndicadorModelo{id: $id, idIndicador: $idIndicador, idModelo: $idModelo}';
  }
}
