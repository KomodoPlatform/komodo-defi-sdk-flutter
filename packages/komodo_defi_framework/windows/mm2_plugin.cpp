#include "include/mm2_plugin/mm2_plugin.h"

#include <flutter/plugin_registrar_windows.h>

namespace
{

    class Mm2Plugin : public flutter::Plugin
    {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

        Mm2Plugin();

        virtual ~Mm2Plugin();
    };

    void Mm2Plugin::RegisterWithRegistrar(
        flutter::PluginRegistrarWindows *registrar)
    {
        auto plugin = std::make_unique<Mm2Plugin>();
        registrar->AddPlugin(std::move(plugin));
    }

    Mm2Plugin::Mm2Plugin() {}

    Mm2Plugin::~Mm2Plugin() {}

} // namespace

void Mm2PluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
    Mm2Plugin::RegisterWithRegistrar(
        flutter::PluginRegistrarManager::GetInstance()
            ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}