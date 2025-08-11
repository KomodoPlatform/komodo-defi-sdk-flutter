// auth_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/auth/auth_bloc.dart';
import 'package:kdf_sdk_example/screens/asset_page.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/instance_view.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/kdf_instance_state.dart';

import 'package:komodo_defi_types/komodo_defi_types.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    required this.statusMessage,
    required this.instanceState,
    super.key,
  });

  final String statusMessage;
  final KdfInstanceState instanceState;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final TextEditingController _searchController;
  List<Asset> _filteredAssets = [];
  Map<AssetId, Asset>? _allAssets;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterAssets);
    _initializeKdf();
  }

  Future<void> _initializeKdf() async {
    final sdk = widget.instanceState.sdk;
    _allAssets = sdk.assets.available;
    _filterAssets();
  }

  void _filterAssets() {
    final query = _searchController.text.toLowerCase();
    final assets = _allAssets;
    if (assets == null) return;

    setState(() {
      _filteredAssets =
          assets.values.where((v) {
            final asset = v.id.name;
            final id = v.id.id;
            return asset.toLowerCase().contains(query) ||
                id.toLowerCase().contains(query);
          }).toList();
    });
  }

  Future<void> _onNavigateToAsset(BuildContext context, Asset asset) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (context) => RepositoryProvider.value(
              value: widget.instanceState.sdk,
              child: AssetPage(asset),
            ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(sdk: widget.instanceState.sdk),
      child: InstanceView(
        instance: widget.instanceState,
        state: 'auth',
        statusMessage: widget.statusMessage,
        searchController: _searchController,
        filteredAssets: _filteredAssets,
        onNavigateToAsset: (asset) => _onNavigateToAsset(context, asset),
      ),
    );
  }
}
