import 'package:hive_flutter/hive_flutter.dart';
import 'package:komodo_coin_updates/src/persistence/persisted_types.dart';

import 'models/coin_info.dart';
import 'models/models.dart';

class KomodoCoinUpdater {
  static Future<void> ensureInitialized(String appFolder) async {
    await Hive.initFlutter(appFolder);
    initializeAdapters();
  }

  static void ensureInitializedIsolate(String fullAppFolderPath) {
    Hive.init(fullAppFolderPath);
    initializeAdapters();
  }

  static void initializeAdapters() {
    Hive.registerAdapter(AddressFormatAdapter());
    Hive.registerAdapter(CheckPointBlockAdapter());
    Hive.registerAdapter(CoinAdapter());
    Hive.registerAdapter(CoinConfigAdapter());
    Hive.registerAdapter(CoinInfoAdapter());
    Hive.registerAdapter(ConsensusParamsAdapter());
    Hive.registerAdapter(ContactAdapter());
    Hive.registerAdapter(ElectrumAdapter());
    Hive.registerAdapter(LinksAdapter());
    Hive.registerAdapter(NodeAdapter());
    Hive.registerAdapter(PersistedStringAdapter());
    Hive.registerAdapter(ProtocolAdapter());
    Hive.registerAdapter(ProtocolDataAdapter());
    Hive.registerAdapter(RpcUrlAdapter());
  }
}
