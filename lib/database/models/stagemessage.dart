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

   factory   StageMessage.fromMap(Map<String, dynamic> map) {
    return   StageMessage(
           id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      Message: map['Message']?.toString() ?? '',
      MessageFamily: map['MessageFamily']?.toString() ?? '',
      Address: map['Address']?.toString() ?? '',
      Action: map['Action']?.toString() ?? '',
      RetryCount: int.tryParse(map['RetryCount']?.toString() ?? '') ?? 0,
      Created: DateTime.tryParse(map['Created']?.toString() ?? '') ?? DateTime(0),
      Updated: DateTime.tryParse(map['Updated']?.toString() ?? '') ?? DateTime(0),
      Proccesed: int.tryParse(map['Proccesed']?.toString() ?? '') ?? 0,
      ErrorDescription: map['ErrorDescription']?.toString() ?? '',
      Error: int.tryParse(map['Error']?.toString() ?? '') ?? 0,
      BusinessId: map['BusinessId']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'StageMessage{id: $id, Message: $Message, MessageFamily: $MessageFamily, Address: $Address, Action: $Action, RetryCount: $RetryCount, Created: $Created, Updated: $Updated, Proccesed: $Proccesed, ErrorDescription: $ErrorDescription, Error: $Error, BusinessId: $BusinessId}';
  }
}
