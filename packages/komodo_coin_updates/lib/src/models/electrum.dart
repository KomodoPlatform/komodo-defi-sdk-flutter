import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'contact.dart';

part 'adapters/electrum_adapter.dart';

// ignore: must_be_immutable
class Electrum extends Equatable {
  Electrum({
    this.url,
    this.wsUrl,
    this.protocol,
    this.contact,
  });

  factory Electrum.fromJson(Map<String, dynamic> json) {
    return Electrum(
      url: json['url'] as String?,
      wsUrl: json['ws_url'] as String?,
      protocol: json['protocol'] as String?,
      contact: (json['contact'] as List<dynamic>?)
          ?.map((dynamic e) => Contact.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String? url;
  String? wsUrl;
  final String? protocol;
  final List<Contact>? contact;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'url': url,
      'ws_url': wsUrl,
      'protocol': protocol,
      'contact': contact?.map((Contact e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => <Object?>[url, wsUrl, protocol, contact];
}
