<p align="center">
    <a href="https://github.com/KomodoPlatform/komodo-defi-framework" alt="Contributors">
        <img width="420" src="https://user-images.githubusercontent.com/24797699/252396802-de8f9264-8056-4430-a17d-5ecec9668dfc.png" />
    </a>
</p>

# Komodo Defi Framework SDK for Flutter

This is a series of Flutter packages for integrating the [Komodo DeFi Framework](https://komodoplatform.com/en/komodo-defi-framework.html) into Flutter applications. This enhances devex by providing an intuitive abstraction layer and handling all binary/media file fetching, reducing what previously would have taken months to understand the API and build a Flutter dApp with KDF integration into a few days.

See the Komodo DeFi Framework (API) source repository at [KomodoPlatform/komodo-defi-framework](https://github.com/KomodoPlatform/komodo-defi-framework) and view the demo site (source in [example](./example)) project at [https://komodo-playground.web.app](https://komodo-playground.web.app).

The recommended entry point ([komodo_defi_sdk](/packages/komodo_defi_sdk/README.md)) is a high-level opinionated library that provides a simple way to build cross-platform Komodo Defi Framework applications (primarily focused on wallets). This repository consists of multiple other child packages in the [packages](./packages) folder, which is orchestrated by the [komodo_defi_sdk](/packages/komodo_defi_sdk/README.md) package.

Note: Most of this README focuses on the lower-level `komodo-defi-framework` package and still needs to be updated to focus on the primary package, `komodo_defi_sdk`.

This project supports building for macOS (more native platforms coming soon) and the web. KDF can either be run as a local Rust binary or you can connect to a remote instance. 1-Click setup for DigitalOcean and AWS deployment is in progress.

From v2.5.0-beta, seed nodes configuration is required for KDF to function properly. The `seednodes` parameter must be specified unless `disable_p2p` is set to true. See the [configuration documentation](https://docs.komodefi.com/komodo-defi-framework/setup/configure-mm2-json/) for more details.

Use the [komodo_defi_framework](packages/komodo_defi_sdk) package for an unopinionated implementation that gives access to the underlying KDF methods.

The structure for this repository is inspired by the [Flutter BLoC](https://github.com/felangel/bloc) project.

This project generally follows the guidelines and high standards set by [Very Good Ventures](https://vgv.dev/).

TODO: Add a comprehensive README

TODO: Contribution guidelines and architecture overview

## Example

Below is an extract from the [example project](https://github.com/KomodoPlatform/komodo-defi-sdk-flutter/blob/dev/example/lib/main.dart) showing the straightforward integration. Note that this is for the [komodo_defi_framework](packages/komodo_defi_framework), and the [komodo_defi_sdk](/packages/komodo_defi_sdk/README.md) will provide a higher-layer abstraction.

Create the configuration for the desired runtime:

```dart
    switch (_selectedHostType) {
      case 'remote':
        config = RemoteConfig(
          userpass: _userpassController.text,
          ipAddress: '$_selectedProtocol://${_ipController.text}',
          port: int.parse(_portController.text),
        );
        break;
      case 'aws':
        config = AwsConfig(
          userpass: _userpassController.text,
          region: _awsRegionController.text,
          accessKey: _awsAccessKeyController.text,
          secretKey: _awsSecretKeyController.text,
          instanceType: _awsInstanceTypeController.text,
        );
        break;
      case 'local':
        config = LocalConfig(userpass: _userpassController.text);
        break;
      default:
        throw Exception(
          'Invalid/unsupported host type: $_selectedHostType',
        );
    }
```

Start KDF:

```dart
void _startKdf(String passphrase) async {
    _statusMessage = null;

    if (_kdfFramework == null) {
      _showMessage('Please configure the framework first.');
      return;
    }

    try {
      final result = await _kdfFramework!.startKdf(passphrase);
      setState(() {
        _statusMessage = 'KDF running: $result';
        _isRunning = true;
      });

      if (!result.isRunning()) {
        _showMessage('Failed to start KDF: $result');
        // return;
      }
    } catch (e) {
      _showMessage('Failed to start KDF: $e');
    }

    await _saveData();
  }
```

Execute RPC requests:

```dart
executeRequest: (rpcInput) async {
      if (_kdfFramework == null || !_isRunning) {
        _showMessage('KDF is not running.');
        throw Exception('KDF is not running.');
      }
      return (await _kdfFramework!.executeRpc(rpcInput)).toString();
    },
```

Stop KDF:

```dart

  void _stopKdf() async {
    if (_kdfFramework == null) {
      _showMessage('Please configure the framework first.');
      return;
    }

    try {
      final result = await _kdfFramework!.kdfStop();
      setState(() {
        _statusMessage = 'KDF stopped: $result';
        _isRunning = false;
      });

      _checkStatus().ignore();
    } catch (e) {
      _showMessage('Failed to stop KDF: $e');
    }
  }
```
