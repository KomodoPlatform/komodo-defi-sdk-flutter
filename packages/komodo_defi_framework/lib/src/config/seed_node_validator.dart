import 'package:komodo_defi_framework/src/config/kdf_logging_config.dart';
import 'package:komodo_defi_framework/src/exceptions/kdf_exception.dart';

/// Helper class to validate seed node configurations
class SeedNodeValidator {
  /// Validates the seed node configuration
  ///
  /// Throws [KdfException] if the configuration is invalid
  static void validate({
    required List<String>? seedNodes,
    required bool? disableP2p,
    required bool? iAmSeed,
    required bool? isBootstrapNode,
  }) {
    // Cannot disable P2P while seed nodes are configured
    if (disableP2p == true && seedNodes != null && seedNodes.isNotEmpty) {
      throw KdfException(
        'Cannot disable P2P while seed nodes are configured.',
        type: KdfExceptionType.seedNodeConfigError,
      );
    }

    // If P2P is disabled, no need for further validation
    if (disableP2p == true) {
      if (KdfLoggingConfig.verboseLogging) {
        print('WARN P2P is disabled. Features that require a P2P network '
            '(like swaps, peer health checks, etc.) will not work.');
      }
      return;
    }

    // Seed nodes cannot disable P2P
    if (iAmSeed == true && disableP2p == true) {
      throw KdfException(
        'Seed nodes cannot disable P2P.',
        type: KdfExceptionType.seedNodeConfigError,
      );
    }

    // Bootstrap node must also be a seed node
    if (isBootstrapNode == true && iAmSeed != true) {
      throw KdfException(
        'Bootstrap node must also be a seed node.',
        type: KdfExceptionType.seedNodeConfigError,
      );
    }

    // Non-bootstrap node must have seed nodes configured
    if (isBootstrapNode != true &&
        iAmSeed != true &&
        (seedNodes == null || seedNodes.isEmpty)) {
      throw KdfException(
        'Non-bootstrap node must have seed nodes configured to connect.',
        type: KdfExceptionType.seedNodeConfigError,
      );
    }

    // Warning about future requirements - updated to be more explicit
    if (seedNodes == null || seedNodes.isEmpty) {
      if (KdfLoggingConfig.verboseLogging) {
        print('WARN From v2.5.0-beta, there will be no default seed nodes, '
            'and the seednodes parameter will be required unless disable_p2p is set to true.');
      }
    }
  }

  /// Gets the default seed nodes if none are provided
  ///
  /// Note: From v2.5.0-beta, there will be no default seed nodes,
  /// and the seednodes parameter will be required unless disable_p2p is set to true.
  static List<String> getDefaultSeedNodes() {
    return ['seed01.kmdefi.net', 'seed02.kmdefi.net'];
  }
}
