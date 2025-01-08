class RegistroCamposAdicionales {
  final int id;
  final int idCamposAdicionales;
  final int idRegistro;
  final int valor;
  final String nombre;

  RegistroCamposAdicionales({
    required this.id,
    required this.idCamposAdicionales,
    required this.idRegistro,
    required this.valor,
    required this.nombre,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idCamposAdicionales': idCamposAdicionales,
      'idRegistro': idRegistro,
      'valor': valor,
      'nombre': nombre,
    };
  }

  @override
  String toString() {
    return 'RegistroCamposAdicionales{id: $id, idCamposAdicionales: $idCamposAdicionales, idRegistro: $idRegistro, valor: $valor, nombre: $nombre}';
  }
}
