class Servicio {
  final int id;
  final int idTecnico;
  final int idCliente;
  final int idEstadoServicio;
  final String nombre;
  final String descripcion;
  final String direccion;
  final int idCiudad;
  final double latitud;
  final double longitud;
  final String fechaInicio;
  final String fechayhorainicio;
  final String fechaModificacion;
  final String fechaFin;
  final int idEquipo;
  final int idFalla;
  final String observacionReporte;
  final String radicado;
  final int idTipoServicio;
  final String cedulaFirma;
  final String nombreFirma;
  final String archivoFirma;
  final int orden;
  final String fechaLlegada;
  final String comentarios;
  final int consecutivo;

  Servicio({
    required this.id,
    required this.idTecnico,
    required this.idCliente,
    required this.idEstadoServicio,
    required this.nombre,
    required this.descripcion,
    required this.direccion,
    required this.idCiudad,
    required this.latitud,
    required this.longitud,
    required this.fechaInicio,
    required this.fechayhorainicio,
    required this.fechaModificacion,
    required this.fechaFin,
    required this.idEquipo,
    required this.idFalla,
    required this.observacionReporte,
    required this.radicado,
    required this.idTipoServicio,
    required this.cedulaFirma,
    required this.nombreFirma,
    required this.archivoFirma,
    required this.orden,
    required this.fechaLlegada,
    required this.comentarios,
    required this.consecutivo,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idTecnico': idTecnico,
      'idCliente': idCliente,
      'idEstadoServicio': idEstadoServicio,
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'idCiudad': idCiudad,
      'latitud': latitud,
      'longitud': longitud,
      'fechaInicio': fechaInicio,
      'fechayhorainicio': fechayhorainicio,
      'fechaModificacion': fechaModificacion,
      'fechaFin': fechaFin,
      'idEquipo': idEquipo,
      'idFalla': idFalla,
      'observacionReporte': observacionReporte,
      'radicado': radicado,
      'idTipoServicio': idTipoServicio,
      'cedulaFirma': cedulaFirma,
      'nombreFirma': nombreFirma,
      'archivoFirma': archivoFirma,
      'orden': orden,
      'fechaLlegada': fechaLlegada,
      'comentarios': comentarios,
      'consecutivo': consecutivo,
    };
  }

  @override
  String toString() {
    return 'Servicio{id: $id, idTecnico: $idTecnico, idCliente: $idCliente, idEstadoServicio: $idEstadoServicio, nombre: $nombre, descripcion: $descripcion, direccion: $direccion, idCiudad: $idCiudad, latitud: $latitud, longitud: $longitud, fechaInicio: $fechaInicio, fechayhorainicio: $fechayhorainicio, fechaModificacion: $fechaModificacion, fechaFin: $fechaFin, idEquipo: $idEquipo, idFalla: $idFalla, observacionReporte: $observacionReporte, radicado: $radicado, idTipoServicio: $idTipoServicio, cedulaFirma: $cedulaFirma, nombreFirma: $nombreFirma, archivoFirma: $archivoFirma, orden: $orden, fechaLlegada: $fechaLlegada, comentarios: $comentarios, consecutivo: $consecutivo}';
  }
}
