import 'dart:async';
import 'dart:convert';

import 'package:bip39/bip39.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_editor_flutter/json_editor_flutter.dart';
import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_framework_example/widgets/request_playground.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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
String _generateDefaultRpcPassword() => SecurityUtils.securePassword(32);

class _ConfigureDialogState extends State<ConfigureDialog> {
  String _selectedHostType = 'local';
  String _selectedProtocol = 'https';
  final TextEditingController _passphraseController = TextEditingController();
  final TextEditingController _userpassController =
      TextEditingController(text: _generateDefaultRpcPassword());
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _awsRegionController = TextEditingController();
  final TextEditingController _awsAccessKeyController = TextEditingController();
  final TextEditingController _awsSecretKeyController = TextEditingController();
  final TextEditingController _awsInstanceTypeController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configure KDF'),
      content: ConstrainedBox(
        constraints:
            const BoxConstraints(minWidth: 300, minHeight: 300, maxWidth: 300),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: _selectedHostType,
                onChanged: (value) {
                  setState(() {
                    _selectedHostType = value!;
                  });
                },
                items: const [
                  DropdownMenuItem(
                    value: 'local',
                    child: Text('Local'),
                  ),
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
              if (_selectedHostType != 'remote') ...[
                TextField(
                  controller: _passphraseController,
                  maxLines: 6,
                  minLines: 1,
                  decoration: const InputDecoration(
                    labelText: 'Seed',
                  ),
                ),
              ],
              if (_selectedHostType == 'remote') ...[
                DropdownButtonFormField<String>(
                  value: _selectedProtocol,
                  onChanged: (value) {
                    setState(() {
                      _selectedProtocol = value!;
                      if (_selectedProtocol == 'http') {
                        _showHttpWarning(context);
                      }
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Protocol',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'http',
                      child: Text('http'),
                    ),
                    DropdownMenuItem(
                      value: 'https',
                      child: Text('https (Requires special configuration)'),
                    ),
                  ],
                ),
                TextField(
                  controller: _userpassController,
                  decoration: const InputDecoration(
                    labelText: 'RPC Password (userpass)',
                  ),
                ),
                TextField(
                  controller: _ipController,
                  decoration: InputDecoration(
                    labelText: 'Host or IP Address',
                    hintText: 'e.g. 123.456.789.012 or example.com',
                    suffixIcon: _selectedHostType == 'remote'
                        ? IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Remote Access Setup'),
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Port',
                  ),
                ),
              ],
              if (_selectedHostType == 'aws') ...[
                TextField(
                  controller: _awsRegionController,
                  decoration: const InputDecoration(
                    labelText: 'AWS Region',
                  ),
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
                  decoration: const InputDecoration(
                    labelText: 'Instance Type',
                  ),
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
            KdfConfig config;
            await _saveConfiguration();
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
            Navigator.of(context).pop(
              {'config': config, 'passphrase': _passphraseController.text},
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _showHttpWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning: HTTP is not secure'),
          content: const Text(
              'You have selected HTTP, which is not secure as your RPC password will be sent in plain text, which can be intercepted by malicious actors. '
              'For remotely accessible KDF instances, it is recommended to use a strong (32+ character) RPC password and set the connection to HTTPS.'),
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
    String? savedHostType = prefs.getString('hostType');
    String? savedUserpass = prefs.getString('userpass');
    String? savedIp = prefs.getString('ipAddress');
    String? savedPort = prefs.getString('port');
    String? savedProtocol = prefs.getString('protocol');
    String? savedAwsRegion = prefs.getString('awsRegion');
    String? savedAwsAccessKey = prefs.getString('awsAccessKey');
    String? savedAwsSecretKey = prefs.getString('awsSecretKey');
    String? savedAwsInstanceType = prefs.getString('awsInstanceType');

    setState(() {
      _selectedHostType = savedHostType ?? 'local';
      _passphraseController.text = generateMnemonic();
      _userpassController.text = savedUserpass ?? _generateDefaultRpcPassword();
      _ipController.text = savedIp ?? '';
      _portController.text = savedPort ?? '7783';
      _selectedProtocol = savedProtocol ?? 'https';
      _awsRegionController.text = savedAwsRegion ?? '';
      _awsAccessKeyController.text = savedAwsAccessKey ?? '';
      _awsSecretKeyController.text = savedAwsSecretKey ?? '';
      _awsInstanceTypeController.text = savedAwsInstanceType ?? '';
    });
  }

  Future<void> _saveConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hostType', _selectedHostType);
    await prefs.setString('userpass', _userpassController.text);
    await prefs.setString('ipAddress', _ipController.text);
    await prefs.setString('port', _portController.text);
    await prefs.setString('protocol', _selectedProtocol);
    await prefs.setString('awsRegion', _awsRegionController.text);
    await prefs.setString('awsAccessKey', _awsAccessKeyController.text);
    await prefs.setString('awsSecretKey', _awsSecretKeyController.text);
    await prefs.setString('awsInstanceType', _awsInstanceTypeController.text);

    //! IMPORTANT: Replace SharedPreferences with a more secure solution before using this in production.
  }
}

class _MyAppState extends State<MyApp> {
  KomodoDefiFramework? _kdfFramework;
  String? _statusMessage;
  String? _version;
  bool _isRunning = false;
  String? _passphrase; // Add this line
  final _logController = StreamController<String>.broadcast();
  final ScrollController _scrollController = ScrollController();
  final List<String> _logMessages = []; // List to store log messages

  Map<String, dynamic> rpcInput = {
    'userpass': '********',
    'method': 'get_enabled_coins',
    'params': {},
  };

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // TODO: More specific name
  bool get _canInteract => _kdfFramework != null;

  // Open end drawer on start
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
              // Button to the project's GitHub repository
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
                    onPressed:
                        _isRunning || !_canInteract || _passphrase == null
                            ? null
                            : () => _startKdf(
                                  _passphrase!,
                                ), // Pass the stored passphrase
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

  KdfConfig _configFromMap(Map<String, dynamic> map) {
    switch (map['hostType']) {
      case 'local':
        return LocalConfig(userpass: map['userpass']);
      case 'remote':
        return RemoteConfig(
          userpass: map['userpass'],
          ipAddress: map['ipAddress'],
          port: map['port'],
        );
      case 'aws':
        return AwsConfig(
          userpass: map['userpass'],
          region: map['region'],
          accessKey: map['accessKey'],
          secretKey: map['secretKey'],
          instanceType: map['instanceType'],
        );
      default:
        throw Exception('Invalid/unsupported host type: ${map['hostType']}');
    }
  }

  Map<String, dynamic> _configToMap(KdfConfig config) {
    if (config is RemoteConfig) {
      return {
        'hostType': config.hostType,
        'userpass': config.userpass,
        'ipAddress': config.ipAddress,
        'port': config.port,
      };
    } else if (config is AwsConfig) {
      return {
        'hostType': config.hostType,
        'userpass': config.userpass,
        'region': config.region,
        'accessKey': config.accessKey,
        'secretKey': config.secretKey,
        'instanceType': config.instanceType,
      };
    } else if (config is LocalConfig) {
      return {
        'hostType': config.hostType,
        'userpass': config.userpass,
      };
    } else {
      return {};
    }
  }

  void _configure() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ConfigureDialog(),
    );

    if (result == null) {
      return;
    }

    setState(() => _kdfFramework = null);

    final KdfConfig config = result['config'];
    final String passphrase = result['passphrase'];

    setState(() {
      _kdfFramework = KomodoDefiFramework.create(
        config: config,
        externalLogger: _logController.add,
      );
      _passphrase = passphrase;
    });

    await _saveConfig(config);
  }

  void _executeRpc() async {
    // For now, we can hide this feature since it's a bit redundant now that
    // we have the RequestPlayground widget.

    // Open the RequestPlayground widget instead
    if (_scaffoldKey.currentState != null) {
      return _scaffoldKey.currentState?.openEndDrawer();
    }

    // ignore: dead_code
    if (_kdfFramework == null || !_isRunning) {
      _showMessage('KDF is not running.');
      return;
    }

    String updatedInput = jsonEncode(rpcInput);

    final didSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Execute RPC'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 500,
              width: 500,
              child: JsonEditor(
                json: jsonEncode(
                  {
                    'userpass': '********',
                    'method': 'get_enabled_coins',
                  },
                ),
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

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedRpcInput = prefs.getString('rpcInput');
    String? savedConfig = prefs.getString('lastUsedConfig');

    if (savedRpcInput != null) {
      rpcInput = jsonDecode(savedRpcInput);
    }

    if (savedConfig != null) {
      final configMap = jsonDecode(savedConfig) as Map<String, dynamic>;
      final config = _configFromMap(configMap);
      setState(() {
        _kdfFramework = KomodoDefiFramework.create(
          config: config,
          externalLogger: _logController.add,
        );
      });
      _checkStatus();
    }
  }

  Future<void> _saveConfig(KdfConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastUsedConfig', jsonEncode(_configToMap(config)));

    //! IMPORTANT: Replace SharedPreferences with a more secure solution before using this in production.
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rpcInput', jsonEncode(rpcInput));

    //! IMPORTANT: Replace SharedPreferences with a more secure solution before using this in production.
  }

  void _showMessage(String message) {
    _scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
