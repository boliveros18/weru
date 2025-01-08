class Maletin {
  final int id;
  final int idItem;
  final int idTecnico;
  final double cantidad;
  final double costo;
  final double valor;

  Maletin({
    required this.id,
    required this.idItem,
    required this.idTecnico,
    required this.cantidad,
    required this.costo,
    required this.valor,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idItem': idItem,
      'idTecnico': idTecnico,
      'cantidad': cantidad,
      'costo': costo,
      'valor': valor,
    };
  }

  @override
  String toString() {
    return 'Maletin{id: $id, idItem: $idItem, idTecnico: $idTecnico, cantidad: $cantidad, costo: $costo, valor: $valor}';
  }
}
