enum SyncStatus {
  notStarted,
  inProgress,
  success,
  error;

  bool get isComplete => this == success || this == error;
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
