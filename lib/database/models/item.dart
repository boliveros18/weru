class Item {
  final int id;
  final String SKU;
  final String descripcion;
  final int tipo;
  final int costo;
  final int precio;
  final int idEstadoItem;
  final String foto;

  Item({
    required this.id,
    required this.SKU,
    required this.descripcion,
    required this.tipo,
    required this.costo,
    required this.precio,
    required this.idEstadoItem,
    required this.foto,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'SKU': SKU,
      'descripcion': descripcion,
      'tipo': tipo,
      'costo': costo,
      'precio': precio,
      'idEstadoItem': idEstadoItem,
      'foto': foto,
    };
  }

  @override
  String toString() {
    return 'Item{id: $id, SKU: $SKU, descripcion: $descripcion, tipo: $tipo, costo: $costo, precio: $precio, idEstadoItem: $idEstadoItem, foto: $foto}';
  }
}
