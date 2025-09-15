import 'package:hive_ce/hive.dart';
import 'package:komodo_cex_market_data/src/models/sparkline_data.dart';

/// Generates Hive adapters for all data models
///
/// This file uses the new GenerateAdapters annotation approach from Hive CE
/// to automatically generate type adapters for our data models.
@GenerateAdapters([AdapterSpec<SparklineData>()])
// The generated file will be created by build_runner
part 'hive_adapters.g.dart';

/// Registers all Hive adapters
///
/// Call this function before opening any Hive boxes to ensure
/// all type adapters are properly registered.
void registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(SparklineDataAdapter());
  }
}
