import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

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
    final sanitizedValue = value
        .replaceAll('SyncStatusEnum.', '')
        .toLowerCase();

    // Map 'ok' to 'success' for backward compatibility with KDF API
    if (sanitizedValue == 'ok') {
      return SyncStatusEnum.success;
    }

    return SyncStatusEnum.values.firstWhereOrNull(
      (e) => e.name.toLowerCase() == sanitizedValue,
    );
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
