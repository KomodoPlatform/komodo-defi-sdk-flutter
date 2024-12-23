#include <flutter_linux/flutter_linux.h>

#include "mm2_plugin.h"

struct _Mm2Plugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(Mm2Plugin, mm2_plugin, g_object_get_type())

static void mm2_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(mm2_plugin_parent_class)->dispose(object);
}

static void mm2_plugin_class_init(Mm2PluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = mm2_plugin_dispose;
}

static void mm2_plugin_init(Mm2Plugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  // Handle method calls here
}

void mm2_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  Mm2Plugin* plugin = MM2_PLUGIN(
      g_object_new(mm2_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "mm2",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}