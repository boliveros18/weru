class Equipo {
  final int id;
  final String serial;
  final String nombre;
  final String fechaCompra;
  final String fechaGarantia;
  final int idModelo;
  final int idEstadoEquipo;
  final int idProveedor;
  final int idCliente;

  Equipo({
    required this.id,
    required this.serial,
    required this.nombre,
    required this.fechaCompra,
    required this.fechaGarantia,
    required this.idModelo,
    required this.idEstadoEquipo,
    required this.idProveedor,
    required this.idCliente,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'serial': serial,
      'nombre': nombre,
      'fechaCompra': fechaCompra,
      'fechaGarantia': fechaGarantia,
      'idModelo': idModelo,
      'idEstadoEquipo': idEstadoEquipo,
      'idProveedor': idProveedor,
      'idCliente': idCliente,
    };
  }

  @override
  String toString() {
    return 'Equipo{id: $id, serial: $serial, nombre: $nombre, fechaCompra: $fechaCompra, fechaGarantia: $fechaGarantia, idModelo: $idModelo, idEstadoEquipo: $idEstadoEquipo, idProveedor: $idProveedor, idCliente: $idCliente}';
  }
}
