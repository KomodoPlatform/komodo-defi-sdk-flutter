import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_editor_flutter/json_editor_flutter.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_framework_example/kdf_operations/kdf_operations_server.dart';
import 'package:komodo_defi_framework_example/widgets/request_playground.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // (await SharedPreferences.getInstance()).clear();
  runApp(const MaterialApp(home: MyApp()));
}

class ConfigureDialog extends StatefulWidget {
  const ConfigureDialog({super.key});

  @override
  _ConfigureDialogState createState() => _ConfigureDialogState();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// Generate a random 32 character password for the RPC userpass
String _generateDefaultRpcPassword() =>
    SecurityUtils.generatePasswordSecure(32);

class _ConfigureDialogState extends State<ConfigureDialog> {
  String _selectedHostType = 'local';
  String _selectedProtocol = 'https';
  bool _exposeHttp = false;
  final TextEditingController _walletNameController = TextEditingController();
  final TextEditingController _walletPasswordController =
      TextEditingController();
  final TextEditingController _passphraseController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _awsRegionController = TextEditingController();
  final TextEditingController _awsAccessKeyController = TextEditingController();
  final TextEditingController _awsSecretKeyController = TextEditingController();
  final TextEditingController _awsInstanceTypeController =
      TextEditingController();
  final TextEditingController _rpcPasswordController = TextEditingController(
    text: _generateDefaultRpcPassword(),
  );

  void _hostTypeChanged(String? value) {
    if (value == null) {
      return;
    }

    setState(() {
      // If current is local and changed to anything else, clear the RPC password
      if (_selectedHostType == 'local' && value != 'local') {
        _rpcPasswordController.text = '';
      } else if (_selectedHostType != 'local' && value == 'local') {
        _rpcPasswordController.text = _generateDefaultRpcPassword();
      }

      _selectedHostType = value;
    });
  }

