#ifndef FLUTTER_PLUGIN_ALL_PAYSTACK_PAYMENTS_PLUGIN_H_
#define FLUTTER_PLUGIN_ALL_PAYSTACK_PAYMENTS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>
#include <string>

namespace all_paystack_payments {

class AllPaystackPaymentsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AllPaystackPaymentsPlugin();

  virtual ~AllPaystackPaymentsPlugin();

  // Disallow copy and assign.
  AllPaystackPaymentsPlugin(const AllPaystackPaymentsPlugin&) = delete;
  AllPaystackPaymentsPlugin& operator=(const AllPaystackPaymentsPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

 private:
  std::string public_key_;
};

}  // namespace all_paystack_payments

#endif  // FLUTTER_PLUGIN_ALL_PAYSTACK_PAYMENTS_PLUGIN_H_
