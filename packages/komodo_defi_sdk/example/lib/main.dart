import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _komodoDefiSdk.initialize();
  runApp(const MaterialApp(home: Scaffold(body: KomodoApp())));
}

final KomodoDefiSdk _komodoDefiSdk = KomodoDefiSdk();

class KomodoApp extends StatefulWidget {
  const KomodoApp({super.key});

  @override
  _KomodoAppState createState() => _KomodoAppState();
}

class _KomodoAppState extends State<KomodoApp> {
  KdfUser? _currentUser;
  String _statusMessage = 'Not signed in';
  String? _mnemonic;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<KdfUser> _knownUsers = [];

  @override
  void initState() {
    super.initState();
    _komodoDefiSdk.auth.authStateChanges.listen((user) {
      setState(() {
        _currentUser = user;
        _statusMessage =
            user != null ? 'Signed in as ${user.walletName}' : 'Not signed in';
      });
    });
    _fetchKnownUsers();

    _refreshUsersTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchKnownUsers(),
    );
  }

  late Timer? _refreshUsersTimer;

  Future<void> _fetchKnownUsers() async {
    try {
      final users = await _komodoDefiSdk.auth.getUsers();
      setState(() {
        _knownUsers = users;
      });
    } catch (e) {
      print('Error fetching known users: $e');
    }
  }

  Future<void> _signIn(String walletName, String password) async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    try {
      final user = await _komodoDefiSdk.auth
          .signIn(walletName: walletName, password: password);
      setState(() {
        _currentUser = user;
        _statusMessage = 'Signed in as ${_currentUser?.walletName}';
      });
    } on AuthException catch (e) {
      setState(() {
        _statusMessage = 'Auth Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  Future<void> _register(
    String walletName,
    String password, {
    Mnemonic? mnemonic,
  }) async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    try {
      final user = await _komodoDefiSdk.auth.register(
        walletName: walletName,
        password: password,
        mnemonic: mnemonic,
      );
      setState(() {
        _currentUser = user;
        _statusMessage =
            'Registered and signed in as ${_currentUser?.walletName}';
      });
    } on AuthException catch (e) {
      setState(() {
        _statusMessage = 'Registration Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _komodoDefiSdk.auth.signOut();
      setState(() {
        _currentUser = null;
        _statusMessage = 'Signed out';
        _mnemonic = null;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error signing out: $e';
      });
    }
  }

  Future<void> _getMnemonic({required bool encrypted}) async {
    try {
      final mnemonic = encrypted
          ? await _komodoDefiSdk.auth.getMnemonicEncrypted()
          : await _komodoDefiSdk.auth.getMnemonicPlainText(_password);

      setState(() {
        _mnemonic = mnemonic.toJson().toJsonString();
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error fetching mnemonic: $e';
      });
    }
  }

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_statusMessage),
              const SizedBox(height: 16),
              if (_currentUser == null) ...[
                _buildKnownUsersList(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _walletNameController,
                  decoration: const InputDecoration(labelText: 'Wallet Name'),
                  validator: notEmptyValidator,
                ),
                TextFormField(
                  controller: _passwordController,
                  validator: notEmptyValidator,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton.tonal(
                      onPressed: () => _signIn(_walletName, _password),
                      child: const Text('Sign In'),
                    ),
                    FilledButton(
                      onPressed: () => _showSeedDialog(context),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ] else
                Column(
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _signOut,
                      label: const Text('Sign Out'),
                      icon: const Icon(Icons.logout),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () => _getMnemonic(encrypted: false),
                          child: const Text('Get Plaintext Mnemonic'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () => _getMnemonic(encrypted: true),
                          child: const Text('Get Encrypted Mnemonic'),
                        ),
                      ],
                    ),
                    if (_mnemonic != null) ...[
                      const SizedBox(height: 16),
                      Text('Mnemonic: $_mnemonic'),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // bool isMnemonicEncrypted = false;

  Future<void> _showSeedDialog(BuildContext context) async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }
    final mnemonicController = TextEditingController();
    bool isMnemonicEncrypted = false;
    String? errorMessage;

    final didProvideImport = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Import Existing Seed?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Do you have an existing seed you would like to import? '
                    'Enter it below or leave empty to generate a new seed.',
                  ),
                  const SizedBox(height: 16),
                  if (errorMessage != null) ...[
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Example of a valid encrypted format:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      EncryptedMnemonicData.encryptedDataExample.toString(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    minLines: isMnemonicEncrypted ? 3 : 1,
                    maxLines: isMnemonicEncrypted ? 4 : 1,
                    controller: mnemonicController,
                    obscureText: !isMnemonicEncrypted,
                    decoration: const InputDecoration(
                      hintText: 'Enter your seed or leave empty for a new one',
                    ),
                    // validator: (input) =>
                    //     !isMnemonicEncrypted || (input?.isEmpty ?? true)
                    //         ? null
                    //         : validateEncryptedMnemonic(
                    //             input,
                    //             isEncrypted: isMnemonicEncrypted,
                    //           ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Encrypted Seed?'),
                    value: isMnemonicEncrypted,
                    onChanged: (value) {
                      setState(() {
                        isMnemonicEncrypted = value;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FilledButton(
                  child: const Text('Register'),
                  onPressed: () {
                    Mnemonic? mnemonic;
                    if (mnemonicController.text.isNotEmpty) {
                      if (isMnemonicEncrypted) {
                        final parsedMnemonic = EncryptedMnemonicData.tryParse(
                          tryParseJson(mnemonicController.text) ?? {},
                        );

                        if (parsedMnemonic == null) {
                          setState(() {
                            errorMessage =
                                'Invalid encrypted mnemonic format. Please ensure it is correctly formatted.';
                          });
                          return;
                        } else {
                          mnemonic = Mnemonic.encrypted(parsedMnemonic);
                        }
                      } else {
                        mnemonic = Mnemonic.plaintext(mnemonicController.text);
                      }
                    }
                    Navigator.of(context).pop(true);

                    // Call the register method with the mnemonic
                    _register(
                      _walletName,
                      _password,
                      mnemonic: mnemonic,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (didProvideImport != null && didProvideImport) {
      await _register(
        _walletName,
        _password,
      );
    }
  }

  String get _walletName => _walletNameController.text;
  String get _password => _passwordController.text;

  Widget _buildKnownUsersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Known Wallets:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _knownUsers.map((user) {
            return ElevatedButton(
              onPressed: () {
                setState(() {
                  _walletNameController.text = user.walletName;
                });
              },
              child: Text(user.walletName),
            );
          }).toList(),
        ),
      ],
    );
  }

  String? notEmptyValidator(String? input, {String? fieldName}) {
    if (input == null || input.isEmpty) {
      return 'Please enter a ${fieldName ?? 'value'}.';
    }
    return null;
  }

  String? validateEncryptedMnemonic(String? input, {bool isEncrypted = false}) {
    if (input == null || input.isEmpty) {
      return 'Mnemonic cannot be empty';
    }

    if (isEncrypted) {
      final maybeJson = tryParseJson(input);
      if (maybeJson == null) {
        return 'Invalid JSON format. Please ensure it is correctly formatted.';
      }

      final parsedMnemonic = EncryptedMnemonicData.tryParse(maybeJson);

      if (parsedMnemonic == null) {
        return 'Invalid encrypted mnemonic format. Please ensure it is correctly formatted.\nExample: ${EncryptedMnemonicData.encryptedDataExample}';
      }
    }

    return null;
  }

  final TextEditingController _walletNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _refreshUsersTimer?.cancel();
    super.dispose();
  }
}
