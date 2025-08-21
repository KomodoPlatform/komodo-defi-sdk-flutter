# Test Organization

This package follows Flutter's recommended testing structure with clear separation between unit tests and integration tests.

## Test Structure

### Unit Tests (`test/` directory)
Unit tests focus on testing individual components in isolation using mocks and fakes. They are fast, reliable, and don't require external dependencies.

#### Core Unit Tests
- **`coin_config_repository_unit_test.dart`** - Repository business logic with mocked dependencies
- **`coin_config_storage_contract_test.dart`** - Storage interface contract validation
- **`coin_config_data_factory_test.dart`** - Factory pattern implementation
- **`coin_config_provider_test.dart`** - GitHub provider logic with mocked HTTP client
- **`local_asset_coin_config_provider_test.dart`** - Local asset provider with mocked bundle
- **`runtime_update_config_model_test.dart`** - Configuration model validation
- **`runtime_update_config_repository_test.dart`** - Configuration loading with mocked bundle
- **`seed_node_updater_test.dart`** - Utility function testing
- **`config_transform_test.dart** - Configuration transformation logic
- **`coin_config_repository_bootstrap_test.dart** - Bootstrap sequence testing
- **`asset_filter_repository_test.dart`** - Asset filtering logic

#### Hive Unit Tests (`test/hive/` directory)
- **`hive_registrar_test.dart`** - Adapter registration testing
- **`asset_adapter_delete_many_test.dart`** - Bulk deletion operations
- **`asset_adapter_put_many_test.dart`** - Concurrent bulk insertion
- **`asset_adapter_roundtrip_test.dart`** - Serialization/deserialization

### Integration Tests (`integration_test/` directory)
Integration tests verify that components work together correctly with real dependencies. They may require external services, databases, or network access.

- **`coin_config_repository_integration_test.dart`** - Repository with Hive database integration
- **`coin_config_provider_integration_test.dart`** - Providers with HTTP and asset bundle integration

## Test Categories

### Unit Tests
- **Fast execution** (< 1 second per test)
- **No external dependencies** (mocks/fakes only)
- **Isolated testing** (one component at a time)
- **Deterministic results** (same outcome every run)

### Integration Tests
- **Slower execution** (may take several seconds)
- **Real dependencies** (databases, HTTP clients, file systems)
- **Component interaction** (multiple components working together)
- **Environment dependent** (may behave differently in CI vs local)

## Running Tests

### Unit Tests Only
```bash
flutter test test/
```

### Integration Tests Only
```bash
flutter test integration_test/
```

### All Tests
```bash
flutter test
```

## Test Dependencies

### Unit Test Dependencies
- `mocktail` - Mocking framework
- `test` - Dart test framework
- `flutter_test` - Flutter test utilities

### Integration Test Dependencies
- `hive_ce` - Database operations
- `http` - HTTP client operations
- `flutter/services` - Asset bundle operations

## Best Practices

1. **Keep unit tests fast** - Use mocks for external dependencies
2. **Test one thing at a time** - Each test should verify one specific behavior
3. **Use descriptive test names** - Test names should explain what is being tested
4. **Group related tests** - Use `group()` to organize related test cases
5. **Clean up after tests** - Use `tearDown()` to clean up test state
6. **Test edge cases** - Include tests for error conditions and boundary cases

## Test Coverage

The test suite provides comprehensive coverage of:
- Business logic and workflows
- Error handling and edge cases
- Interface contracts and implementations
- Component integration and data flow
- Configuration management and validation
- Database operations and persistence
- HTTP client integration and error handling
- Asset loading and transformation pipelines
