class Titulos {
  final int id;
  final int idCampo;
  final String campo;
  final String valor;

  Titulos({
    required this.id,
    required this.idCampo,
    required this.campo,
    required this.valor,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idCampo': idCampo,
      'campo': campo,
      'valor': valor,
    };
  }

  @override
  String toString() {
    return 'Titulos{id: $id, idCampo: $idCampo, campo: $campo, valor: $valor}';
  }
}
