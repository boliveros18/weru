class ItemServicio {
  final int id;
  final int idItem;
  final int idServicio;
  final double cantidad;
  final int costo;
  final int valor;
  final double cantidadReq;
  final String fechaUltimaVez;
  final String vidaUtil;

  ItemServicio({
    required this.id,
    required this.idItem,
    required this.idServicio,
    required this.cantidad,
    required this.costo,
    required this.valor,
    required this.cantidadReq,
    required this.fechaUltimaVez,
    required this.vidaUtil,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idItem': idItem,
      'idServicio': idServicio,
      'cantidad': cantidad,
      'costo': costo,
      'valor': valor,
      'cantidadReq': cantidadReq,
      'fechaUltimaVez': fechaUltimaVez,
      'vidaUtil': vidaUtil,
    };
  }

  @override
  String toString() {
    return 'ItemServicio{id: $id, idItem: $idItem, idServicio: $idServicio, cantidad: $cantidad, costo: $costo, valor: $valor, cantidadReq: $cantidadReq, fechaUltimaVez: $fechaUltimaVez, vidaUtil: $vidaUtil}';
  }
}
