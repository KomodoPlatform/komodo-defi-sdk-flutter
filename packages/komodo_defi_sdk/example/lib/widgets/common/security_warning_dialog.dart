import 'package:flutter/material.dart';

class SecurityWarningDialog extends StatelessWidget {
  const SecurityWarningDialog({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 8),
          Text('Security Warning'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚠️ Private Key Export Security Warning:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text('• Private keys provide FULL control over your funds'),
          const Text(
            '• Anyone with access to these keys can steal your assets',
          ),
          const Text('• Never share private keys with anyone'),
          const Text('• Store them securely and delete when no longer needed'),
          const Text('• Only export when absolutely necessary'),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('I Understand - Export'),
        ),
      ],
    );
  }

  static Future<bool> show(BuildContext context, String message) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => SecurityWarningDialog(
                title: 'Security Warning',
                message: message,
              ),
        ) ??
        false;
  }
}
