class Tecnico {
  final int id;
  final String cedula;
  final String nombre;
  final int idProveedor;
  final int idEstadoTecnico;
  final String usuario;
  final String clave;
  final String telefono;
  final String celular;
  final double latitud;
  final double longitud;
  final String androidID;
  final String fechaPulso;
  final String versionApp;

  Tecnico({
    required this.id,
    required this.cedula,
    required this.nombre,
    required this.idProveedor,
    required this.idEstadoTecnico,
    required this.usuario,
    required this.clave,
    required this.telefono,
    required this.celular,
    required this.latitud,
    required this.longitud,
    required this.androidID,
    required this.fechaPulso,
    required this.versionApp,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'cedula': cedula,
      'nombre': nombre,
      'idProveedor': idProveedor,
      'idEstadoTecnico': idEstadoTecnico,
      'usuario': usuario,
      'clave': clave,
      'telefono': telefono,
      'celular': celular,
      'latitud': latitud,
      'longitud': longitud,
      'androidID': androidID,
      'fechaPulso': fechaPulso,
      'versionApp': versionApp,
    };
  }

  @override
  String toString() {
    return 'Tecnico{id: $id, cedula: $cedula, nombre: $nombre, idProveedor: $idProveedor, idEstadoTecnico: $idEstadoTecnico, usuario: $usuario, clave: $clave, telefono: $telefono, celular: $celular, latitud: $latitud, longitud: $longitud, androidID: $androidID, fechaPulso: $fechaPulso, versionApp: $versionApp}';
  }
}
