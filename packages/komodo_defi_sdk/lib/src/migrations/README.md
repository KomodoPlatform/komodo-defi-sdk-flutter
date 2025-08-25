# One-Click Migration Feature - Implementation Guide

## 📋 Overview

This directory contains the complete implementation of the one-click migration feature for the Komodo DeFi SDK Flutter package. The feature enables users to migrate cryptocurrency balances from one wallet to another (primarily from Iguana to HD wallets) in a single, streamlined operation.

## 🏗️ Architecture

The migration feature follows the established clean architecture pattern used throughout the Komodo DeFi SDK:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐  │
│  │ Migration BLoC  │  │ Migration UI    │  │ Migration    │  │
│  │                 │  │ Components      │  │ States       │  │
│  └─────────────────┘  └─────────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐  │
│  │ Migration       │  │ Migration       │  │ Migration    │  │
│  │ Manager         │  │ Models          │  │ Errors       │  │
│  └─────────────────┘  └─────────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐  │
│  │ Activation      │  │ Withdrawal      │  │ Balance      │  │
│  │ Manager         │  │ Manager         │  │ Manager      │  │
│  └─────────────────┘  └─────────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 📂 Directory Structure

```
migrations/
├── docs/                          # Documentation
│   ├── implementation-plan.md      # Complete technical architecture
│   └── action-plan.md              # Project roadmap and phases
├── subtasks/                       # Individual development tasks
│   ├── task-01-data-models.md      # Core data structures
│   ├── task-02-migration-manager.md # Business logic service
│   ├── task-03-migration-bloc.md   # State management
│   ├── task-04-ui-components.md    # Flutter UI widgets
│   └── task-05-testing-integration.md # Testing strategy
├── models/                         # Data models (to be implemented)
├── bloc/                          # BLoC state management
├── widgets/                       # UI components
├── utils/                         # Utility classes
├── migration_manager.dart         # Core business logic
├── migration_config.dart          # Configuration management
├── migration_logger.dart          # Logging utilities
├── migration_models.dart          # Barrel export for models
├── migration_bloc.dart            # Barrel export for BLoC
├── migration_widgets.dart         # Barrel export for widgets
└── README.md                      # This file
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart 3.0+
- Basic understanding of BLoC pattern
- Familiarity with Komodo DeFi SDK structure

### Development Workflow

The implementation is divided into 5 independent subtasks that can be tackled by different developers:

1. **[Task 01: Data Models](subtasks/task-01-data-models.md)** ⭐ **START HERE**
   - Priority: High
   - Difficulty: Beginner
   - Duration: 2-3 days
   - Dependencies: None

2. **[Task 02: Migration Manager](subtasks/task-02-migration-manager.md)**
   - Priority: High
   - Difficulty: Intermediate
   - Duration: 4-5 days
   - Dependencies: Task 01

3. **[Task 03: Migration BLoC](subtasks/task-03-migration-bloc.md)**
   - Priority: High
   - Difficulty: Intermediate
   - Duration: 3-4 days
   - Dependencies: Task 01, Task 02

4. **[Task 04: UI Components](subtasks/task-04-ui-components.md)**
   - Priority: High
   - Difficulty: Intermediate
   - Duration: 4-5 days
   - Dependencies: Task 01, Task 03

5. **[Task 05: Testing & Integration](subtasks/task-05-testing-integration.md)**
   - Priority: High
   - Difficulty: Intermediate to Advanced
   - Duration: 3-4 days
   - Dependencies: All previous tasks

### Quick Start Guide

1. **Read the Documentation**
   ```bash
   # Start with the implementation plan
   open docs/implementation-plan.md
   
   # Review the action plan for project timeline
   open docs/action-plan.md
   ```

2. **Setup Development Environment**
   ```bash
   # Install dependencies (from project root)
   melos bootstrap
   
   # Or for individual package
   cd packages/komodo_defi_sdk
   flutter pub get
   ```

3. **Code Generation (Required for Data Models)**
   ```bash
   # Generate freezed code for migration models (from project root)
   melos run runners:generate
   
   # Or for individual package
   cd packages/komodo_defi_sdk
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Begin Implementation**
   ```bash
   # Start with Task 01 (Data Models)
   open subtasks/task-01-data-models.md
   ```

5. **Follow the Subtask Structure**
   - Each subtask contains detailed requirements
   - Code examples and templates are provided
   - Acceptance criteria for completion
   - Testing requirements included

### Code Generation Notes

**Important**: After implementing the data models in Task 01, you MUST run code generation to create the required `.freezed.dart` and `.g.dart` files:

```bash
# From project root (recommended)
melos run runners:generate

# Or from package directory
cd packages/komodo_defi_sdk
dart run build_runner build --delete-conflicting-outputs
```

The following files will be generated:
- `migration_request.freezed.dart` & `migration_request.g.dart`
- `migration_operation_preview.freezed.dart` & `migration_operation_preview.g.dart`
- `migration_progress.freezed.dart` & `migration_progress.g.dart`
- `migration_result.freezed.dart` & `migration_result.g.dart`
- `migration_errors.freezed.dart` & `migration_errors.g.dart`

**Note**: The generated files are required for the models to compile and should be committed to version control.

## 🎯 Core Features

### User Journey

1. **Wallet Selection**: Choose source (Iguana) and target (HD) wallets
2. **Asset Selection**: Select which assets to migrate with filtering options
3. **Migration Preview**: Review fees, amounts, and migration details
4. **Progress Tracking**: Real-time updates during migration process
5. **Results Summary**: Success/failure status with retry options

### Key Components

