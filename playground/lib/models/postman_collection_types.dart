// Custom collection models to replace postman_collection dependency
class CollectionInfo {
  final String name;

  CollectionInfo({required this.name});

  factory CollectionInfo.fromJson(Map<String, dynamic> json) {
    return CollectionInfo(name: json['name'] ?? 'Unnamed Collection');
  }
}

class RequestBody {
  final String? raw;

  RequestBody({this.raw});

  factory RequestBody.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RequestBody();
    return RequestBody(raw: json['raw']);
  }
}

class RequestData {
  final RequestBody? body;

  RequestData({this.body});

  factory RequestData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RequestData();
    return RequestData(body: RequestBody.fromJson(json['body']));
  }
}

class CollectionItem {
  final String name;
  final RequestData? request;
  final List<CollectionItem>? item;

  CollectionItem({required this.name, this.request, this.item});

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      name: json['name'] ?? 'Unnamed Item',
      request:
          json['request'] != null
              ? RequestData.fromJson(json['request'])
              : null,
      item:
          json['item'] != null
              ? (json['item'] as List)
                  .map((i) => CollectionItem.fromJson(i))
                  .toList()
              : null,
    );
  }
}

class Collection {
  final CollectionInfo info;
  final List<CollectionItem> item;

  Collection({required this.info, required this.item});

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      info: CollectionInfo.fromJson(json['info'] ?? {}),
      item:
          (json['item'] as List? ?? [])
              .map((i) => CollectionItem.fromJson(i))
              .toList(),
    );
  }
}