  bool _passwordVisible = false;
  void _togglePasswordVisibility() {
    setState(() => _passwordVisible = !_passwordVisible);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configure KDF'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 300,
          minHeight: 300,
          maxWidth: 300,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: _selectedHostType,
                onChanged: _hostTypeChanged,
                items: const [
                  DropdownMenuItem(value: 'local', child: Text('Local')),
                  DropdownMenuItem(
                    value: 'remote',
                    child: Text('Remote (LAN/Internet)'),
                  ),
                  DropdownMenuItem(
                    value: 'aws',
                    enabled: false,
                    child: Text('AWS (Unavailable)'),
                  ),
                  DropdownMenuItem(
                    value: 'digital-ocean',
                    enabled: false,
                    child: Text('Digital Ocean (Unavailable)'),
                  ),
                ],
              ),
              TextField(
                controller: _walletNameController,
                decoration: const InputDecoration(labelText: 'Wallet Name'),
              ),
              TextField(
                controller: _walletPasswordController,
                decoration: InputDecoration(
                  labelText: 'Wallet Password',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.remove_red_eye),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                obscureText: _passwordVisible,
              ),
              if (_selectedHostType != 'remote')
                TextField(
                  controller: _passphraseController,
                  decoration: const InputDecoration(
                    labelText: 'Passphrase/Seed (Optional)',
                  ),
                ),
              if (_selectedHostType == 'local' && kIsWeb) ...[
                CheckboxListTile(
                  value: _exposeHttp,
                  onChanged: (value) {
                    setState(() {
                      _exposeHttp = value!;
                    });
                  },
                  title: const Text('Expose WASM via HTTP'),
                  subtitle: const Text(
                    'Enable this to access the WASM instance through a REST API. '
                    'Accessible at http://localhost:3777',
                  ),
                ),
              ],
              if (_selectedHostType == 'remote') ...[
                DropdownButtonFormField<String>(
                  value: _selectedProtocol,
                  onChanged: (value) => _selectedProtocolChanged(value!),
                  decoration: const InputDecoration(labelText: 'Protocol'),
                  items: const [
                    DropdownMenuItem(value: 'http', child: Text('http')),
                    DropdownMenuItem(
                      value: 'https',
                      child: Text('https (Requires special configuration)'),
                    ),
                  ],
                ),
                TextField(
                  controller: _rpcPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'RPC Password (userpass)',
                  ),
                ),
                TextField(
                  controller: _ipController,
                  decoration: InputDecoration(
                    labelText: 'Host or IP Address',
                    hintText: 'e.g. 123.456.789.012 or example.com',
                    suffixIcon:
                        _selectedHostType == 'remote'
                            ? IconButton(
                              icon: const Icon(Icons.info_outline),
                              onPressed:
                                  () => showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text(
                                            'Remote Access Setup',
                                          ),
                                          content: SingleChildScrollView(
                                            child: SelectableText(
                                              _remoteAccessTooltipMessage(),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                  ),
                            )
                            : null,
                  ),
                ),
                TextField(
                  controller: _portController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Port'),
                ),
              ],
              if (_selectedHostType == 'aws') ...[
                TextField(
                  controller: _awsRegionController,
                  decoration: const InputDecoration(labelText: 'AWS Region'),
                ),
                TextField(
                  controller: _awsAccessKeyController,
                  decoration: const InputDecoration(
                    labelText: 'AWS Access Key',
                  ),
                ),
                TextField(
                  controller: _awsSecretKeyController,
                  decoration: const InputDecoration(
                    labelText: 'AWS Secret Key',
                  ),
                ),
                TextField(
                  controller: _awsInstanceTypeController,
                  decoration: const InputDecoration(labelText: 'Instance Type'),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await _saveConfiguration();
            IKdfHostConfig config;

            // Determine the host configuration.
            switch (_selectedHostType) {
              case 'remote':
                config = RemoteConfig(
                  rpcPassword: _rpcPasswordController.text,
                  ipAddress: _ipController.text,
                  port: int.parse(_portController.text),
                  https: _selectedProtocol == 'https',
                );
                break;
              case 'aws':
                config = AwsConfig(
                  rpcPassword: _rpcPasswordController.text,
                  region: _awsRegionController.text,
                  accessKey: _awsAccessKeyController.text,
                  secretKey: _awsSecretKeyController.text,
                  instanceType: _awsInstanceTypeController.text,
                  https: _selectedProtocol == 'https',
                );
                break;
              case 'local':
              default:
                config = LocalConfig(
                  rpcPassword: _rpcPasswordController.text,
                  https: _selectedProtocol == 'https',
                );
                break;
            }

            Navigator.of(context).pop({
              'config': config,
              'walletName': _walletNameController.text,
              'walletPassword': _walletPasswordController.text,
              'passphrase': _passphraseController.text,
              'hostType': _selectedHostType,
              'ipAddress': _ipController.text,
              'port': _portController.text,
              'protocol': _selectedProtocol,
              'exposeHttp': _exposeHttp,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _selectedProtocolChanged(String value) {
    if (value == 'http') {
      _showHttpWarning(context);
    }
    setState(() {
      _selectedProtocol = value;
    });
  }

  void _showHttpWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning: HTTP is not secure'),
          content: const Text(
            'You have selected HTTP, which is not secure as your RPC password will be sent in plain text, which can be intercepted by malicious actors. '
            'For remotely accessible KDF instances, it is recommended to use a strong (32+ character) RPC password and set the connection to HTTPS.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _remoteAccessTooltipMessage() {
    return '''
1. Setup a server to run KDF and ensure the necessary ports are exposed. Default is `7783`. This can easily be set up using our docker image: https://hub.docker.com/r/komodoofficial/komodo-defi-framework
2. (Optional) Generate a private and public key and set the paths as environment variables using `MM_CERT_PATH` and `MM_CERT_KEY_PATH` or add them to the launch parameter.
3. Set the following parameters in MM2.json or pass them as CLI parameters:
```json
"https": true,
"rpc_local_only": false,
"rpcip": "0.0.0.0",
```
4. If using Docker, run the container with the following comand:
```bash
docker run -p 7783:7783 -v "\$(pwd)":/app -w /app komodoofficial/komodo-defi-framework:dev-latest
```
''';
  }

  @override
  void initState() {
    super.initState();
    _loadSavedConfiguration();
  }

  Future<void> _loadSavedConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    // TODO: Fix. host type is stored in 'lastUsedConfig' key with the rest of the host config.
    String? savedHostType =
        prefs.getString('hostType') == null
            ? null
            : prefs.getString('lastUsedConfig') == null
            ? null
            : jsonDecode(prefs.getString('lastUsedConfig')!)['hostType'];
    String? savedIp = prefs.getString('ipAddress');
    String? savedWalletPassword = prefs.getString('walletPassword');
    String? savedPort = prefs.getString('port');
    String? savedProtocol = prefs.getString('protocol');
    String? savedAwsRegion = prefs.getString('awsRegion');
    String? savedAwsAccessKey = prefs.getString('awsAccessKey');
    String? savedAwsSecretKey = prefs.getString('awsSecretKey');
    String? savedAwsInstanceType = prefs.getString('awsInstanceType');
    String? savedRpcPassword = prefs.getString('rpcPassword'); // Add this line

    setState(() {
      _selectedHostType = savedHostType ?? 'local';
      _passphraseController.text = '';
      _walletPasswordController.text = savedWalletPassword ?? '';
      _ipController.text = savedIp ?? '';
      _portController.text = savedPort ?? '7783';
      _selectedProtocol = savedProtocol ?? 'https';
      _awsRegionController.text = savedAwsRegion ?? '';
      _awsAccessKeyController.text = savedAwsAccessKey ?? '';
      _awsSecretKeyController.text = savedAwsSecretKey ?? '';
      _awsInstanceTypeController.text = savedAwsInstanceType ?? '';
      _rpcPasswordController.text =
          savedRpcPassword ?? _generateDefaultRpcPassword();
    });
  }

  Future<void> _saveConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hostType', _selectedHostType);
    await prefs.setString('walletPassword', _walletPasswordController.text);
    await prefs.setString('ipAddress', _ipController.text);
    await prefs.setString('port', _portController.text);
    await prefs.setString('protocol', _selectedProtocol);
    await prefs.setString('awsRegion', _awsRegionController.text);
    await prefs.setString('awsAccessKey', _awsAccessKeyController.text);
    await prefs.setString('awsSecretKey', _awsSecretKeyController.text);
    await prefs.setString('awsInstanceType', _awsInstanceTypeController.text);
    await prefs.setString('rpcPassword', _rpcPasswordController.text);

    //! IMPORTANT: Replace SharedPreferences with a more secure solution before using this in production.
  }
}

class _MyAppState extends State<MyApp> {
  KomodoDefiFramework? _kdfFramework;
  String? _statusMessage;
  String? _version;
  bool _isRunning = false;
  IKdfHostConfig? _kdfHostConfig;
  final _logController = StreamController<String>.broadcast();
  final ScrollController _scrollController = ScrollController();
  final List<String> _logMessages = [];

  Map<String, dynamic> rpcInput = {
    'userpass': '********',
    'method': 'get_enabled_coins',
    'params': {},
  };

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _canInteract => _kdfFramework != null;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 18);
    const verticalSpacerSmall = SizedBox(height: 12);
    const horizontalSpacerSmall = SizedBox(width: 12);
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Komodo DeFi Framework Flutter SDK Example'),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.code),
                onPressed: () {
                  launchUrlString(
                    'https://github.com/KomodoPlatform/komodo-defi-sdk-flutter/tree/dev',
                  );
                },
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _configure,
                    label: const Text('Configure'),
                    icon: const Icon(Icons.settings),
                  ),
                  horizontalSpacerSmall,
                  FilledButton.icon(
                    onPressed: _isRunning || !_canInteract ? null : _startKdf,
                    label: const Text('Start KDF'),
                    icon: const Icon(Icons.play_arrow),
                  ),
                  horizontalSpacerSmall,
                  ElevatedButton.icon(
                    onPressed: _isRunning ? _stopKdf : null,
                    label: const Text('Stop KDF'),
                    icon: const Icon(Icons.stop),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  horizontalSpacerSmall,
                  OutlinedButton.icon(
                    onPressed: _canInteract ? _checkStatus : null,
                    label: const Text('Refresh Status'),
                    icon: const Icon(Icons.refresh),
                  ),
                  horizontalSpacerSmall,
                  OutlinedButton(
                    onPressed: _canInteract && _isRunning ? _executeRpc : null,
                    child: const Text('Execute RPC'),
                  ),
                ],
              ),
              verticalSpacerSmall,
              Text('Status: $_statusMessage', style: textStyle),
              verticalSpacerSmall,
              Text('Version: $_version', style: textStyle),
              verticalSpacerSmall,
              Text(
                'Host type: ${_kdfFramework?.operationsName ?? 'None selected.'}',
                style: textStyle,
              ),
              const Divider(),
              const Text('Logs:', style: textStyle),
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: StreamBuilder<String>(
                        stream: _logController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            _logMessages.add(snapshot.data!);

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(
                                  _scrollController.position.maxScrollExtent,
                                );
                              }
                            });
                          }

                          if (_logMessages.isEmpty) {
                            return const Text(
                              'No logs available.',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Courier',
                              ),
                            );
                          }

                          return Text(
                            _logMessages.join('\n'),
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontFamily: 'Courier',
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        endDrawer: SizedBox(
          width: 600,
          height: double.infinity,
          child: RequestPlayground(
            executeRequest: (rpcInput) async {
              if (_kdfFramework == null || !_isRunning) {
                _showMessage('KDF is not running.');
                throw Exception('KDF is not running.');
              }
              return (await _kdfFramework!.executeRpc(rpcInput)).toString();
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logController.close();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (_kdfFramework == null) {
      _showMessage('Please configure the framework first.');
      return;
    }

    final status = await _kdfFramework!.kdfMainStatus();

    final version =
        MainStatus.rpcIsUp == status ? await _kdfFramework!.version() : 'N/A';
    setState(() {
      _isRunning = status == MainStatus.rpcIsUp;
      _statusMessage = status.toString();
      _version = version;
    });
  }

  void _configure() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ConfigureDialog(),
    );

    if (result == null) {
      return;
    }

    final IKdfHostConfig config = result['config'];
    final String walletName = result['walletName'];
    final String walletPassword = result['walletPassword'];
    final String passphrase = result['passphrase'];
    final bool exposeHttp = result['exposeHttp'];

    setState(() {
      _kdfHostConfig = config;
      _kdfFramework =
          exposeHttp && !kIsWeb
              ? KomodoDefiFramework.createWithOperations(
                hostConfig: config,
                kdfOperations: KdfHttpServerOperations(config as LocalConfig),
                externalLogger: _logController.add,
              )
              : KomodoDefiFramework.create(
                hostConfig: config,
                externalLogger: _logController.add,
              );
    });

    await _saveConfig(config);
    await _saveStartupData(walletName, walletPassword, passphrase);
  }

  void _startHttpServer() {
    if (_kdfFramework == null) {
      _showMessage('KDF is not configured.');
      return;
    }

    // Start the HTTP server with the KDF instance
    // final KdfServer kdfServer = KdfServer(_kdfFramework!.operations);
    // kdfServer.start();
  }

  void _executeRpc() async {
    if (_scaffoldKey.currentState != null) {
      return _scaffoldKey.currentState?.openEndDrawer();
    }

    if (_kdfFramework == null || !_isRunning) {
      _showMessage('KDF is not running.');
      return;
    }

    String updatedInput = jsonEncode(rpcInput);

    final didSave = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Execute RPC'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 500,
                  width: 500,
                  child: JsonEditor(
                    json: jsonEncode({
                      'userpass': '********',
                      'method': 'get_enabled_coins',
                    }),
                    onChanged: (json) => updatedInput = json,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                label: const Text('Execute'),
                icon: const Icon(Icons.play_arrow_rounded),
              ),
            ],
          ),
    );

    if (didSave == false || didSave == null) {
      return;
    }
    final decoded = jsonDecode(updatedInput);

    rpcInput = decoded;

    await _saveData();

    final rpcResponse = await _kdfFramework!.executeRpc(decoded);

    _showMessage('RPC Response: ${rpcResponse.toString()}');
  }

  Future<void> _saveStartupData(
    String walletName,
    String walletPassword,
    String passphrase,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('walletName', walletName);
    await prefs.setString('walletPassword', walletPassword);
    await prefs.setString('passphrase', passphrase);
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedRpcInput = prefs.getString('rpcInput');
    String? savedConfig = prefs.getString('lastUsedConfig');

    if (savedRpcInput != null) {
      rpcInput = jsonDecode(savedRpcInput);
    }

    if (savedConfig != null) {
      final configMap = jsonDecode(savedConfig) as Map<String, dynamic>;
      _kdfHostConfig = _configFromMap(configMap);
      setState(() {
        _kdfFramework = KomodoDefiFramework.create(
          hostConfig: _kdfHostConfig!,
          externalLogger: _logController.add,
        );
      });
      _checkStatus();
    }
  }

  IKdfHostConfig _configFromMap(Map<String, dynamic> map) {
    switch (map['hostType']) {
      case 'local':
        return LocalConfig(
          rpcPassword: map['rpcPassword'],
          https: map['https'],
        );
      case 'remote':
        return RemoteConfig(
          rpcPassword: map['rpcPassword'],
          ipAddress: map['ipAddress'],
          port: map['port'],
          https: map['https'],
        );
      case 'aws':
        return AwsConfig(
          rpcPassword: map['rpcPassword'],
          region: map['region'],
          accessKey: map['accessKey'],
          secretKey: map['secretKey'],
          instanceType: map['instanceType'],
          https: map['https'],
        );
      default:
        throw Exception('Invalid/unsupported host type: ${map['hostType']}');
    }
  }

  Future<void> _saveConfig(IKdfHostConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'lastUsedConfig',
      jsonEncode(config.getConnectionParams()),
    );
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rpcInput', jsonEncode(rpcInput));
  }

  void _showMessage(String message) {
    _scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _startKdf() async {
    _statusMessage = null;

    if (_kdfFramework == null || _kdfHostConfig == null) {
      _showMessage('Please configure the framework first.');
      return;
    }

    // Load saved startup data
    final prefs = await SharedPreferences.getInstance();
    final walletName = prefs.getString('walletName') ?? '';
    final walletPassword = prefs.getString('walletPassword') ?? '';
    final passphrase = prefs.getString('passphrase');

    try {
      final KdfStartupConfig startupConfig =
          await KdfStartupConfig.generateWithDefaults(
            enableHd: false, // TODO: Add as checkbox
            walletName: walletName,
            walletPassword:
                walletPassword, // This is the wallet account password
            rpcPassword: _kdfHostConfig!.rpcPassword, // RPC password
            seed:
                (passphrase?.isNotEmpty ?? false)
                    ? passphrase
                    : null, // Optional passphrase
          );

      final result = await _kdfFramework!.startKdf(startupConfig);

      setState(() {
        _statusMessage = 'KDF running: $result';
        _isRunning = result.isStartingOrAlreadyRunning();
      });

      if (!result.isStartingOrAlreadyRunning()) {
        _showMessage('Failed to start KDF: $result');
      }
    } catch (e) {
      _showMessage('Failed to start KDF: $e');
    }
  }

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
}
