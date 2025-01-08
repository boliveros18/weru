class ItemModelo {
  final int id;
  final int idItem;
  final int idModelo;

  ItemModelo({
    required this.id,
    required this.idItem,
    required this.idModelo,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idItem': idItem,
      'idModelo': idModelo,
    };
  }

  @override
  String toString() {
    return 'ItemModelo{id: $id, idItem: $idItem, idModelo: $idModelo}';
  }
}
