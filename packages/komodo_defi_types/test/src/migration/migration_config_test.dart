import 'package:test/test.dart';
import 'package:komodo_defi_types/src/migration/migration_config.dart';

void main() {
  group('MigrationConfig Tests', () {
    test('should create MigrationConfig with default values', () {
      // Arrange & Act
      const config = MigrationConfig();

      // Assert
      expect(config.activationBatchSize, MigrationConfig.defaultActivationBatchSize);
      expect(config.operationTimeout, MigrationConfig.defaultOperationTimeout);
      expect(config.retryAttempts, MigrationConfig.defaultRetryAttempts);
      expect(config.retryDelay, MigrationConfig.defaultRetryDelay);
      expect(config.previewCacheTimeout, MigrationConfig.defaultPreviewCacheTimeout);
      expect(config.maxConcurrentWithdrawals, MigrationConfig.defaultMaxConcurrentWithdrawals);
      expect(config.enableProgressUpdates, true);
      expect(config.enableDetailedLogging, true);
    });

    test('should create MigrationConfig with custom values', () {
      // Arrange & Act
      const config = MigrationConfig(
        activationBatchSize: 5,
        operationTimeout: Duration(minutes: 10),
        retryAttempts: 5,
        retryDelay: Duration(seconds: 5),
        previewCacheTimeout: Duration(hours: 1),
        maxConcurrentWithdrawals: 3,
        enableProgressUpdates: false,
        enableDetailedLogging: false,
      );

      // Assert
      expect(config.activationBatchSize, 5);
      expect(config.operationTimeout, Duration(minutes: 10));
      expect(config.retryAttempts, 5);
      expect(config.retryDelay, Duration(seconds: 5));
      expect(config.previewCacheTimeout, Duration(hours: 1));
      expect(config.maxConcurrentWithdrawals, 3);
      expect(config.enableProgressUpdates, false);
      expect(config.enableDetailedLogging, false);
    });

    test('should create copy with modified values', () {
      // Arrange
      const originalConfig = MigrationConfig(
        activationBatchSize: 10,
        retryAttempts: 3,
      );

      // Act
      final copiedConfig = originalConfig.copyWith(
        activationBatchSize: 20,
        enableProgressUpdates: false,
      );

      // Assert
      expect(copiedConfig.activationBatchSize, 20);
      expect(copiedConfig.retryAttempts, 3); // Unchanged
      expect(copiedConfig.enableProgressUpdates, false);
      expect(copiedConfig.enableDetailedLogging, true); // Default from original
    });

    test('should support equality comparison', () {
      // Arrange
      const config1 = MigrationConfig(
        activationBatchSize: 10,
        retryAttempts: 3,
      );

      const config2 = MigrationConfig(
        activationBatchSize: 10,
        retryAttempts: 3,
      );

      const config3 = MigrationConfig(
        activationBatchSize: 20,
        retryAttempts: 3,
      );

      // Act & Assert
      expect(config1, config2);
      expect(config1 == config3, false);
      expect(config1.hashCode, config2.hashCode);
      expect(config1.hashCode == config3.hashCode, false);
    });

    test('should have meaningful toString representation', () {
      // Arrange
      const config = MigrationConfig(
        activationBatchSize: 15,
        retryAttempts: 5,
      );

      // Act
      final stringRepresentation = config.toString();

      // Assert
      expect(stringRepresentation.contains('MigrationConfig'), true);
      expect(stringRepresentation.contains('activationBatchSize: 15'), true);
      expect(stringRepresentation.contains('retryAttempts: 5'), true);
    });

    test('should validate default constants are reasonable', () {
      // Assert
      expect(MigrationConfig.defaultActivationBatchSize > 0, true);
      expect(MigrationConfig.defaultActivationBatchSize <= 50, true);

      expect(MigrationConfig.defaultOperationTimeout.inMinutes >= 1, true);
      expect(MigrationConfig.defaultOperationTimeout.inMinutes <= 30, true);

      expect(MigrationConfig.defaultRetryAttempts >= 0, true);
      expect(MigrationConfig.defaultRetryAttempts <= 10, true);

      expect(MigrationConfig.defaultRetryDelay.inSeconds >= 1, true);
      expect(MigrationConfig.defaultRetryDelay.inSeconds <= 30, true);

      expect(MigrationConfig.defaultPreviewCacheTimeout.inMinutes >= 5, true);
      expect(MigrationConfig.defaultPreviewCacheTimeout.inHours <= 24, true);

      expect(MigrationConfig.defaultMaxConcurrentWithdrawals > 0, true);
      expect(MigrationConfig.defaultMaxConcurrentWithdrawals <= 20, true);
    });

    test('should serialize to and from JSON', () {
      // Arrange
      const originalConfig = MigrationConfig(
        activationBatchSize: 15,
        operationTimeout: Duration(minutes: 8),
        retryAttempts: 5,
        retryDelay: Duration(seconds: 3),
        previewCacheTimeout: Duration(hours: 2),
        maxConcurrentWithdrawals: 7,
        enableProgressUpdates: false,
        enableDetailedLogging: true,
      );

      // Act
      final json = originalConfig.toJson();
      final reconstructedConfig = MigrationConfig.fromJson(json);

      // Assert
      expect(reconstructedConfig, originalConfig);
      expect(reconstructedConfig.activationBatchSize, 15);
      expect(reconstructedConfig.operationTimeout, Duration(minutes: 8));
      expect(reconstructedConfig.retryAttempts, 5);
      expect(reconstructedConfig.retryDelay, Duration(seconds: 3));
      expect(reconstructedConfig.previewCacheTimeout, Duration(hours: 2));
      expect(reconstructedConfig.maxConcurrentWithdrawals, 7);
      expect(reconstructedConfig.enableProgressUpdates, false);
      expect(reconstructedConfig.enableDetailedLogging, true);
    });
  });

  group('MigrationConfigProvider Tests', () {
    test('DefaultMigrationConfigProvider should return default config', () async {
      // Arrange
      const provider = DefaultMigrationConfigProvider();

      // Act
      final config = await provider.getConfig();

      // Assert
      expect(config.runtimeType, MigrationConfig);
      expect(config, const MigrationConfig());
    });

    test('DefaultMigrationConfigProvider should return custom default config', () async {
      // Arrange
      const customConfig = MigrationConfig(
        activationBatchSize: 25,
        retryAttempts: 1,
      );
      const provider = DefaultMigrationConfigProvider(customConfig);

      // Act
      final config = await provider.getConfig();

      // Assert
      expect(config, customConfig);
      expect(config.activationBatchSize, 25);
      expect(config.retryAttempts, 1);
    });
  });
}
