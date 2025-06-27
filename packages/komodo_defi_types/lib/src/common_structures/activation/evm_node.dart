import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class EvmNode {
  EvmNode({required this.url, this.guiAuth = false});

  factory EvmNode.fromJson(JsonMap json) {
    return EvmNode(
      url: json.value<String>('url'),
      guiAuth: json.valueOrNull<bool>('gui_auth') ?? false,
    );
  }

  final String url;
  final bool guiAuth;

  Map<String, dynamic> toJson() => {'url': url, 'gui_auth': guiAuth};
}
