// import 'package:komodo_defi_rpc_methods/src/common_structures/nft/nft_metadata.dart';

// class NftInfo {
//   NftInfo({
//     required this.chain,
//     required this.tokenAddress,
//     required this.tokenId,
//     required this.amount,
//     required this.ownerOf,
//     required this.tokenHash,
//     required this.blockNumberMinted,
//     required this.blockNumber,
//     required this.contractType,
//     required this.lastTokenUriSync,
//     required this.lastMetadataSync,
//     required this.minterAddress,
//     required this.possibleSpam,
//     required this.possiblePhishing,
//     required this.uriMeta,
//     this.name,
//     this.symbol,
//     this.tokenUri,
//     this.tokenDomain,
//     this.metadata,
//   });

//   factory NftInfo.fromJson(Map<String, dynamic> json) => NftInfo(
//         chain: json['chain'],
//         tokenAddress: json['token_address'],
//         tokenId: json['token_id'],
//         amount: json['amount'],
//         ownerOf: json['owner_of'],
//         tokenHash: json['token_hash'],
//         blockNumberMinted: json['block_number_minted'],
//         blockNumber: json['block_number'],
//         contractType: json['contract_type'],
//         name: json['name'],
//         symbol: json['symbol'],
//         tokenUri: json['token_uri'],
//         tokenDomain: json['token_domain'],
//         metadata: json['metadata'],
//         lastTokenUriSync: json['last_token_uri_sync'],
//         lastMetadataSync: json['last_metadata_sync'],
//         minterAddress: json['minter_address'],
//         possibleSpam: json['possible_spam'],
//         possiblePhishing: json['possible_phishing'],
//         uriMeta: NftMetadata.fromJson(json['uri_meta']),
//       );

//   final String chain;
//   final String tokenAddress;
//   final String tokenId;
//   final String amount;
//   final String ownerOf;
//   final String tokenHash;
//   final int blockNumberMinted;
//   final int blockNumber;
//   final String contractType;
//   final String? name;
//   final String? symbol;
//   final String? tokenUri;
//   final String? tokenDomain;
//   final String? metadata;
//   final String lastTokenUriSync;
//   final String lastMetadataSync;
//   final String minterAddress;
//   final bool possibleSpam;
//   final bool possiblePhishing;
//   final NftMetadata uriMeta;

//   Map<String, dynamic> toJson() => {
//         'chain': chain,
//         'token_address': tokenAddress,
//         'token_id': tokenId,
//         'amount': amount,
//         'owner_of': ownerOf,
//         'token_hash': tokenHash,
//         'block_number_minted': blockNumberMinted,
//         'block_number': blockNumber,
//         'contract_type': contractType,
//         if (name != null) 'name': name,
//         if (symbol != null) 'symbol': symbol,
//         if (tokenUri != null) 'token_uri': tokenUri,
//         if (tokenDomain != null) 'token_domain': tokenDomain,
//         if (metadata != null) 'metadata': metadata,
//         'last_token_uri_sync': lastTokenUriSync,
//         'last_metadata_sync': lastMetadataSync,
//         'minter_address': minterAddress,
//         'possible_spam': possibleSpam,
//         'possible_phishing': possiblePhishing,
//         'uri_meta': uriMeta.toJson(),
//       };
// }

// class NftFilter {
//   NftFilter({
//     this.excludeSpam,
//     this.excludePhishing,
//   });
//   final bool? excludeSpam;
//   final bool? excludePhishing;

//   Map<String, dynamic> toJson() => {
//         if (excludeSpam != null) 'exclude_spam': excludeSpam,
//         if (excludePhishing != null) 'exclude_phishing': excludePhishing,
//       };
// }

// class NftTransferFilter {
//   NftTransferFilter({
//     this.status,
//     this.fromTimestamp,
//     this.toTimestamp,
//   });
//   final String? status;
//   final int? fromTimestamp;
//   final int? toTimestamp;

//   Map<String, dynamic> toJson() => {
//         if (status != null) 'status': status,
//         if (fromTimestamp != null) 'from_timestamp': fromTimestamp,
//         if (toTimestamp != null) 'to_timestamp': toTimestamp,
//       };
// }

// class WithdrawNftData {
//   WithdrawNftData({
//     required this.chain,
//     required this.to,
//     required this.tokenAddress,
//     required this.tokenId,
//     this.max,
//     this.amount,
//   });
//   final String chain;
//   final String to;
//   final String tokenAddress;
//   final String tokenId;
//   final bool? max;
//   final String? amount;

//   Map<String, dynamic> toJson() => {
//         'chain': chain,
//         'to': to,
//         'token_address': tokenAddress,
//         'token_id': tokenId,
//         if (max != null) 'max': max,
//         if (amount != null) 'amount': amount,
//       };
// }
