import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/auth/auth_bloc.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/auth_form_widget.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/instance_status.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/kdf_instance_state.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/logged_in_view_widget.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class InstanceView extends StatefulWidget {
  const InstanceView({
    required this.instance,
    required this.state,
    required this.statusMessage,
    required this.searchController,
    required this.filteredAssets,
    required this.onNavigateToAsset,
    super.key,
  });

  final KdfInstanceState instance;
  final String state;
  final String statusMessage;
  final TextEditingController searchController;
  final List<Asset> filteredAssets;
  final void Function(Asset) onNavigateToAsset;

  @override
  State<InstanceView> createState() => _InstanceViewState();
}

class _InstanceViewState extends State<InstanceView> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthKnownUsersFetched());
    context.read<AuthBloc>().add(const AuthInitialStateChecked());
  }

  Future<void> _deleteWallet(String walletName) async {
    if (walletName.isEmpty) {
      _showError('Wallet name is required');
      return;
    }
    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Wallet'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter the wallet password to confirm deletion. This action cannot be undone.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await widget.instance.sdk.auth.deleteWallet(
        walletName: walletName,
        password: passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Wallet deleted')));
        context.read<AuthBloc>().add(const AuthKnownUsersFetched());
      }
    } on AuthException catch (e) {
      _showError('Delete wallet failed: ${e.message}');
    } catch (e) {
      _showError('Delete wallet failed: $e');
    }
  }

  Future<void> _showTrezorPinDialog(int taskId, String? message) async {
    final pinController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) {
                // Handle back button press - trigger cancel action
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(
                  AuthTrezorCancelled(taskId: taskId),
                );
              }
            },
            child: AlertDialog(
              title: const Text('Trezor PIN Required'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message ?? 'Please enter your Trezor PIN'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    decoration: const InputDecoration(
                      labelText: 'PIN',
                      border: OutlineInputBorder(),
                      helperText: 'Use the PIN pad on your Trezor device',
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<AuthBloc>().add(
                      AuthTrezorCancelled(taskId: taskId),
                    );
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final pin = pinController.text;
                    Navigator.of(context).pop(pin);
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
    );

    if (result != null && mounted) {
      context.read<AuthBloc>().add(
        AuthTrezorPinProvided(taskId: taskId, pin: result),
      );
    }
  }

  Future<void> _showTrezorPassphraseDialog(int taskId, String? message) async {
    final passphraseController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) {
                // Handle back button press - trigger cancel action
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(
                  AuthTrezorCancelled(taskId: taskId),
                );
              }
            },
            child: AlertDialog(
              title: const Text('Trezor Passphrase Required'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message ?? 'Please choose your passphrase option'),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose your passphrase configuration:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passphraseController,
                    decoration: const InputDecoration(
                      labelText: 'Hidden passphrase (optional)',
                      border: OutlineInputBorder(),
                      helperText:
                          'Enter your passphrase or leave empty for standard wallet',
                    ),
                    obscureText: true,
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<AuthBloc>().add(
                      AuthTrezorCancelled(taskId: taskId),
                    );
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    // Standard wallet with empty passphrase
                    Navigator.of(context).pop('');
                  },
                  child: const Text('Standard Wallet'),
                ),
                FilledButton(
                  onPressed: () {
                    // Hidden passphrase wallet
                    final passphrase = passphraseController.text;
                    Navigator.of(context).pop(passphrase);
                  },
                  child: const Text('Hidden Wallet'),
                ),
              ],
            ),
          ),
    );

    if (result != null && mounted) {
      context.read<AuthBloc>().add(
        AuthTrezorPassphraseProvided(taskId: taskId, passphrase: result),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.error) {
          _showError(state.errorMessage ?? 'Unknown error');
        }

        // Handle Trezor-specific states
        if (state.isTrezorPinRequired) {
          _showTrezorPinDialog(
            state.trezorTaskId!,
            state.trezorMessage ?? 'Enter PIN',
          );
        } else if (state.isTrezorPassphraseRequired) {
          _showTrezorPassphraseDialog(
            state.trezorTaskId!,
            state.trezorMessage ?? 'Enter Passphrase',
          );
        } else if (state.isTrezorAwaitingConfirmation) {
          // Show a non-blocking message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.trezorMessage ?? 'Please confirm on your Trezor device',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        final currentUser =
            state.status == AuthStatus.authenticated ? state.user : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InstanceStatus(instance: widget.instance),
            const SizedBox(height: 16),
            Text(widget.statusMessage),
            if (currentUser != null) ...[
              Text(
                currentUser.isHd ? 'HD' : 'Legacy',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            if (currentUser == null)
              Expanded(
                child: SingleChildScrollView(
                  child: AuthFormWidget(
                    authState: state,
                    onDeleteWallet: _deleteWallet,
                  ),
                ),
              )
            else
              Expanded(
                child: LoggedInViewWidget(
                  currentUser: currentUser,
                  filteredAssets: widget.filteredAssets,
                  searchController: widget.searchController,
                  onNavigateToAsset: widget.onNavigateToAsset,
                  instance: widget.instance,
                ),
              ),
          ],
        );
      },
    );
  }
}
