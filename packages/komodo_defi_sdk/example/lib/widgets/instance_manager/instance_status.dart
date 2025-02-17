// instance_status.dart
import 'package:flutter/material.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/kdf_instance_state.dart';

class InstanceStatus extends StatelessWidget {
  const InstanceStatus({required this.instance, super.key});

  final KdfInstanceState instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            instance.isConnected
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            instance.isConnected ? Icons.check_circle : Icons.error,
            color: instance.isConnected ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            instance.isConnected ? 'Connected' : 'Disconnected',
            style: TextStyle(
              color: instance.isConnected ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
          if (instance.error != null) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: instance.error,
              child: const Icon(Icons.info, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
