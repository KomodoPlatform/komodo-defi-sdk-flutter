// Migration flow widget/integration tests have been removed.
//
// Rationale:
// - This package is a pure Dart SDK (non-Flutter).
// - Previous contents depended on flutter_test via testWidgets.
// - We now restrict tests to pure Dart (package:test) only.
//
// Migration logic coverage:
//   * See test/migrations/integration_test.dart for high-level flow tests.
//
// If future end-to-end or performance scenarios are needed, add pure Dart
// benchmark / integration suites that do not import flutter_test.
//
// This stub now includes an empty `main()` so test discovery succeeds
// without reporting a missing `main` error. Keep this file (or delete it)
// once all references to the legacy migration flow are gone.
void main() {
  // intentionally no-op
}
