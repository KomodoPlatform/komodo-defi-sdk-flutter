// Extension for firstWhereOrNull on Iterable
extension IterableTypeUtils<T> on Iterable<T> {
  /// Returns the first element that satisfies the given predicate [test] or
  /// `null` if there are none.
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
