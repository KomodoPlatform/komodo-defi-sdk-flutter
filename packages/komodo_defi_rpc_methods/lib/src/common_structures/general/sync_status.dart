import 'package:komodo_defi_types/komodo_defi_types.dart';

class SyncStatusResponse {
  SyncStatusResponse({
    required this.state,
    this.additional,
  });

  factory SyncStatusResponse.fromJson(Map<String, dynamic> json) {
    return SyncStatusResponse(
      state: json.value<String>('state'),
      additional: json.value<JsonMap>('additional'),
    );
  }
  final String state;
  final Map<String, dynamic>? additional;

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      if (additional != null) 'additional': additional,
    };
  }
}
