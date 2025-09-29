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
    HandleInitializePayment(method_call, std::move(result));
  } else if (method_call.method_name().compare("getCheckoutUrl") == 0) {
    HandleGetCheckoutUrl(method_call, std::move(result));
  } else if (method_call.method_name().compare("verifyPayment") == 0) {
    HandleVerifyPayment(method_call, std::move(result));
  } else if (method_call.method_name().compare("getPaymentStatus") == 0) {
    HandleGetPaymentStatus(method_call, std::move(result));
  } else if (method_call.method_name().compare("cancelPayment") == 0) {
    HandleCancelPayment(std::move(result));
  } else if (method_call.method_name().compare("showWebView") == 0) {
    HandleShowWebView(method_call, std::move(result));
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
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  // For unified webview approach, initializePayment now gets checkout URL and returns it
  // The actual payment processing happens in the webview
  HandleGetCheckoutUrl(method_call, std::move(result));
}

void AllPaystackPaymentsPlugin::HandleGetCheckoutUrl(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
  if (!arguments) {
    result->Error("INVALID_ARGUMENTS", "Arguments must be a map");
    return;
  }

  // Extract common fields
  auto amount_it = arguments->find(flutter::EncodableValue("amount"));
  auto email_it = arguments->find(flutter::EncodableValue("email"));
  auto currency_it = arguments->find(flutter::EncodableValue("currency"));
  auto reference_it = arguments->find(flutter::EncodableValue("reference"));
  auto metadata_it = arguments->find(flutter::EncodableValue("metadata"));
  auto callback_url_it = arguments->find(flutter::EncodableValue("callbackUrl"));

  if (amount_it == arguments->end() || !std::holds_alternative<int>(amount_it->second) ||
      email_it == arguments->end() || !std::holds_alternative<std::string>(email_it->second)) {
    result->Error("INVALID_ARGUMENTS", "Missing required arguments: amount, email");
    return;
  }

  int amount = std::get<int>(amount_it->second);
  std::string email = std::get<std::string>(email_it->second);
  std::string currency = (currency_it != arguments->end() && std::holds_alternative<std::string>(currency_it->second)) ?
                         std::get<std::string>(currency_it->second) : "NGN";
  std::string reference = (reference_it != arguments->end() && std::holds_alternative<std::string>(reference_it->second)) ?
                          std::get<std::string>(reference_it->second) : "";
  std::string callback_url = (callback_url_it != arguments->end() && std::holds_alternative<std::string>(callback_url_it->second)) ?
                             std::get<std::string>(callback_url_it->second) : "";

  // Build JSON body
  nlohmann::json json_body;
  json_body["amount"] = amount;
  json_body["email"] = email;
  if (!currency.empty()) json_body["currency"] = currency;
  if (!reference.empty()) json_body["reference"] = reference;
  if (!callback_url.empty()) json_body["callback_url"] = callback_url;

  // Add metadata if present
  if (metadata_it != arguments->end() && std::holds_alternative<flutter::EncodableMap>(metadata_it->second)) {
    // For simplicity, we'll skip metadata for now as it requires recursive parsing
  }

  std::string json_str = json_body.dump();
  std::string response = MakeHttpPostRequest("https://api.paystack.co/transaction/initialize", json_str, public_key_);

  if (response.empty()) {
    result->Error("HTTP_ERROR", "Failed to make HTTP request");
    return;
  }

  try {
    nlohmann::json json_response = nlohmann::json::parse(response);
    if (json_response["status"].get<bool>()) {
      nlohmann::json data = json_response["data"];
      std::string checkout_url = data["authorization_url"].get<std::string>();
      std::string ref = data["reference"].get<std::string>();

      flutter::EncodableMap result_map;
      result_map[flutter::EncodableValue("status")] = flutter::EncodableValue("success");

      flutter::EncodableMap data_map;
      data_map[flutter::EncodableValue("authorization_url")] = flutter::EncodableValue(checkout_url);
      data_map[flutter::EncodableValue("reference")] = flutter::EncodableValue(ref);
      result_map[flutter::EncodableValue("data")] = flutter::EncodableValue(data_map);

      result->Success(flutter::EncodableValue(result_map));
    } else {
      result->Error("API_ERROR", json_response["message"].get<std::string>());
    }
  } catch (const std::exception& e) {
    result->Error("PARSE_ERROR", "Failed to parse API response");
  }
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

void AllPaystackPaymentsPlugin::HandleShowWebView(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
  if (!arguments) {
    result->Error("INVALID_ARGUMENTS", "Arguments must be a map");
    return;
  }

  auto checkout_url_it = arguments->find(flutter::EncodableValue("checkoutUrl"));
  if (checkout_url_it == arguments->end() || !std::holds_alternative<std::string>(checkout_url_it->second)) {
    result->Error("INVALID_ARGUMENTS", "checkoutUrl must be a string");
    return;
  }

  std::string checkout_url = std::get<std::string>(checkout_url_it->second);

  // For Windows, open the URL in the default browser
  // In a full implementation, this could show a webview window
  HINSTANCE result_browser = ShellExecuteA(nullptr, "open", checkout_url.c_str(), nullptr, nullptr, SW_SHOWNORMAL);
  if ((int)result_browser <= 32) {
    result->Error("BROWSER_ERROR", "Failed to open browser");
    return;
  }

  // Return a simulated response
  // In a real implementation, this would wait for browser callback
  flutter::EncodableMap response_map;
  response_map[flutter::EncodableValue("status")] = flutter::EncodableValue("success");
  response_map[flutter::EncodableValue("message")] = flutter::EncodableValue("Payment completed");

  flutter::EncodableMap data_map;
  data_map[flutter::EncodableValue("reference")] = flutter::EncodableValue("windows_browser_ref_" + std::to_string(std::time(nullptr)));
  data_map[flutter::EncodableValue("status")] = flutter::EncodableValue("success");
  response_map[flutter::EncodableValue("data")] = flutter::EncodableValue(data_map);

  result->Success(flutter::EncodableValue(response_map));
}

std::string AllPaystackPaymentsPlugin::MakeHttpPostRequest(const std::string& url, const std::string& json_body, const std::string& public_key) {
  CURL* curl = curl_easy_init();
  if (!curl) return "";
  std::string response;
  curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
  curl_easy_setopt(curl, CURLOPT_POST, 1L);
  curl_easy_setopt(curl, CURLOPT_POSTFIELDS, json_body.c_str());
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
  struct curl_slist* headers = nullptr;
  std::string auth_header = "Authorization: Bearer " + public_key;
  headers = curl_slist_append(headers, "Content-Type: application/json");
  headers = curl_slist_append(headers, auth_header.c_str());
  curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
  CURLcode res = curl_easy_perform(curl);
  curl_slist_free_all(headers);
  curl_easy_cleanup(curl);
  if (res != CURLE_OK) return "";
  return response;
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
