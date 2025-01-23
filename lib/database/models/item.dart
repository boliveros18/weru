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

   factory   Item.fromMap(Map<String, dynamic> map) {
    return   Item(
           id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      SKU: map['SKU']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      tipo: int.tryParse(map['tipo']?.toString() ?? '') ?? 0,
      costo: int.tryParse(map['costo']?.toString() ?? '') ?? 0,
      precio: int.tryParse(map['precio']?.toString() ?? '') ?? 0,
      idEstadoItem: int.tryParse(map['idEstadoItem']?.toString() ?? '') ?? 0,
      foto: map['foto']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'Item{id: $id, SKU: $SKU, descripcion: $descripcion, tipo: $tipo, costo: $costo, precio: $precio, idEstadoItem: $idEstadoItem, foto: $foto}';
  }
}
