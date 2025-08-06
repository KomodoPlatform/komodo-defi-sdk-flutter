import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

part 'adapters/rpc_url_adapter.dart';

class RpcUrl extends Equatable {
  const RpcUrl({this.url});

  factory RpcUrl.fromJson(Map<String, dynamic> json) {
    return RpcUrl(url: json['url'] as String?);
  }

  final String? url;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'url': url};
  }

  @override
  List<Object?> get props => <Object?>[url];
}
