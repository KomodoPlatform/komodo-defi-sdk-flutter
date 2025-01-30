class Pagination {
  Pagination({
    this.fromId,
    this.pageNumber,
  });
  final String? fromId;
  final int? pageNumber;

  Map<String, dynamic> toJson() => {
        if (fromId != null) 'FromId': fromId,
        if (pageNumber != null) 'PageNumber': pageNumber,
      };
}
