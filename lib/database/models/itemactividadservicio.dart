class ItemActividadServicio {
  final int id;
  final int idItem;
  final int idActividadServicio;
  final double cantidadReq;

  ItemActividadServicio({
    required this.id,
    required this.idItem,
    required this.idActividadServicio,
    required this.cantidadReq,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idItem': idItem,
      'idActividadServicio': idActividadServicio,
      'cantidadReq': cantidadReq,
    };
  }

  @override
  String toString() {
    return 'ItemActividadServicio{id: $id, idItem: $idItem, idActividadServicio: $idActividadServicio, cantidadReq: $cantidadReq}';
  }
}
