#include "include/all_paystack_payments/all_paystack_payments_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "all_paystack_payments_plugin.h"

void AllPaystackPaymentsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  all_paystack_payments::AllPaystackPaymentsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
