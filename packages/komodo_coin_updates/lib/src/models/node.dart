import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

import 'package:komodo_coin_updates/komodo_coin_updates.dart';

part 'adapters/node_adapter.dart';

class Node extends Equatable {
  const Node({this.url, this.wsUrl, this.guiAuth, this.contact});

  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      url: json['url'] as String?,
      wsUrl: json['ws_url'] as String?,
      guiAuth: (json['gui_auth'] ?? json['komodo_proxy']) as bool?,
      contact:
          json['contact'] != null
              ? Contact.fromJson(json['contact'] as Map<String, dynamic>)
              : null,
    );
  }

  final String? url;
  final String? wsUrl;
  final bool? guiAuth;
  final Contact? contact;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'url': url,
      'ws_url': wsUrl,
      'gui_auth': guiAuth,
      'komodo_proxy': guiAuth,
      'contact': contact?.toJson(),
    };
  }

  @override
  List<Object?> get props => <Object?>[url, wsUrl, guiAuth, contact];
}
