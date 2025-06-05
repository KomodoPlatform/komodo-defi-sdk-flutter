import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_wasm.dart';

class KomodoDefiFrameworkWeb {
  static void registerWith(Registrar registrar) {
    KdfPluginWeb.registerWith(registrar);

    // Register JS files to be included in the build
  }
}
