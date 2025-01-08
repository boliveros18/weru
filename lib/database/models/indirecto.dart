class Indirecto {
  final int id;
  final int idEstado;
  final String descripcion;
  final int costo;
  final int valor;

  Indirecto({
    required this.id,
    required this.idEstado,
    required this.descripcion,
    required this.costo,
    required this.valor,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idEstado': idEstado,
      'descripcion': descripcion,
      'costo': costo,
      'valor': valor,
    };
  }

  @override
  String toString() {
    return 'Indirecto{id: $id, idEstado: $idEstado, descripcion: $descripcion, costo: $costo, valor: $valor}';
  }
}
