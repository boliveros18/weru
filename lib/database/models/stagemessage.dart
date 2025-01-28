class StageMessage {
  final int? id;
  final String Message;
  final String MessageFamily;

  StageMessage({
    this.id,
    required this.Message,
    required this.MessageFamily,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'Message': Message,
      'MessageFamily': MessageFamily,
    };
  }

  factory StageMessage.fromMap(Map<String, dynamic> map) {
    return StageMessage(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      Message: map['Message']?.toString() ?? '',
      MessageFamily: map['MessageFamily']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'StageMessage{id: $id, Message: $Message, MessageFamily: $MessageFamily}';
  }
}
