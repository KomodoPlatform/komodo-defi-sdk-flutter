// class NftTransfer {
//   NftTransfer({
//     required this.blockHash,
//     required this.transactionHash,
//     required this.transactionIndex,
//     required this.logIndex,
//     required this.value,
//     required this.transactionType,
//     required this.tokenAddress,
//     required this.fromAddress,
//     required this.toAddress,
//     required this.amount,
//     required this.verified,
//     required this.operator,
//     required this.possibleSpam,
//     required this.chain,
//     required this.tokenId,
//     required this.blockNumber,
//     required this.blockTimestamp,
//     required this.contractType,
//     required this.status,
//     required this.possiblePhishing,
//     required this.feeDetails,
//     required this.confirmations,
//     this.tokenUri,
//     this.tokenDomain,
//     this.collectionName,
//     this.imageUrl,
//     this.imageDomain,
//     this.tokenName,
//   });

//   factory NftTransfer.fromJson(Map<String, dynamic> json) => NftTransfer(
//         blockHash: json['block_hash'],
//         transactionHash: json['transaction_hash'],
//         transactionIndex: json['transaction_index'],
//         logIndex: json['log_index'],
//         value: json['value'],
//         transactionType: json['transaction_type'],
//         tokenAddress: json['token_address'],
//         fromAddress: json['from_address'],
//         toAddress: json['to_address'],
//         amount: json['amount'],
//         verified: json['verified'],
//         operator: json['operator'],
//         possibleSpam: json['possible_spam'],
//         chain: json['chain'],
//         tokenId: json['token_id'],
//         blockNumber: json['block_number'],
//         blockTimestamp: json['block_timestamp'],
//         contractType: json['contract_type'],
//         tokenUri: json['token_uri'],
//         tokenDomain: json['token_domain'],
//         collectionName: json['collection_name'],
//         imageUrl: json['image_url'],
//         imageDomain: json['image_domain'],
//         tokenName: json['token_name'],
//         status: json['status'],
//         possiblePhishing: json['possible_phishing'],
//         feeDetails: WithdrawFee.fromJson(json['fee_details']),
//         confirmations: json['confirmations'],
//       );
//   final String blockHash;
//   final String transactionHash;
//   final int transactionIndex;
//   final int logIndex;
//   final String value;
//   final String transactionType;
//   final String tokenAddress;
//   final String fromAddress;
//   final String toAddress;
//   final String amount;
//   final int verified;
//   final String operator;
//   final bool possibleSpam;
//   final String chain;
//   final String tokenId;
//   final int blockNumber;
//   final int blockTimestamp;
//   final String contractType;
//   final String? tokenUri;
//   final String? tokenDomain;
//   final String? collectionName;
//   final String? imageUrl;
//   final String? imageDomain;
//   final String? tokenName;
//   final String status;
//   final bool possiblePhishing;
//   final WithdrawFee feeDetails;
//   final int confirmations;

//   Map<String, dynamic> toJson() => {
//         'block_hash': blockHash,
//         'transaction_hash': transactionHash,
//         'transaction_index': transactionIndex,
//         'log_index': logIndex,
//         'value': value,
//         'transaction_type': transactionType,
//         'token_address': tokenAddress,
//         'from_address': fromAddress,
//         'to_address': toAddress,
//         'amount': amount,
//         'verified': verified,
//         'operator': operator,
//         'possible_spam': possibleSpam,
//         'chain': chain,
//         'token_id': tokenId,
//         'block_number': blockNumber,
//         'block_timestamp': blockTimestamp,
//         'contract_type': contractType,
//         if (tokenUri != null) 'token_uri': tokenUri,
//         if (tokenDomain != null) 'token_domain': tokenDomain,
//         if (collectionName != null) 'collection_name': collectionName,
//         if (imageUrl != null) 'image_url': imageUrl,
//         if (imageDomain != null) 'image_domain': imageDomain,
//         if (tokenName != null) 'token_name': tokenName,
//         'status': status,
//         'possible_phishing': possiblePhishing,
//         'fee_details': feeDetails.toJson(),
//         'confirmations': confirmations,
//       };
// }
