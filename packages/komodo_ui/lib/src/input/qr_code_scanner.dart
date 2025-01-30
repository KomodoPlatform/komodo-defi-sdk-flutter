// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCodeReaderOverlay extends StatefulWidget {
  const QrCodeReaderOverlay({super.key});

  @override
  State<QrCodeReaderOverlay> createState() => _QrCodeReaderOverlayState();
}

class _QrCodeReaderOverlayState extends State<QrCodeReaderOverlay> {
  bool qrDetected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //TODO!:l10n title: Text(LocaleKeys.qrScannerTitle.tr()),
        title: const Text('QR Scanner'),
        foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
        elevation: 0,
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionTimeoutMs: 1000,
          formats: [BarcodeFormat.qrCode],
        ),
        errorBuilder: _buildQrScannerError,
        onDetect: (capture) {
          if (qrDetected) return;

          final qrCodes = capture.barcodes;

          if (qrCodes.isNotEmpty) {
            final r = qrCodes.first.rawValue;
            qrDetected = true;

            // MRC: Guarantee that we don't try to close the current screen
            // if it was already closed
            if (!context.mounted) return;
            Navigator.pop(context, r);
          }
        },
        placeholderBuilder: (context, _) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildQrScannerError(
    BuildContext context,
    MobileScannerException exception,
    _,
  ) {
    late String errorMessage;

    switch (exception.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = // TODO!l10n: LocaleKeys.qrScannerErrorControllerUninitialized.tr();
            'The controller was used before being initialized';

      case MobileScannerErrorCode.permissionDenied:
        errorMessage = // TODO!l10n: LocaleKeys.qrScannerErrorPermissionDenied.tr();
            'Permission to use the camera was denied. Please enable camera '
            'permissions in your device settings.';
      // TODO: Disable the scanner button if the device does not
      // support scanning
      case MobileScannerErrorCode.unsupported:
        errorMessage = //TODO!l10n: LocaleKeys.qrScannerErrorUnsupported.tr();
            'Scanning is unsupported on the current device.';
      case MobileScannerErrorCode.genericError:
      case MobileScannerErrorCode.controllerDisposed:
      case MobileScannerErrorCode.controllerAlreadyInitialized:
        errorMessage = //TODO!l10n: LocaleKeys.qrScannerErrorGenericError.tr();
            'An error occurred while scanning the QR code. Please try again.';
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning,
            color: Colors.yellowAccent,
            size: 64,
          ),
          const SizedBox(height: 8),
          Text(
            //TODO!l10n: LocaleKeys.qrScannerErrorTitle.tr(),
            'Error',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 32),
          Text(errorMessage, style: Theme.of(context).textTheme.bodyLarge),
          if (exception.errorDetails != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  //TODO!l10n: '${LocaleKeys.errorCode.tr()}: ${exception.errorDetails!.code}',
                  'Error code: ${exception.errorDetails!.code}',
                ),
                Text(
                  //TODO!l10n: '${LocaleKeys.errorDetails.tr()}: ${exception.errorDetails!.details}',
                  'Error details: ${exception.errorDetails!.details}',
                ),
                Text(
                  //TODO!l10n: '${LocaleKeys.errorMessage.tr()}: ${exception.errorDetails!.message}',
                  'Error message: ${exception.errorDetails!.message}',
                ),
              ],
            ),
        ],
      ),
    );
  }
}
