class Pagination {
  Pagination({
    this.fromId,
    this.pageNumber,
  });
  final int? fromId;
  final int? pageNumber;

  Map<String, dynamic> toJson() => {
        if (fromId != null) 'FromId': fromId,
        if (pageNumber != null) 'PageNumber': pageNumber,
      };
}
