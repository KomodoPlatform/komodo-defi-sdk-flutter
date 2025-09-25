import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart'
    show ZhtlcSyncParams;
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart'
    show
        DownloadProgress,
        DownloadResultPatterns,
        ZcashParamsDownloader,
        ZcashParamsDownloaderFactory,
        ZhtlcUserConfig;
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Handles ZHTLC configuration dialog with optional automatic Zcash parameters download.
///
/// This class manages the complete flow for configuring ZHTLC assets:
/// - On desktop platforms: automatically downloads Zcash parameters and prefills the path
/// - Shows progress dialog during download
/// - Displays configuration dialog for user input
/// - Handles download failures gracefully with fallback to manual configuration
class ZhtlcConfigDialogHandler {
  /// Shows a download progress dialog for Zcash parameters.
  ///
  /// Returns true if download completes successfully, false if cancelled.
  static Future<bool?> _showDownloadProgressDialog(
    BuildContext context,
    ZcashParamsDownloader downloader,
  ) async {
    const downloadTimeout = Duration(minutes: 10);
    // Start the download
    final downloadFuture = downloader.downloadParams().timeout(
      downloadTimeout,
      onTimeout: () => throw TimeoutException(
        'Download timed out after ${downloadTimeout.inMinutes} minutes',
        downloadTimeout,
      ),
    );
    var downloadComplete = false;
    var downloadSuccess = false;

    // Show the progress dialog that monitors download completion
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Listen for download completion and close dialog automatically
            downloadFuture
                .then((result) {
                  if (!downloadComplete && context.mounted) {
                    downloadComplete = true;
                    downloadSuccess = result.when(
                      success: (paramsPath) => true,
                      failure: (error) => false,
                    );

                    // Close the dialog with the result
                    Navigator.of(context).pop(downloadSuccess);
                  }
                })
                .catchError((Object e, StackTrace? stackTrace) {
                  if (!downloadComplete && context.mounted) {
                    downloadComplete = true;
                    downloadSuccess = false;

                    // Log the error for debugging
                    debugPrint('Zcash parameters download failed: $e');
                    if (stackTrace != null) {
                      debugPrint('Stack trace: $stackTrace');
                    }

                    // Pass error information back to caller
                    Navigator.of(
                      context,
                    ).pop({'success': false, 'error': e.toString()});
                  }
                });

            return AlertDialog(
              title: const Text('Downloading Zcash Parameters'),
              content: SizedBox(
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    StreamBuilder<DownloadProgress>(
                      stream: downloader.downloadProgress,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final progress = snapshot.data;
                          return Column(
                            children: [
                              Text(
                                progress?.displayText ?? '',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: (progress?.percentage ?? 0) / 100,
                              ),
                              Text(
                                '${(progress?.percentage ?? 0).toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        }
                        return const Text('Preparing download...');
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await downloader.cancelDownload();
                    Navigator.of(context).pop(false); // Cancelled
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Handles the complete ZHTLC configuration flow including optional download.
  ///
  /// On desktop platforms, this method will attempt to download Zcash parameters
  /// automatically. If successful, it prefills the parameters path in the dialog.
  /// Returns null if the user cancels the download or configuration.
  static Future<ZhtlcUserConfig?> handleZhtlcConfigDialog(
    BuildContext context,
    Asset asset,
  ) async {
    // On desktop platforms, try to download Zcash parameters first
    if (ZcashParamsDownloaderFactory.requiresDownload) {
      try {
        final downloader = ZcashParamsDownloaderFactory.create();

        // Check if parameters are already available
        final areAvailable = await downloader.areParamsAvailable();
        if (!areAvailable) {
          // Show download progress dialog (starts download internally)
          final downloadResult = await _showDownloadProgressDialog(
            context,
            downloader,
          );

          if (downloadResult == false) {
            // User cancelled the download
            return null;
          } else if (downloadResult == true) {
            // Download successful, get the path
            final paramsPath = await downloader.getParamsPath();
            return _showZhtlcConfigDialog(
              context,
              asset,
              prefilledZcashPath: paramsPath,
            );
          }
          // downloadResult == null means download failed, continue to manual config
        } else {
          // Parameters already available, get the path
          final paramsPath = await downloader.getParamsPath();
          return _showZhtlcConfigDialog(
            context,
            asset,
            prefilledZcashPath: paramsPath,
          );
        }
      } catch (e) {
        // Error creating downloader or getting params path
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error setting up Zcash parameters: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }

    // On web or if download failed, show dialog without prefilled path
    return _showZhtlcConfigDialog(context, asset);
  }

  /// Shows the ZHTLC configuration dialog.
  ///
  /// If [prefilledZcashPath] is provided, the Zcash parameters path field
  /// will be prefilled and made read-only.
  static Future<ZhtlcUserConfig?> _showZhtlcConfigDialog(
    BuildContext context,
    Asset asset, {
    String? prefilledZcashPath,
  }) async {
    final zcashPathController = TextEditingController(text: prefilledZcashPath);
    final blocksPerIterController = TextEditingController(text: '1000');
    final intervalMsController = TextEditingController(text: '0');

    var syncType = 'date'; // earliest | height | date
    final syncValueController = TextEditingController();
    DateTime? selectedDateTime;

    String formatDate(DateTime dateTime) {
      return dateTime.toIso8601String().split('T')[0];
    }

    Future<void> selectDate(BuildContext context) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDateTime ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        // Default to midnight (00:00) of the selected day
        selectedDateTime = DateTime(picked.year, picked.month, picked.day);
        syncValueController.text = formatDate(selectedDateTime!);
      }
    }

    // Initialize with default date (2 days ago)
    void initializeDate() {
      selectedDateTime = DateTime.now().subtract(const Duration(days: 2));
      syncValueController.text = formatDate(selectedDateTime!);
    }

    initializeDate();

    ZhtlcUserConfig? result;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AlertDialog(
              title: Text('Configure ${asset.id.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: zcashPathController,
                      readOnly: prefilledZcashPath != null,
                      decoration: InputDecoration(
                        labelText: 'Zcash parameters path',
                        helperText: prefilledZcashPath != null
                            ? 'Path automatically detected'
                            : 'Folder containing sapling params',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: blocksPerIterController,
                      decoration: const InputDecoration(
                        labelText: 'Blocks per iteration',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: intervalMsController,
                      decoration: const InputDecoration(
                        labelText: 'Scan interval (ms)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Start sync from:'),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: syncType,
                          items: const [
                            DropdownMenuItem(
                              value: 'earliest',
                              child: Text('Earliest (sapling)'),
                            ),
                            DropdownMenuItem(
                              value: 'height',
                              child: Text('Block height'),
                            ),
                            DropdownMenuItem(
                              value: 'date',
                              child: Text('Date & Time'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setInnerState(() => syncType = v);
                          },
                        ),
                        const SizedBox(width: 8),
                        if (syncType != 'earliest')
                          Expanded(
                            child: TextField(
                              controller: syncValueController,
                              decoration: InputDecoration(
                                labelText: syncType == 'height'
                                    ? 'Block height'
                                    : 'Select date & time',
                                suffixIcon: syncType == 'date'
                                    ? IconButton(
                                        icon: const Icon(Icons.calendar_today),
                                        onPressed: () => selectDate(context),
                                      )
                                    : null,
                              ),
                              keyboardType: syncType == 'height'
                                  ? TextInputType.number
                                  : TextInputType.none,
                              readOnly: syncType == 'date',
                              onTap: syncType == 'date'
                                  ? () => selectDate(context)
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final path = zcashPathController.text.trim();
                    if (path.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Zcash params path is required'),
                        ),
                      );
                      return;
                    }

                    ZhtlcSyncParams? syncParams;
                    if (syncType == 'earliest') {
                      syncParams = ZhtlcSyncParams.earliest();
                    } else if (syncType == 'height') {
                      final v = int.tryParse(syncValueController.text.trim());
                      if (v == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enter a valid block height'),
                          ),
                        );
                        return;
                      }
                      syncParams = ZhtlcSyncParams.height(v);
                    } else if (syncType == 'date') {
                      if (selectedDateTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a date and time'),
                          ),
                        );
                        return;
                      }
                      // Convert to Unix timestamp (seconds since epoch)
                      final unixTimestamp =
                          selectedDateTime!.millisecondsSinceEpoch ~/ 1000;
                      syncParams = ZhtlcSyncParams.date(unixTimestamp);
                    }

                    result = ZhtlcUserConfig(
                      zcashParamsPath: path,
                      scanBlocksPerIteration:
                          int.tryParse(blocksPerIterController.text) ?? 1000,
                      scanIntervalMs:
                          int.tryParse(intervalMsController.text) ?? 0,
                      syncParams: syncParams,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }
}
