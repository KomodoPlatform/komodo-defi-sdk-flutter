#ifndef FLUTTER_PLUGIN_MM2_PLUGIN_H_
#define FLUTTER_PLUGIN_MM2_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#define MM2_TYPE_PLUGIN (mm2_plugin_get_type())

G_DECLARE_FINAL_TYPE(Mm2Plugin, mm2_plugin, MM2, PLUGIN, GObject)

void mm2_plugin_register_with_registrar(FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_MM2_PLUGIN_H_