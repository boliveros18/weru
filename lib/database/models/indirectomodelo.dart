class IndirectoModelo {
  final int id;
  final int idIndirecto;
  final int idModelo;

  IndirectoModelo({
    required this.id,
    required this.idIndirecto,
    required this.idModelo,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'idIndirecto': idIndirecto,
      'idModelo': idModelo,
    };
  }

  @override
  String toString() {
    return 'IndirectoModelo{id: $id, idIndirecto: $idIndirecto, idModelo: $idModelo}';
  }
}
