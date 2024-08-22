import 'package:flutter/material.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

void main() async {
  await _komodoDefiSdk.initialize();
  runApp(const KomodoApp());
}

final KomodoDefiSdk _komodoDefiSdk = KomodoDefiSdk();

class KomodoApp extends StatefulWidget {
  const KomodoApp({super.key});

  @override
  _KomodoAppState createState() => _KomodoAppState();
}

class _KomodoAppState extends State<KomodoApp> {
  final KomodoDefiSdk _komodoDefiSdk = KomodoDefiSdk();

  KdfUser? _currentUser;
  String _statusMessage = 'Not signed in';
  String? _mnemonic;

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
  }

  Future<void> _signIn(String walletName, String password) async {
    try {
      final user = await _komodoDefiSdk.auth
          .signIn(walletName: walletName, password: password);
      setState(() {
        _currentUser = user;
        _statusMessage = 'Signed in as ${_currentUser?.walletName}';
      });
    } on AuthException catch (e) {
      // Handle specific auth errors
      setState(() {
        _statusMessage = 'Error: ${e.message}';
      });
    } catch (e) {
      // Handle any other unexpected errors
      setState(() {
        _statusMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  Future<void> _signOut() async {
    await _komodoDefiSdk.auth.signOut();
    setState(() {
      _currentUser = null;
      _statusMessage = 'Signed out';
    });
  }

  Future<void> _getMnemonic({required bool encrypted}) async {
    try {
      final mnemonic = await _komodoDefiSdk.auth.getMnemonic(
        encrypted: encrypted,
        walletPassword: _password,
      );
      setState(() {
        _mnemonic = mnemonic;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error fetching mnemonic: $e';
      });
    }
  }

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Komodo Defi Local Auth')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_statusMessage),
              const SizedBox(height: 16),
              if (_currentUser == null)
                Column(
                  children: [
                    TextFormField(
                      initialValue: 'My first wallet',
                      decoration:
                          const InputDecoration(labelText: 'Wallet Name'),
                      onChanged: (value) => _walletName = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => _obscureText = !_obscureText);
                          },
                        ),
                      ),
                      onChanged: (value) => _password = value,
                      obscureText: _obscureText,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _signIn(_walletName, _password),
                      child: const Text('Sign In'),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _signOut,
                      child: const Text('Sign Out'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _getMnemonic(encrypted: false),
                      child: const Text('Get Plaintext Mnemonic'),
                    ),
                    ElevatedButton(
                      onPressed: () => _getMnemonic(encrypted: true),
                      child: const Text('Get Encrypted Mnemonic'),
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

  // Track user inputs for walletName and password
  String _walletName = '';
  String _password = '';
}
