//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <device_manager/device_manager_plugin.h>
#include <keypress_simulator_windows/keypress_simulator_windows_plugin_c_api.h>
#include <universal_ble/universal_ble_plugin_c_api.h>
#include <url_launcher_windows/url_launcher_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  DeviceManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DeviceManagerPlugin"));
  KeypressSimulatorWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("KeypressSimulatorWindowsPluginCApi"));
  UniversalBlePluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UniversalBlePluginCApi"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
}
