import 'package:hive_ce/hive.dart';
import 'package:komodo_defi_sdk/src/activation_config/activation_config_service.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Generates Hive adapters for activation config data models
///
/// This file uses the new GenerateAdapters annotation approach from Hive CE
/// to automatically generate type adapters for our data models.
@GenerateAdapters([AdapterSpec<HiveActivationConfigWrapper>()])
// The generated file will be created by build_runner
part 'hive_adapters.g.dart';

/// Registers all Hive adapters for activation config
///
/// Call this function before opening any Hive boxes to ensure
/// all type adapters are properly registered.
void registerActivationConfigAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(HiveActivationConfigWrapperAdapter());
  }
}
