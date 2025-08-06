import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

part 'adapters/address_format_adapter.dart';

class AddressFormat extends Equatable {
  const AddressFormat({this.format, this.network});

  factory AddressFormat.fromJson(Map<String, dynamic> json) {
    return AddressFormat(
      format: json['format'] as String?,
      network: json['network'] as String?,
    );
  }

  final String? format;
  final String? network;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'format': format, 'network': network};
  }

  @override
  List<Object?> get props => <Object?>[format, network];
}
