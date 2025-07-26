import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class NewAddressDialogWidget extends StatefulWidget {
  const NewAddressDialogWidget({required this.stream, super.key});

  final Stream<NewAddressState> stream;

  @override
  State<NewAddressDialogWidget> createState() => _NewAddressDialogWidgetState();
}

class _NewAddressDialogWidgetState extends State<NewAddressDialogWidget> {
  late final StreamSubscription<NewAddressState> _subscription;
  NewAddressState? _state;

  @override
  void initState() {
    super.initState();
    _subscription = widget.stream.listen((state) {
      setState(() => _state = state);
      if (state.status == NewAddressStatus.completed) {
        Navigator.of(context).pop(state.address);
      } else if (state.status == NewAddressStatus.cancelled) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _cancelAddressGeneration() async {
    final state = _state;
    if (state?.taskId != null) {
      try {
        final sdk = context.read<KomodoDefiSdk>();
        await sdk.client.rpc.hdWallet.getNewAddressTaskCancel(
          taskId: state!.taskId!,
        );
      } catch (e) {
        // If cancellation fails, still dismiss the dialog
        // The error is likely due to the task already being completed or cancelled
      }
    }

    // Always dismiss the dialog
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;

    String message;
    if (state == null) {
      message = 'Initializing...';
    } else {
      switch (state.status) {
        case NewAddressStatus.initializing:
        case NewAddressStatus.processing:
        case NewAddressStatus.waitingForDevice:
        case NewAddressStatus.waitingForDeviceConfirmation:
        case NewAddressStatus.pinRequired:
        case NewAddressStatus.passphraseRequired:
          message = state.message ?? 'Processing...';
        case NewAddressStatus.confirmAddress:
          message = 'Confirm the address on your device';
        case NewAddressStatus.completed:
          message = 'Completed';
        case NewAddressStatus.error:
          message = state.error ?? 'Error';
        case NewAddressStatus.cancelled:
          message = 'Cancelled';
      }
    }

    final showAddress = state?.status == NewAddressStatus.confirmAddress;

    return AlertDialog(
      title: const Text('Generating Address'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAddress)
            SelectableText(state?.expectedAddress ?? '')
          else
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(),
            ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _cancelAddressGeneration,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
