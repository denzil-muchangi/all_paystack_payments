//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <all_paystack_payments/all_paystack_payments_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) all_paystack_payments_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AllPaystackPaymentsPlugin");
  all_paystack_payments_plugin_register_with_registrar(all_paystack_payments_registrar);
}
