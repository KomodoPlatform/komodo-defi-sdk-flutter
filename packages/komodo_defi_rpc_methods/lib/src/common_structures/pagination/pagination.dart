class Pagination {
  Pagination({this.fromId, this.pageNumber});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    final dynamic rawFromId =
        json['FromId'] ?? json['from_id'] ?? json['fromId'];
    final dynamic rawPageNumber =
        json['PageNumber'] ?? json['page_number'] ?? json['pageNumber'];

    return Pagination(
      fromId: rawFromId?.toString(),
      pageNumber: rawPageNumber is num ? rawPageNumber.toInt() : null,
    );
  }

  final String? fromId;
  final int? pageNumber;

  Map<String, dynamic> toJson() => {
    if (fromId != null) 'FromId': fromId,
    if (pageNumber != null) 'PageNumber': pageNumber,
  };
}
