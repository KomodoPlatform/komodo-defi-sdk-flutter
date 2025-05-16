/// Example usage:
///
/// class ExampleBuildStep extends BuildStep {
///   @override
///   Future<void> build() async {
///     final File tempFile = File('${tempWorkingDir.path}/temp.txt');
///     tempFile.createSync(recursive: true);
///
///     /// Create a demo empty text file in the assets directory.
///     final File newAssetFile = File('${assetsDir.path}/empty.txt');
///     newAssetFile.createSync(recursive: true);
///   }
///
///   @override
///   bool canSkip() {
///     return false;
///   }
///
///   @override
///   Future<void> revert() async {
///     await Future<void>.delayed(Duration.zero);
///   }
/// }
abstract class BuildStep {
  /// A unique identifier for this build step.
  String get id;

  /// Execute the build step. This should return a future that completes when
  /// the build step is done.
  Future<void> build();

  /// Whether this build step can be skipped if the output artifact already
  /// exists. E.g. We don't want to re-download a file if we already have the
  /// correct version.
  Future<bool> canSkip();

  /// Revert the environment to the state it was in before the build step was
  /// executed. This will be called internally by the build system if a build
  /// step fails.
  Future<void> revert([Exception? e]);
}
