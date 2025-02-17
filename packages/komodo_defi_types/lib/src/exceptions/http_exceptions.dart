class HttpException implements Exception {
  HttpException(this.message, {this.uri});
  final String message;
  final Uri? uri;

  @override
  String toString() => 'HttpException: $message${uri != null ? ' ($uri)' : ''}';
}
