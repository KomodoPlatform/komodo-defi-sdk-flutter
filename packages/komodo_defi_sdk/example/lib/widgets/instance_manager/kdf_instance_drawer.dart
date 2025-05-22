import 'package:flutter/material.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/kdf_instance_state.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_remote/komodo_defi_remote.dart';

class KdfInstanceDrawer extends StatefulWidget {
  const KdfInstanceDrawer({super.key});

  @override
  State<KdfInstanceDrawer> createState() => _KdfInstanceDrawerState();
}

class _KdfInstanceDrawerState extends State<KdfInstanceDrawer> {
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _rpcPasswordController = TextEditingController();
  final _doTokenController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _rpcPasswordController.dispose();
    _doTokenController.dispose();
    super.dispose();
  }

  Future<void> _showAddInstanceDialog() async {
    final manager = KdfInstanceManagerProvider.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add KDF Instance'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Instance Name',
                    hintText: 'Enter a name for this instance',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    labelText: 'Host',
                    hintText: 'Enter host address',
                  ),
                ),
                TextFormField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: 'Port',
                    hintText: 'Enter port number',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _rpcPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'RPC Password',
                    hintText: 'Enter RPC password',
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Add Instance'),
              ),
            ],
          ),
    );

    if (result ?? false) {
      final config = RemoteConfig(
        rpcPassword: _rpcPasswordController.text,
        ipAddress: _hostController.text,
        port: int.tryParse(_portController.text) ?? 7783,
        https: false, //TODO! HTTPS support
      );

      final sdk = KomodoDefiSdk(
        host: config,
        config: const KomodoDefiSdkConfig(),
      );

      try {
        await manager.registerInstance(
          _nameController.text,
          const KomodoDefiSdkConfig(),
          sdk,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Instance added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add instance: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _deployDigitalOcean() async {
    final manager = KdfInstanceManagerProvider.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('DigitalOcean Deployment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _doTokenController,
                  decoration: const InputDecoration(labelText: 'API Token'),
                ),
                TextField(
                  controller: _rpcPasswordController,
                  decoration: const InputDecoration(labelText: 'RPC Password'),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Deploy'),
              ),
            ],
          ),
    );

    if (result != true) return;

    final deploymentManager = RemoteDeploymentManager();
    final provider = DigitalOceanServerProvider(
      apiToken: _doTokenController.text,
    );

    final instance = await deploymentManager.deployNew(provider: provider);

    final sdk = KomodoDefiSdk(
      host: RemoteConfig(
        rpcPassword: _rpcPasswordController.text,
        ipAddress: instance.ip ?? '',
        port: 7783,
        https: false,
      ),
      config: const KomodoDefiSdkConfig(),
    );

    await manager.registerInstance(
      'DO ${instance.id}',
      const KomodoDefiSdkConfig(),
      sdk,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('DigitalOcean deployment started')),
      );
    }
  }

  String? _selectedInstanceName;
  KdfInstanceState? get _selectedInstance =>
      _selectedInstanceName == null
          ? null
          : KdfInstanceManagerProvider.of(
            context,
          ).getInstance(_selectedInstanceName!);

  @override
  Widget build(BuildContext context) {
    final manager = KdfInstanceManagerProvider.of(context);
    final instances = manager.instances;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'KDF Instances',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.cloud),
                      onPressed: _deployDigitalOcean,
                      tooltip: 'Deploy to DigitalOcean',
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _showAddInstanceDialog,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: instances.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final instance = instances.values.elementAt(index);
                final isActive = instance.name == _selectedInstance?.name;

                return Card(
                  color:
                      isActive
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                  child: ListTile(
                    title: Text(instance.name),
                    subtitle: Text(
                      instance.isConnected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        color:
                            instance.isConnected
                                ? Colors.green
                                : Theme.of(context).colorScheme.error,
                      ),
                    ),
                    selected: isActive,
                    onTap:
                        () => setState(
                          () => _selectedInstanceName = instance.name,
                        ),
                    trailing: PopupMenuButton(
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              child: const Text('Remove'),
                              onTap:
                                  () => manager.removeInstance(instance.name),
                            ),
                          ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
