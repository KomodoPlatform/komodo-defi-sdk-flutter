/// Filter for my_recent_swaps in KDF v2.
///
/// All fields are optional and will be omitted from the payload when null.
class RecentSwapsFilter {
  RecentSwapsFilter({
    this.limit,
    this.pageNumber,
    this.fromUuid,
    this.myCoin,
    this.otherCoin,
    this.fromTimestamp,
    this.toTimestamp,
  });

  final int? limit;
  final int? pageNumber;
  final String? fromUuid;
  final String? myCoin;
  final String? otherCoin;
  final int? fromTimestamp;
  final int? toTimestamp;

  Map<String, dynamic> toJson() {
    return {
      if (limit != null) 'limit': limit,
      if (pageNumber != null) 'page_number': pageNumber,
      if (fromUuid != null) 'from_uuid': fromUuid,
      if (myCoin != null) 'my_coin': myCoin,
      if (otherCoin != null) 'other_coin': otherCoin,
      if (fromTimestamp != null) 'from_timestamp': fromTimestamp,
      if (toTimestamp != null) 'to_timestamp': toTimestamp,
    };
  }
}
