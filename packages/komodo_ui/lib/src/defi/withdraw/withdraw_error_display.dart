import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    required this.message,
    this.icon,
    this.isWarning = false,
    this.child,
    this.actionLabel,
    this.onActionPressed,
    this.detailedMessage,
    this.showDetails = false,
    super.key,
  });

  final String message;
  final IconData? icon;
  final bool isWarning;
  final Widget? child;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final String? detailedMessage;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine color based on whether this is a warning or error
    final color =
        isWarning ? theme.colorScheme.tertiary : theme.colorScheme.error;

    // Determine background and container design
    final backgroundColor =
        isWarning
            ? theme.colorScheme.tertiaryContainer.withOpacity(0.7)
            : theme.colorScheme.errorContainer.withOpacity(0.7);

    return Card(
      elevation: 0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon ??
                      (isWarning
                          ? Icons.warning_amber_rounded
                          : Icons.error_outline),
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color:
                              isWarning
                                  ? theme.colorScheme.onTertiaryContainer
                                  : theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (detailedMessage != null && showDetails) ...[
                        const SizedBox(height: 8),
                        Text(
                          detailedMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                isWarning
                                    ? theme.colorScheme.onTertiaryContainer
                                        .withOpacity(0.8)
                                    : theme.colorScheme.onErrorContainer
                                        .withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (child != null) ...[const SizedBox(height: 16), child!],
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (detailedMessage != null)
                    TextButton(
                      onPressed: () {
                        // Show detailed error message or toggle visibility
                        // This would need state management in a StatefulWidget
                      },
                      child: Text(
                        showDetails ? 'Hide Details' : 'Show Details',
                        style: TextStyle(color: color),
                      ),
                    ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onActionPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor:
                          isWarning
                              ? theme.colorScheme.onTertiary
                              : theme.colorScheme.onError,
                    ),
                    child: Text(actionLabel!),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
