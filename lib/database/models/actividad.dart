class Actividad {
  final int id;
  final String codigoExt;
  final String descripcion;
  final int costo;
  final int valor;
  final int idEstadoActividad;

  Actividad({
    required this.id,
    required this.codigoExt,
    required this.descripcion,
    required this.costo,
    required this.valor,
    required this.idEstadoActividad,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'codigoExt': codigoExt,
      'descripcion': descripcion,
      'costo': costo,
      'valor': valor,
      'idEstadoActividad': idEstadoActividad,
    };
  }

  @override
  String toString() {
    return 'Actividad{id: $id, codigoExt: $codigoExt, descripcion: $descripcion, costo: $costo, valor: $valor, idEstadoActividad: $idEstadoActividad}';
  }
}
