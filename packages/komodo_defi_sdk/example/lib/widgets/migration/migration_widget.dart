import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/migrations/bloc/migration_bloc_exports.dart';
import 'package:kdf_sdk_example/widgets/migration/initiate_migration_screen.dart';
import 'package:kdf_sdk_example/widgets/migration/migration_preview_screen.dart';
import 'package:kdf_sdk_example/widgets/migration/migration_results_screen.dart';
import 'package:kdf_sdk_example/widgets/migration/scanning_balances_screen.dart';
import 'package:kdf_sdk_example/widgets/migration/transferring_funds_screen.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

class MigrationWidget extends StatelessWidget {
  const MigrationWidget({
    this.sourceWallet,
    this.destinationWallet,
    super.key,
  });

  final KdfUser? sourceWallet;
  final KdfUser? destinationWallet;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 700,
        ),
        child: BlocConsumer<MigrationBloc, MigrationState>(
          listener: (context, state) {
            // Handle error messages via snackbar
            if (state.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Unknown error occurred'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  action: SnackBarAction(
                    label: 'Dismiss',
                    textColor: Theme.of(context).colorScheme.onError,
                    onPressed: () {
                      context.read<MigrationBloc>().add(
                        const MigrationErrorCleared(),
                      );
                    },
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Scaffold(
                appBar: _buildAppBar(context, state),
                body: _buildBody(context, state),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, MigrationState state) {
    return AppBar(
      title: const Text('Wallet Migration'),
      centerTitle: true,
      leading: state.isInProgress
          ? null
          : IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                context.read<MigrationBloc>().add(const MigrationCancelled());
                Navigator.of(context).pop();
              },
              key: const Key('close_migration_button'),
            ),
      automaticallyImplyLeading: !state.isInProgress,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
    );
  }

  Widget _buildBody(BuildContext context, MigrationState state) {
    switch (state.status) {
      case MigrationFlowStatus.idle:
        return InitiateMigrationScreen(
          sourceWallet: sourceWallet,
          destinationWallet: destinationWallet,
        );

      case MigrationFlowStatus.scanning:
        return const ScanningBalancesScreen();

      case MigrationFlowStatus.preview:
        return MigrationPreviewScreen(coins: state.coins);

      case MigrationFlowStatus.transferring:
        return TransferringFundsScreen(
          coins: state.coins,
          currentCoinIndex: state.currentCoinIndex,
        );

      case MigrationFlowStatus.completed:
        return MigrationResultsScreen(coins: state.coins);

      case MigrationFlowStatus.error:
        return _buildErrorScreen(context, state);
    }
  }

  Widget _buildErrorScreen(BuildContext context, MigrationState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),

          const SizedBox(height: 24),

          // Error title
          Text(
            'Migration Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Error message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  state.errorMessage ?? 'An unknown error occurred during migration.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (state.coins.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Some coins may have been partially processed.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<MigrationBloc>().add(const MigrationReset());
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                  key: const Key('close_error_button'),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<MigrationBloc>().add(const MigrationErrorCleared());
                    context.read<MigrationBloc>().add(
                      MigrationInitiated(
                        sourceWalletName: state.sourceWalletName,
                        destinationWalletName: state.destinationWalletName,
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  key: const Key('retry_migration_button'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Help text
          Text(
            'If the problem persists, please check your network connection and wallet status.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Helper widget to show migration in a modal dialog
class MigrationDialog extends StatelessWidget {
  const MigrationDialog({
    this.sourceWallet,
    this.destinationWallet,
    super.key,
  });

  final KdfUser? sourceWallet;
  final KdfUser? destinationWallet;

  /// Show the migration dialog
  static Future<void> show(
    BuildContext context, {
    KdfUser? sourceWallet,
    KdfUser? destinationWallet,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<MigrationBloc>(),
        child: MigrationDialog(
          sourceWallet: sourceWallet,
          destinationWallet: destinationWallet,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MigrationWidget(
      sourceWallet: sourceWallet,
      destinationWallet: destinationWallet,
    );
  }
}

/// Page-based migration widget for full-screen usage
class MigrationPage extends StatelessWidget {
  const MigrationPage({
    this.sourceWallet,
    this.destinationWallet,
    super.key,
  });

  final KdfUser? sourceWallet;
  final KdfUser? destinationWallet;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MigrationBloc, MigrationState>(
      listener: (context, state) {
        // Handle error messages via snackbar
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Unknown error occurred'),
              backgroundColor: Theme.of(context).colorScheme.error,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Theme.of(context).colorScheme.onError,
                onPressed: () {
                  context.read<MigrationBloc>().add(
                    const MigrationErrorCleared(),
                  );
                },
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Wallet Migration'),
            centerTitle: true,
            leading: state.isInProgress
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      context.read<MigrationBloc>().add(const MigrationCancelled());
                      Navigator.of(context).pop();
                    },
                  ),
            automaticallyImplyLeading: !state.isInProgress,
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MigrationState state) {
    switch (state.status) {
      case MigrationFlowStatus.idle:
        return InitiateMigrationScreen(
          sourceWallet: sourceWallet,
          destinationWallet: destinationWallet,
        );

      case MigrationFlowStatus.scanning:
        return const ScanningBalancesScreen();

      case MigrationFlowStatus.preview:
        return MigrationPreviewScreen(coins: state.coins);

      case MigrationFlowStatus.transferring:
        return TransferringFundsScreen(
          coins: state.coins,
          currentCoinIndex: state.currentCoinIndex,
        );

      case MigrationFlowStatus.completed:
        return MigrationResultsScreen(coins: state.coins);

      case MigrationFlowStatus.error:
        return _buildErrorScreen(context, state);
    }
  }

  Widget _buildErrorScreen(BuildContext context, MigrationState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),

          const SizedBox(height: 24),

          // Error title
          Text(
            'Migration Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Error message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  state.errorMessage ?? 'An unknown error occurred during migration.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (state.coins.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Some coins may have been partially processed.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<MigrationBloc>().add(const MigrationReset());
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<MigrationBloc>().add(const MigrationErrorCleared());
                    context.read<MigrationBloc>().add(
                      MigrationInitiated(
                        sourceWalletName: state.sourceWalletName,
                        destinationWalletName: state.destinationWalletName,
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Help text
          Text(
            'If the problem persists, please check your network connection and wallet status.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
