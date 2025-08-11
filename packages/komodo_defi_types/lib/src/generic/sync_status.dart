enum SyncStatusEnum {
  notStarted,
  inProgress,
  success,
  error;

  bool get isTerminal => this == success || this == error;

  static SyncStatusEnum? tryParse(String? value) {
    if (value == null) {
      return null;
    }

    switch (value) {
      case 'NotStarted':
        return SyncStatusEnum.notStarted;
      case 'InProgress':
        return SyncStatusEnum.inProgress;
      case 'Success':
      case 'Ok':
        return SyncStatusEnum.success;
      case 'Error':
        return SyncStatusEnum.error;
      default:
        throw ArgumentError.value(value, 'value', 'Invalid sync status');
    }
  }
}

/*
0 =
"mmrpc" -> "2.0"
1 =
"result" -> Map (2 items)
key =
"result"
value =
Map (2 items)
0 =
"status" -> "InProgress"
1 =
"details" -> "RequestingAccountBalance"
*/
