# One-Click Migration Feature

This directory contains the implementation of a one-click fund migration feature for the Komodo DeFi SDK Flutter example app. The feature allows users to migrate all funds from their legacy (Iguana) wallet to an HD (Hierarchical Deterministic) wallet through a guided, user-friendly process.

## Overview

The migration feature implements a step-by-step wizard flow that guides users through:

1. **Initiation** - User confirms they want to migrate funds
2. **Scanning** - System scans for coins with non-zero balances
3. **Preview** - User reviews coins to be migrated and any issues
4. **Transfer** - Coins are transferred sequentially to the HD wallet
5. **Results** - User sees final results with transaction details

## Architecture

### State Management
- **MigrationBloc** - Manages the overall migration state and orchestrates the flow
- **MigrationState** - Represents the current state of migration (idle, scanning, preview, transferring, completed, error)
- **MigrationCoin** - Represents individual coins with their migration status

### UI Components

#### Core Screens
- **InitiateMigrationScreen** - Initial screen where users start the migration
- **ScanningBalancesScreen** - Shows loading while scanning for coins
- **MigrationPreviewScreen** - Displays coins to be migrated with status
- **TransferringFundsScreen** - Shows real-time transfer progress
- **MigrationResultsScreen** - Final results with transaction details

#### Main Widget
- **MigrationWidget** - Main orchestrator that switches between screens based on state
- **MigrationDialog** - Dialog wrapper for modal presentation
- **MigrationPage** - Full-page wrapper for standalone presentation

## Usage

### Integration

The migration feature is integrated into the main app via a "Migrate to HD" button that appears in the `LoggedInViewWidget` for legacy wallet users:

```dart
// Add to your widget
if (!widget.currentUser.isHd) ...[
  FilledButton.tonalIcon(
    onPressed: () => _showMigrationDialog(),
    icon: const Icon(Icons.sync_alt),
    label: const Text('Migrate to HD'),
    key: const Key('migrate_to_hd_button'),
  ),
],
```

### Showing Migration Dialog

```dart
Future<void> _showMigrationDialog() async {
  await MigrationDialog.show(
    context,
    sourceWallet: widget.currentUser,
  );
}
```

### BLoC Provider Setup

The MigrationBloc is automatically provided in the main app's widget tree:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (context) => AuthBloc(sdk: instance.sdk)),
    BlocProvider(create: (context) => MigrationBloc(sdk: instance.sdk)),
  ],
  child: YourWidget(),
)
```

## Features

### User Experience
- **Guided Flow** - Step-by-step wizard with clear progress indicators
- **Error Handling** - Comprehensive error messages and retry options
- **Real-time Feedback** - Live updates during transfers
- **Transaction Verification** - Links to blockchain explorers and copy-to-clipboard functionality

### Technical Features
- **Sequential Transfers** - Coins are transferred one at a time to avoid conflicts
- **Fee Validation** - Checks if balances are sufficient to cover network fees
- **Retry Mechanism** - Failed transfers can be retried individually or in batch
- **Cancellation** - Users can cancel during scanning phase
- **State Persistence** - Migration state is maintained throughout the process

## Coin Status Types

- **Ready** - Coin can be migrated
- **Fee Too Low** - Balance insufficient to cover network fees
- **Not Supported** - Coin not supported for migration
- **Transferring** - Currently being transferred
- **Transferred** - Successfully migrated with transaction ID
- **Failed** - Transfer failed with error message
- **Skipped** - Migration was skipped

## Error Handling

The system handles various error scenarios:

- **No Coins Found** - When no coins have non-zero balances
- **Network Errors** - Temporary connection issues
- **Insufficient Fees** - When coin balances can't cover network fees
- **Transaction Failures** - When blockchain transactions fail
- **SDK Errors** - When the underlying SDK encounters issues

## BLoC Events and States

### Events
- `MigrationInitiated` - Start the migration process
- `MigrationConfirmed` - User confirms after preview
- `MigrationCancelled` - Cancel migration
- `MigrationRetryFailed` - Retry all failed coins
- `MigrationRetryCoin` - Retry specific coin
- `MigrationReset` - Reset to initial state
- `MigrationErrorCleared` - Clear error state

### States
- `MigrationFlowStatus` - idle, scanning, preview, transferring, completed, error
- `CoinMigrationStatus` - ready, feeTooLow, notSupported, transferring, transferred, failed, skipped

## Testing

### Widget Tests
- Individual screen component tests
- State management tests
- User interaction tests

### Integration Tests
- Full migration flow testing
- Button interactions and dialog appearance
- Error scenario testing

### Running Tests

```bash
# Widget tests
flutter test test/widgets/migration/

# Integration tests
flutter test integration_test/migration_test.dart

# All tests
flutter test
```

## Current Implementation

The current implementation includes:

- **Real SDK Integration** - Uses actual KomodoDefiSdk services
- **Mock Transfer Simulation** - Simulates transfers with 3-second delays for demonstration
- **Real Asset Discovery** - Fetches actual assets from the SDK
- **Mock Transaction IDs** - Generates realistic-looking transaction hashes
- **Configurable Success Rates** - 90% success rate for main flow, 80% for retries

## Customization

### Styling
All UI components use Material Design 3 theming and can be customized through the app's theme:

```dart
ThemeData(
  colorSchemeSeed: Colors.blue,
  useMaterial3: true,
)
```

### Behavior
Migration behavior can be customized by:

- Modifying coin scanning logic in `MigrationBloc._scanForCoinsWithBalance()`
- Customizing transfer logic in `MigrationBloc._performMigration()`
- Adjusting UI flow in the individual screen widgets
- Configuring success rates and timing in the BLoC

## Dependencies

- **flutter_bloc** - State management
- **komodo_defi_sdk** - Core SDK functionality
- **komodo_defi_types** - Type definitions
- **url_launcher** - Opening blockchain explorers
- **equatable** - Value equality

## Future Enhancements

Potential improvements for production use:

1. **Real Transfer Implementation** - Replace mock transfers with actual SDK calls
2. **Batch Transfers** - Option to transfer multiple coins simultaneously
3. **Fee Estimation** - More accurate fee calculation before migration
4. **Wallet Selection** - Support for multiple source/destination wallets
5. **Progress Persistence** - Resume interrupted migrations
6. **Advanced Filtering** - User selection of specific coins to migrate
7. **Analytics** - Migration success/failure tracking
8. **Notifications** - Background notifications for long migrations

## Security Considerations

- All transfers require proper authentication
- Private keys are handled securely by the underlying SDK
- Transaction signing follows established security protocols
- No sensitive data is stored in migration state
- All network communications use secure channels

## Accessibility

The migration UI follows accessibility best practices:

- Semantic labels for screen readers
- High contrast color schemes
- Keyboard navigation support
- Clear visual indicators for status changes
- Descriptive error messages

## Recent Updates

**Migration Feature Now Enabled (Current Version)**

- Migration feature is now fully integrated and enabled
- BLoC is properly configured with the KomodoDefiSdk
- All UI components are connected and functional
- Migration dialog appears when clicking "Migrate to HD" button
- Real asset discovery and mock transfer simulation working
- Error handling and retry functionality implemented
- Comprehensive state management with reactive UI updates

The migration feature is ready for testing and further development!