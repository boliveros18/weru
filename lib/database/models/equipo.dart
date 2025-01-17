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

  factory Equipo.fromMap(Map<String, dynamic> map) {
    return Equipo(
      id: map['id'] as int,
      serial: map['serial'] as String,
      nombre: map['nombre'] as String,
      fechaCompra: map['fechaCompra'] as String,
      fechaGarantia: map['fechaGarantia'] as String,
      idModelo: map['idModelo'] as int,
      idEstadoEquipo: map['idEstadoEquipo'] as int,
      idProveedor: map['idProveedor'] as int,
      idCliente: map['idCliente'] as int,
    );
  }

  @override
  String toString() {
    return 'Equipo{id: $id, serial: $serial, nombre: $nombre, fechaCompra: $fechaCompra, fechaGarantia: $fechaGarantia, idModelo: $idModelo, idEstadoEquipo: $idEstadoEquipo, idProveedor: $idProveedor, idCliente: $idCliente}';
  }
}
