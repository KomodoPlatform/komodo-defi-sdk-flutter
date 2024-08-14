
1. Activation Structures:
   - [x] ActivationParams
   - [x] ActivationMode
   - [x] ActivationRpcData
   - [x] ActivationServers
   - [x] CoinProtocol
   - [x] CoinProtocolData
   - [x] EvmNode
   - [x] TokensRequest
   - [x] UtxoMergeParams

2. General Common Structures:
   - [x] WalletInfo
   - [x] NewAddressInfo
   - [x] BalanceInfo
   - [x] ScanAddressesInfo
   - [x] WithdrawFee
   - [x] SyncStatus

3. Lightning Network Common Structures:
   - [x] LightningChannelAmount
   - [x] LightningChannelOptions
   - [x] LightningChannelConfig
   - [x] CounterpartyChannelConfig
   - [x] LightningPayment
   - [x] LightningActivationParams
   - [x] ConfirmationTargets
   - [x] LightningOpenChannelsFilter
   - [x] LightningClosedChannelsFilter
   - [x] LightningPaymentFilter

4. NFT Common Structures:
   - [x] NftInfo
   - [x] NftMetadata
   - [x] NftTransfer
   - [x] NftFilter
   - [x] NftTransferFilter
   - [x] WithdrawNftData

We have now implemented all the common structures mentioned in the documentation. Each class includes methods for serialization (toJson) and, where appropriate, deserialization (fromJson).

Is there anything else you'd like me to add, modify, or explain regarding these implementations?