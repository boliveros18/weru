class StageMessage {
  final int? id;
  final String Message;
  final String MessageFamily;
  final String Action;

  StageMessage({
    this.id,
    required this.Message,
    required this.MessageFamily,
    required this.Action,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'Message': Message,
      'MessageFamily': MessageFamily,
      'Action': Action
    };
  }

  factory StageMessage.fromMap(Map<String, dynamic> map) {
    return StageMessage(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      Message: map['Message']?.toString() ?? '',
      MessageFamily: map['MessageFamily']?.toString() ?? '',
      Action: map['Action']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'StageMessage{id: $id, Message: $Message, MessageFamily: $MessageFamily, Action: $Action}';
  }
}
