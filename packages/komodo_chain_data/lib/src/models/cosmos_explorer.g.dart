// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cosmos_explorer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CosmosExplorer _$CosmosExplorerFromJson(Map<String, dynamic> json) =>
    _CosmosExplorer(
      kind: json['kind'] as String?,
      url: json['url'] as String,
      txPage: json['tx_page'] as String?,
      accountPage: json['account_page'] as String?,
      validatorPage: json['validator_page'] as String?,
      proposalPage: json['proposal_page'] as String?,
      blockPage: json['block_page'] as String?,
    );

Map<String, dynamic> _$CosmosExplorerToJson(_CosmosExplorer instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'url': instance.url,
      'tx_page': instance.txPage,
      'account_page': instance.accountPage,
      'validator_page': instance.validatorPage,
      'proposal_page': instance.proposalPage,
      'block_page': instance.blockPage,
    };
