class Credentials {
  final int id;
  final String name;
  final String value;

  Credentials({
    required this.id,
    required this.name,
    required this.value,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'value': value,
    };
  }

  @override
  String toString() {
    return 'Credentials{id: $id, name: $name, value: $value}';
  }
}
