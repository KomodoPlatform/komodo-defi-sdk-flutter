import 'package:flutter/material.dart';

class ErrorDisplay extends StatefulWidget {
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
  State<ErrorDisplay> createState() => _ErrorDisplayState();
}

class _ErrorDisplayState extends State<ErrorDisplay> {
  bool showDetailedMessage = false;

  /// Shows the detailed error message if the override is true, or if the user
  /// has toggled the detailed message to be shown.
  bool get shouldShowDetailedMessage =>
      widget.detailedMessage != null &&
      (widget.showDetails || showDetailedMessage);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine color based on whether this is a warning or error
    final color =
        widget.isWarning ? theme.colorScheme.tertiary : theme.colorScheme.error;

    // Determine background and container design
    final backgroundColor =
        widget.isWarning
            ? theme.colorScheme.tertiaryContainer.withValues(alpha: 0.7)
            : theme.colorScheme.errorContainer.withValues(alpha: 0.7);

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
                  widget.icon ??
                      (widget.isWarning
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
                        widget.message,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color:
                              widget.isWarning
                                  ? theme.colorScheme.onTertiaryContainer
                                  : theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (shouldShowDetailedMessage) ...[
                        const SizedBox(height: 8),
                        SelectableText(
                          widget.detailedMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                widget.isWarning
                                    ? theme.colorScheme.onTertiaryContainer
                                        .withValues(alpha: 0.8)
                                    : theme.colorScheme.onErrorContainer
                                        .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (widget.child != null) ...[
              const SizedBox(height: 16),
              widget.child!,
            ],
            ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.detailedMessage != null)
                    TextButton(
                      onPressed: () {
                        // If the widget showDetails override is present, then
                        // we don't want to toggle the showDetailedMessage state
                        if (widget.showDetails) {
                          return;
                        }

                        setState(() {
                          showDetailedMessage = !showDetailedMessage;
                        });
                      },
                      child: Text(
                        shouldShowDetailedMessage
                            ? 'Hide Details'
                            : 'Show Details',
                        style: TextStyle(color: color),
                      ),
                    ),
                  const SizedBox(width: 12),
                  if (widget.actionLabel != null &&
                      widget.onActionPressed != null)
                    ElevatedButton(
                      onPressed: widget.onActionPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor:
                            widget.isWarning
                                ? theme.colorScheme.onTertiary
                                : theme.colorScheme.onError,
                      ),
                      child: Text(widget.actionLabel!),
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
