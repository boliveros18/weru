class ActividadServicio {
  final int id;
  final int idActividad;
  final String idServicio;
  final int cantidad;
  final int costo;
  final int valor;
  final int ejecutada;

  ActividadServicio({
    required this.id,
    required this.idActividad,
    required this.idServicio,
    required this.cantidad,
    required this.costo,
    required this.valor,
    required this.ejecutada,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idActividad': idActividad,
      'idServicio': idServicio,
      'cantidad': cantidad,
      'costo': costo,
      'valor': valor,
      'ejecutada': ejecutada,
    };
  }

  @override
  String toString() {
    return 'ActividadServicio{id: $id, idActividad: $idActividad, idServicio: $idServicio, cantidad: $cantidad, costo: $costo, valor: $valor, ejecutada: $ejecutada}';
  }
}
