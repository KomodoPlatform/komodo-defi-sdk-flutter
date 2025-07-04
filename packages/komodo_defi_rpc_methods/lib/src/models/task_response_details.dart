import 'dart:convert';

import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';

/// Generic response details wrapper for task status responses
class ResponseDetails<T, R extends GeneralErrorResponse, D extends Object> {
  ResponseDetails({required this.data, required this.error, this.description})
      : assert(
          [data, error, description].where((e) => e != null).length == 1,
          'Of the three fields, exactly one must be non-null',
        );

  final T? data;
  final R? error;

  // Usually only non-null for in-progress tasks
  /// Additional status information for in-progress tasks
  final D? description;

  void get throwIfError {
    if (error != null) {
      throw error!;
    }
  }

  T? get dataOrNull => data;

  Map<String, dynamic> toJson() {
    return {
      if (data != null) 'data': jsonEncode(data),
      if (error != null) 'error': jsonEncode(error),
      if (description != null)
        'description': description is String
            ? description
            : jsonEncode(description),
    };
  }
}
