// Removed: Previously contained performance and stress tests using migration manager.
// Reason: komodo_defi_sdk is a pure Dart SDK (non-Flutter widget package). Performance
// tests here pulled in Flutter-style patterns indirectly (and are out of scope for
// lightweight smoke/unit coverage). If future non-UI performance benchmarks are needed,
// create a pure Dart benchmark suite (e.g. under /benchmark or using package:benchmark_harness)
// without any flutter_test dependency.
//
// (File intentionally left blank to avoid reintroducing flutter_test imports.)

void main() {
  // No-op: placeholder main to satisfy test runner.
}
