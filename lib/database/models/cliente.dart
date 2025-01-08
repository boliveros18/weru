class Cliente {
  final int id;
  final String nombre;
  final String direccion;
  final int idCiudad;
  final String telefono;
  final String celular;
  final int idTipoCliente;
  final String idTipoDocumento;
  final String numDocumento;
  final String establecimiento;
  final String contacto;
  final int idEstado;
  final String correo;

  Cliente({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.idCiudad,
    required this.telefono,
    required this.celular,
    required this.idTipoCliente,
    required this.idTipoDocumento,
    required this.numDocumento,
    required this.establecimiento,
    required this.contacto,
    required this.idEstado,
    required this.correo,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'idCiudad': idCiudad,
      'telefono': telefono,
      'celular': celular,
      'idTipoCliente': idTipoCliente,
      'idTipoDocumento': idTipoDocumento,
      'numDocumento': numDocumento,
      'establecimiento': establecimiento,
      'contacto': contacto,
      'idEstado': idEstado,
      'correo': correo,
    };
  }

  @override
  String toString() {
    return 'Cliente{id: $id, nombre: $nombre, direccion: $direccion, idCiudad: $idCiudad, telefono: $telefono, celular: $celular, idTipoCliente: $idTipoCliente, idTipoDocumento: $idTipoDocumento, numDocumento: $numDocumento, establecimiento: $establecimiento, contacto: $contacto, idEstado: $idEstado, correo: $correo}';
  }
}
