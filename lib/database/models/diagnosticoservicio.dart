class DiagnosticoServicio {
  final int id;
  final int idServicio;
  final int idDiagnostico;

  DiagnosticoServicio({
    required this.id,
    required this.idServicio,
    required this.idDiagnostico,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idServicio': idServicio,
      'idDiagnostico': idDiagnostico,
    };
  }

  @override
  String toString() {
    return 'DiagnosticoServicio{id: $id, idServicio: $idServicio, idDiagnostico: $idDiagnostico}';
  }
}
