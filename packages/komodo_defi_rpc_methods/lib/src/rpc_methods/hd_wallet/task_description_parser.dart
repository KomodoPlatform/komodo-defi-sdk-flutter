import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Task Description Parser Strategy Pattern
abstract class TaskDescriptionParser {
  bool canParse(JsonMap json);
  Object parse(JsonMap json);
}

class ConfirmAddressDescriptionParser implements TaskDescriptionParser {
  @override
  bool canParse(JsonMap json) => json.containsKey('ConfirmAddress');

  @override
  Object parse(JsonMap json) =>
      ConfirmAddressDetails.fromJson(json.value<JsonMap>('ConfirmAddress'));
}

class TaskDescriptionParserFactory {
  static final List<TaskDescriptionParser> _parsers = [
    ConfirmAddressDescriptionParser(),
  ];

  static Object? parseDescription(Object? detailsJson) {
    if (detailsJson is String) {
      return detailsJson;
    } else if (detailsJson is JsonMap) {
      for (final parser in _parsers) {
        if (parser.canParse(detailsJson)) {
          return parser.parse(detailsJson);
        }
      }

      // Fallback to raw JsonMap
      return detailsJson;
    }
    return null;
  }
}
