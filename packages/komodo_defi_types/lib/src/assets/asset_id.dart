class AssetId {
  const AssetId({
    required this.id,
    required this.name,
    required this.symbol,
    required this.chainId,
  });

  final String id;
  final String name;
  final String symbol;

  // TODO! Replace with `Chain` type
  final String chainId;
}
