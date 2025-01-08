class StageMessage {
  final int id;
  final String Message;
  final String MessageFamily;
  final String Address;
  final String Action;
  final int RetryCount;
  final DateTime Created;
  final DateTime Updated;
  final int Proccesed;
  final String ErrorDescription;
  final int Error;
  final String BusinessId;

  StageMessage({
    required this.id,
    required this.Message,
    required this.MessageFamily,
    required this.Address,
    required this.Action,
    required this.RetryCount,
    required this.Created,
    required this.Updated,
    required this.Proccesed,
    required this.ErrorDescription,
    required this.Error,
    required this.BusinessId,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'Message': Message,
      'MessageFamily': MessageFamily,
      'Address': Address,
      'Action': Action,
      'RetryCount': RetryCount,
      'Created': Created,
      'Updated': Updated,
      'Proccesed': Proccesed,
      'ErrorDescription': ErrorDescription,
      'Error': Error,
      'BusinessId': BusinessId,
    };
  }

  @override
  String toString() {
    return 'StageMessage{id: $id, Message: $Message, MessageFamily: $MessageFamily, Address: $Address, Action: $Action, RetryCount: $RetryCount, Created: $Created, Updated: $Updated, Proccesed: $Proccesed, ErrorDescription: $ErrorDescription, Error: $Error, BusinessId: $BusinessId}';
  }
}
