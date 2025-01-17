class IndirectoServicio {
  final int id;
  final int idIndirecto;
  final int idServicio;
  final int cantidad;
  final int costo;
  final int valor;

  IndirectoServicio({
    required this.id,
    required this.idIndirecto,
    required this.idServicio,
    required this.cantidad,
    required this.costo,
    required this.valor,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idIndirecto': idIndirecto,
      'idServicio': idServicio,
      'cantidad': cantidad,
      'costo': costo,
      'valor': valor,
    };
  }

  @override
  String toString() {
    return 'IndirectoServicio{id: $id, idIndirecto: $idIndirecto, idServicio: $idServicio, cantidad: $cantidad, costo: $costo, valor: $valor}';
  }
}
