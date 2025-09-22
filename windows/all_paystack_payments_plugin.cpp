#include "all_paystack_payments_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <curl/curl.h>
#include <nlohmann/json.hpp>

#include <memory>
#include <sstream>
#include <string>

namespace all_paystack_payments {

// static
void AllPaystackPaymentsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "all_paystack_payments",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<AllPaystackPaymentsPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

AllPaystackPaymentsPlugin::AllPaystackPaymentsPlugin() {}

AllPaystackPaymentsPlugin::~AllPaystackPaymentsPlugin() {}

void AllPaystackPaymentsPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("initialize") == 0) {
    HandleInitialize(method_call, std::move(result));
  } else if (method_call.method_name().compare("initializePayment") == 0) {
    HandleInitializePayment(std::move(result));
  } else if (method_call.method_name().compare("verifyPayment") == 0) {
    HandleVerifyPayment(method_call, std::move(result));
  } else if (method_call.method_name().compare("getPaymentStatus") == 0) {
    HandleGetPaymentStatus(method_call, std::move(result));
  } else if (method_call.method_name().compare("cancelPayment") == 0) {
    HandleCancelPayment(std::move(result));
  } else if (method_call.method_name().compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  } else {
    result->NotImplemented();
  }
}

void AllPaystackPaymentsPlugin::HandleInitialize(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
  if (!arguments) {
    result->Error("INVALID_ARGUMENTS", "Arguments must be a map");
    return;
  }
  auto public_key_it = arguments->find(flutter::EncodableValue("publicKey"));
  if (public_key_it == arguments->end() || !std::holds_alternative<std::string>(public_key_it->second)) {
    result->Error("INVALID_ARGUMENTS", "publicKey must be a string");
    return;
  }
  public_key_ = std::get<std::string>(public_key_it->second);
  result->Success();
}

void AllPaystackPaymentsPlugin::HandleInitializePayment(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  result->Error("DESKTOP_NOT_SUPPORTED", "Payment initialization is not supported on desktop platforms");
}

void AllPaystackPaymentsPlugin::HandleVerifyPayment(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
  if (!arguments) {
    result->Error("INVALID_ARGUMENTS", "Arguments must be a map");
    return;
  }
  auto reference_it = arguments->find(flutter::EncodableValue("reference"));
  if (reference_it == arguments->end() || !std::holds_alternative<std::string>(reference_it->second)) {
    result->Error("INVALID_ARGUMENTS", "reference must be a string");
    return;
  }
  std::string reference = std::get<std::string>(reference_it->second);
  std::string url = "https://api.paystack.co/transaction/verify/" + reference;
  std::string response = MakeHttpRequest(url, public_key_);
  if (response.empty()) {
    result->Error("HTTP_ERROR", "Failed to make HTTP request");
    return;
  }
  try {
    nlohmann::json json_response = nlohmann::json::parse(response);
    if (json_response["status"].get<bool>()) {
      nlohmann::json data = json_response["data"];
      flutter::EncodableMap result_map;
      result_map[flutter::EncodableValue("reference")] = flutter::EncodableValue(data["reference"].get<std::string>());
      result_map[flutter::EncodableValue("status")] = flutter::EncodableValue(data["status"].get<std::string>());
      result_map[flutter::EncodableValue("amount")] = flutter::EncodableValue(data["amount"].get<int>());
      result_map[flutter::EncodableValue("currency")] = flutter::EncodableValue(data["currency"].get<std::string>());
      result_map[flutter::EncodableValue("payment_method")] = flutter::EncodableValue("card");
      if (data.contains("gateway_response")) {
        result_map[flutter::EncodableValue("gateway_response")] = flutter::EncodableValue(data["gateway_response"].get<std::string>());
      }
      result->Success(flutter::EncodableValue(result_map));
    } else {
      result->Error("API_ERROR", json_response["message"].get<std::string>());
    }
  } catch (const std::exception& e) {
    result->Error("PARSE_ERROR", "Failed to parse API response");
  }
}

void AllPaystackPaymentsPlugin::HandleGetPaymentStatus(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  HandleVerifyPayment(method_call, std::move(result));
}

void AllPaystackPaymentsPlugin::HandleCancelPayment(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  result->Success(flutter::EncodableValue(false));
}

static std::string MakeHttpRequest(const std::string& url, const std::string& public_key) {
  CURL* curl = curl_easy_init();
  if (!curl) return "";
  std::string response;
  curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
  struct curl_slist* headers = nullptr;
  std::string auth_header = "Authorization: Bearer " + public_key;
  headers = curl_slist_append(headers, auth_header.c_str());
  curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
  CURLcode res = curl_easy_perform(curl);
  curl_slist_free_all(headers);
  curl_easy_cleanup(curl);
  if (res != CURLE_OK) return "";
  return response;
}

static size_t WriteCallback(void* contents, size_t size, size_t nmemb, std::string* response) {
  size_t total_size = size * nmemb;
  response->append((char*)contents, total_size);
  return total_size;
}

}  // namespace all_paystack_payments
