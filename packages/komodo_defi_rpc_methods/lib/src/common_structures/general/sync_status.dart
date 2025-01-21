import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class SyncStatusResponse {
  SyncStatusResponse({
    required this.state,
    this.additional,
  }) : assert(
          (state != TransactionSyncStatusEnum.inProgress &&
                  state != TransactionSyncStatusEnum.error) ||
              additional != null,
          'additional must be present for InProgress and Error states',
        );

  factory SyncStatusResponse.fromJson(Map<String, dynamic> json) {
    return SyncStatusResponse(
      state: TransactionSyncStatusEnum.parse(json.value<String>('state')),
      additional: json.containsKey('additional_info')
          ? SyncStatusExtended.fromJson(json.value<JsonMap>('additional_info'))
          : null,
    );
  }
  final TransactionSyncStatusEnum state;
  final SyncStatusExtended? additional;

  Map<String, dynamic> toJson() {
    return {
      'state': state.value,
      if (additional != null) 'additional_info': additional!.toJson(),
    };
  }
}
