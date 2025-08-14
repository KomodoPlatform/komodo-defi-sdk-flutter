import 'package:freezed_annotation/freezed_annotation.dart';

part 'rpc_url.freezed.dart';
part 'rpc_url.g.dart';

@freezed
abstract class RpcUrl with _$RpcUrl {
  const factory RpcUrl({String? url}) = _RpcUrl;

  factory RpcUrl.fromJson(Map<String, dynamic> json) => _$RpcUrlFromJson(json);
}
