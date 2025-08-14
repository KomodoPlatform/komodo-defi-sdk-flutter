// Lightweight registrar for manual adapters

import 'package:hive_ce/hive.dart';
import 'package:komodo_coin_updates/hive/hive_adapters.dart';

extension HiveRegistrar on HiveInterface {
  void registerAdapters() {
    registerAdapter(AssetAdapter());
  }
}

extension IsolatedHiveRegistrar on IsolatedHiveInterface {
  void registerAdapters() {
    registerAdapter(AssetAdapter());
  }
}