- **MigrationManager**: Orchestrates the entire migration process
- **Migration BLoC**: Manages UI state and user interactions  
- **Migration Models**: Data structures for requests, previews, and results
- **UI Components**: Flutter widgets for each step of the process
- **Error Handling**: Comprehensive error management and user feedback

## 📋 Requirements Summary

### Functional Requirements

- **F-01**: Migration trigger from any screen showing wallet info
- **F-02**: Flexible wallet-pair selection (default: Iguana → HD)
- **F-03**: Asset filtering (all coins with balance or activated coins only)
- **F-04**: Batch asset activation with balance and fee queries
- **F-05**: User control over asset selection before migration
- **F-06**: Comprehensive preview screen with per-asset details
- **F-07**: User confirmation required before execution
- **F-08**: Per-asset execution with detailed progress tracking
- **F-09**: Real-time progress UI with success/error indicators
- **F-10**: Manual retry mechanism for failed assets
- **F-11**: No automatic retries or hidden operations
- **F-12**: Cross-platform responsive UI design
- **F-13**: Comprehensive logging for auditing and support

### Technical Requirements

- Clean architecture with BLoC pattern
- Integration with existing SDK services
- Immutable value objects throughout
- Comprehensive error handling
- Batch processing with configurable limits
- Local key management and signing
- Extensive testing coverage

## 🧪 Testing Strategy

### Test Coverage Requirements

- **Unit Tests**: >90% code coverage
- **Widget Tests**: All UI components tested
- **Integration Tests**: Complete user flows validated
- **E2E Tests**: Real service integration verified
- **Performance Tests**: Response time and memory usage benchmarks

### Test Categories

1. **Unit Tests**: Individual component functionality
2. **Integration Tests**: Service interaction validation
3. **Widget Tests**: UI component behavior verification
4. **Performance Tests**: Scalability and efficiency validation
5. **E2E Tests**: Complete user journey validation

## 🔧 Development Guidelines

### Code Standards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use SDK naming conventions consistently
- Implement comprehensive documentation
- Include unit tests for all public APIs
- Follow existing SDK architectural patterns

### Error Handling

```dart
enum MigrationError {
  activationFailed,
  insufficientBalance,
  insufficientFee,
  txCreationFailed,
  txBroadcastFailed,
  walletLocked,
  invalidWallet,
  networkError,
}
```

### Logging Standards

```dart
// Use structured logging with context
MigrationLogger.logMigrationStart(migrationId, assetCount: count);
MigrationLogger.logAssetResult(migrationId, assetId, success: true);
MigrationLogger.logMigrationComplete(migrationId, result);
```

## 📚 Resources

### Documentation

- [Implementation Plan](docs/implementation-plan.md) - Complete technical specification
- [Action Plan](docs/action-plan.md) - Project timeline and phases
- [Flutter Documentation](https://docs.flutter.dev/)
- [BLoC Library Guide](https://bloclibrary.dev/)

### Existing SDK References

- `WithdrawalManager` - Reference implementation for transaction management
- `ActivationManager` - Asset activation patterns
- `BalanceManager` - Balance query implementations
- `FeeManager` - Fee estimation approaches

## 🤝 Contributing

### Development Process

1. **Choose a Subtask**: Start with Task 01 if new to the project
2. **Read Requirements**: Thoroughly review subtask documentation
3. **Implement Solution**: Follow provided examples and patterns
4. **Write Tests**: Achieve required coverage levels
5. **Request Review**: Submit for peer review before marking complete
6. **Integration**: Ensure compatibility with other components

### Code Review Checklist

- [ ] Follows SDK architectural patterns
- [ ] Includes comprehensive tests
- [ ] Handles all error scenarios
- [ ] Documentation is complete
- [ ] Performance meets requirements
- [ ] Security best practices followed
- [ ] UI is accessible and responsive

## 🚧 Implementation Status

| Component | Status | Assigned | Completion |
|-----------|--------|----------|------------|
| Data Models | 🟡 Not Started | - | 0% |
| Migration Manager | 🟡 Not Started | - | 0% |
| Migration BLoC | 🟡 Not Started | - | 0% |
| UI Components | 🟡 Not Started | - | 0% |
| Testing & Integration | 🟡 Not Started | - | 0% |

**Legend**: 🟡 Not Started, 🟠 In Progress, 🟢 Complete, 🔴 Blocked

## ⚠️ Important Notes

### Security Considerations

- All private key operations remain within existing secure boundaries
- No additional authentication required beyond current SDK patterns
- Transaction signing performed locally on device
- No sensitive data exposed in logs or analytics

### Performance Expectations

- Preview generation: <30 seconds for 50 assets
- Memory usage: <100MB additional during migration
- UI responsiveness: <200ms for user interactions
- Batch processing: Configurable batch sizes (default: 10)

### Limitations

- Only migrates standard cryptocurrency balances
- No support for NFTs or special asset types
- Requires network connectivity throughout process
- Source wallet must have sufficient funds for transaction fees

## 📞 Support

### Getting Help

1. **Documentation**: Review implementation and action plans
2. **Code Examples**: Each subtask includes detailed examples
3. **Team Support**: Reach out to project leads for architecture questions
4. **Pair Programming**: Available for complex integration scenarios

### Communication Channels

- Technical questions: Project lead or senior developers
- Architecture decisions: Team architecture review
- UI/UX feedback: Design team collaboration
- Testing support: QA team coordination

---

**Last Updated**: 2024-01-15  
**Next Review**: 2024-01-22  
**Maintainer**: Migration Feature Team

Ready to start building? Begin with [Task 01: Data Models](subtasks/task-01-data-models.md)! 🚀