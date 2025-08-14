import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_coin_updates/src/models/contact.dart';

part 'node.freezed.dart';
part 'node.g.dart';

@freezed
abstract class Node with _$Node {
  const factory Node({
    String? url,
    String? wsUrl,
    bool? guiAuth,
    Contact? contact,
  }) = _Node;

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);
}
