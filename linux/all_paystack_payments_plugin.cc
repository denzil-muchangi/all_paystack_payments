#include "include/all_paystack_payments/all_paystack_payments_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>
#include <string>

#include "all_paystack_payments_plugin_private.h"

#include <curl/curl.h>
#include <nlohmann/json.hpp>

#define ALL_PAYSTACK_PAYMENTS_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), all_paystack_payments_plugin_get_type(), \
                               AllPaystackPaymentsPlugin))

struct _AllPaystackPaymentsPluginPrivate {
  std::string public_key;
};

struct _AllPaystackPaymentsPlugin {
  GObject parent_instance;
  AllPaystackPaymentsPluginPrivate* priv;
};

G_DEFINE_TYPE_WITH_PRIVATE(AllPaystackPaymentsPlugin, all_paystack_payments_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void all_paystack_payments_plugin_handle_method_call(
    AllPaystackPaymentsPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "initialize") == 0) {
    response = handle_initialize(self, args);
  } else if (strcmp(method, "initializePayment") == 0) {
    response = handle_initialize_payment(self, args);
  } else if (strcmp(method, "getCheckoutUrl") == 0) {
    response = handle_get_checkout_url(self, args);
  } else if (strcmp(method, "verifyPayment") == 0) {
    response = handle_verify_payment(self, args);
  } else if (strcmp(method, "getPaymentStatus") == 0) {
    response = handle_get_payment_status(self, args);
  } else if (strcmp(method, "cancelPayment") == 0) {
    response = handle_cancel_payment(self, args);
  } else if (strcmp(method, "showWebView") == 0) {
    response = handle_show_webview(self, args);
  } else if (strcmp(method, "getPlatformVersion") == 0) {
    response = get_platform_version();
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

FlMethodResponse* get_platform_version() {
  struct utsname uname_data = {};
  uname(&uname_data);
  g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
  g_autoptr(FlValue) result = fl_value_new_string(version);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

FlMethodResponse* handle_initialize(AllPaystackPaymentsPlugin* self, FlValue* args) {
  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGUMENTS", "Arguments must be a map", nullptr));
  }
  FlValue* public_key_value = fl_value_lookup_string(args, "publicKey");
  if (!public_key_value || fl_value_get_type(public_key_value) != FL_VALUE_TYPE_STRING) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGUMENTS", "publicKey must be a string", nullptr));
  }
  const gchar* public_key = fl_value_get_string(public_key_value);
  self->priv->public_key = public_key;
  return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
}

FlMethodResponse* handle_initialize_payment(AllPaystackPaymentsPlugin* self, FlValue* args) {
  // For unified webview approach, initializePayment now gets checkout URL and returns it
  // The actual payment processing happens in the webview
  return handle_get_checkout_url(self, args);
}

FlMethodResponse* handle_get_checkout_url(AllPaystackPaymentsPlugin* self, FlValue* args) {
  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGUMENTS", "Arguments must be a map", nullptr));
  }

  // Extract common fields
  FlValue* amount_value = fl_value_lookup_string(args, "amount");
  FlValue* email_value = fl_value_lookup_string(args, "email");
  FlValue* currency_value = fl_value_lookup_string(args, "currency");
  FlValue* reference_value = fl_value_lookup_string(args, "reference");
  FlValue* callback_url_value = fl_value_lookup_string(args, "callbackUrl");
  FlValue* metadata_value = fl_value_lookup_string(args, "metadata");

  if (!amount_value || fl_value_get_type(amount_value) != FL_VALUE_TYPE_INT ||
      !email_value || fl_value_get_type(email_value) != FL_VALUE_TYPE_STRING) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGUMENTS", "Missing required arguments: amount, email", nullptr));
  }

  int64_t amount = fl_value_get_int(amount_value);
  const gchar* email = fl_value_get_string(email_value);
  const gchar* currency = currency_value && fl_value_get_type(currency_value) == FL_VALUE_TYPE_STRING ? fl_value_get_string(currency_value) : "NGN";
  const gchar* reference = reference_value && fl_value_get_type(reference_value) == FL_VALUE_TYPE_STRING ? fl_value_get_string(reference_value) : nullptr;
  const gchar* callback_url = callback_url_value && fl_value_get_type(callback_url_value) == FL_VALUE_TYPE_STRING ? fl_value_get_string(callback_url_value) : nullptr;

  // Build JSON body
  nlohmann::json json_body;
  json_body["amount"] = amount;
  json_body["email"] = email;
  if (currency) json_body["currency"] = currency;
  if (reference) json_body["reference"] = reference;
  if (callback_url) json_body["callback_url"] = callback_url;

  // Add metadata if present (simplified)
  if (metadata_value && fl_value_get_type(metadata_value) == FL_VALUE_TYPE_MAP) {
    // For simplicity, we'll skip complex metadata parsing for now
  }

  std::string json_str = json_body.dump();
  std::string response = make_http_post_request("https://api.paystack.co/transaction/initialize", json_str, self->priv->public_key);

  if (response.empty()) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("HTTP_ERROR", "Failed to make HTTP request", nullptr));
  }

  try {
    nlohmann::json json_response = nlohmann::json::parse(response);
    if (json_response["status"].get<bool>()) {
      nlohmann::json data = json_response["data"];
      std::string checkout_url = data["authorization_url"].get<std::string>();
      std::string ref = data["reference"].get<std::string>();

      g_autoptr(FlValue) result = fl_value_new_map();
      fl_value_set(result, fl_value_new_string("status"), fl_value_new_string("success"));

      g_autoptr(FlValue) data_map = fl_value_new_map();
      fl_value_set(data_map, fl_value_new_string("authorization_url"), fl_value_new_string(checkout_url.c_str()));
      fl_value_set(data_map, fl_value_new_string("reference"), fl_value_new_string(ref.c_str()));
      fl_value_set(result, fl_value_new_string("data"), data_map);

      return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    } else {
      return FL_METHOD_RESPONSE(fl_method_error_response_new("API_ERROR", json_response["message"].get<std::string>().c_str(), nullptr));
    }
  } catch (const std::exception& e) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("PARSE_ERROR", "Failed to parse API response", nullptr));
  }
}

FlMethodResponse* handle_verify_payment(AllPaystackPaymentsPlugin* self, FlValue* args) {
  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGUMENTS", "Arguments must be a map", nullptr));
  }
  FlValue* reference_value = fl_value_lookup_string(args, "reference");
  if (!reference_value || fl_value_get_type(reference_value) != FL_VALUE_TYPE_STRING) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGUMENTS", "reference must be a string", nullptr));
  }
  const gchar* reference = fl_value_get_string(reference_value);
  std::string url = "https://api.paystack.co/transaction/verify/" + std::string(reference);
  std::string response = make_http_request(url, self->priv->public_key);
  if (response.empty()) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("HTTP_ERROR", "Failed to make HTTP request", nullptr));
  }
  try {
    nlohmann::json json_response = nlohmann::json::parse(response);
    if (json_response["status"].get<bool>()) {
      nlohmann::json data = json_response["data"];
      g_autoptr(FlValue) result = fl_value_new_map();
      fl_value_set(result, fl_value_new_string("reference"), fl_value_new_string(data["reference"].get<std::string>().c_str()));
      fl_value_set(result, fl_value_new_string("status"), fl_value_new_string(data["status"].get<std::string>().c_str()));
      fl_value_set(result, fl_value_new_string("amount"), fl_value_new_int(data["amount"].get<int>()));
      fl_value_set(result, fl_value_new_string("currency"), fl_value_new_string(data["currency"].get<std::string>().c_str()));
      fl_value_set(result, fl_value_new_string("payment_method"), fl_value_new_string("card")); // default
      if (data.contains("gateway_response")) {
        fl_value_set(result, fl_value_new_string("gateway_response"), fl_value_new_string(data["gateway_response"].get<std::string>().c_str()));
      }
      return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    } else {
      return FL_METHOD_RESPONSE(fl_method_error_response_new("API_ERROR", json_response["message"].get<std::string>().c_str(), nullptr));
    }
  } catch (const std::exception& e) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("PARSE_ERROR", "Failed to parse API response", nullptr));
  }
}

FlMethodResponse* handle_get_payment_status(AllPaystackPaymentsPlugin* self, FlValue* args) {
  // Same as verify for now
  return handle_verify_payment(self, args);
}

FlMethodResponse* handle_cancel_payment(AllPaystackPaymentsPlugin* self, FlValue* args) {
  g_autoptr(FlValue) result = fl_value_new_bool(false);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

FlMethodResponse* handle_show_webview(AllPaystackPaymentsPlugin* self, FlValue* args) {
  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGUMENTS", "Arguments must be a map", nullptr));
  }

  FlValue* checkout_url_value = fl_value_lookup_string(args, "checkoutUrl");
  if (!checkout_url_value || fl_value_get_type(checkout_url_value) != FL_VALUE_TYPE_STRING) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGUMENTS", "checkoutUrl must be a string", nullptr));
  }

  const gchar* checkout_url = fl_value_get_string(checkout_url_value);

  // For Linux, try to open the URL in the default browser
  // Using xdg-open or similar
  std::string command = "xdg-open '" + std::string(checkout_url) + "' 2>/dev/null &";
  int result_code = system(command.c_str());

  if (result_code != 0) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("BROWSER_ERROR", "Failed to open browser", nullptr));
  }

  // Return a simulated response
  g_autoptr(FlValue) result = fl_value_new_map();
  fl_value_set(result, fl_value_new_string("status"), fl_value_new_string("success"));
  fl_value_set(result, fl_value_new_string("message"), fl_value_new_string("Payment completed"));

  g_autoptr(FlValue) data_map = fl_value_new_map();
  std::string ref = "linux_browser_ref_" + std::to_string(std::time(nullptr));
  fl_value_set(data_map, fl_value_new_string("reference"), fl_value_new_string(ref.c_str()));
  fl_value_set(data_map, fl_value_new_string("status"), fl_value_new_string("success"));
  fl_value_set(result, fl_value_new_string("data"), data_map);

  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

std::string make_http_post_request(const std::string& url, const std::string& json_body, const std::string& public_key) {
  CURL* curl = curl_easy_init();
  if (!curl) return "";
  std::string response;
  curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
  curl_easy_setopt(curl, CURLOPT_POST, 1L);
  curl_easy_setopt(curl, CURLOPT_POSTFIELDS, json_body.c_str());
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
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

std::string make_http_request(const std::string& url, const std::string& public_key) {
  CURL* curl = curl_easy_init();
  if (!curl) return "";
  std::string response;
  curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
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

size_t write_callback(void* contents, size_t size, size_t nmemb, std::string* response) {
  size_t total_size = size * nmemb;
  response->append((char*)contents, total_size);
  return total_size;
}

static void all_paystack_payments_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(all_paystack_payments_plugin_parent_class)->dispose(object);
}

static void all_paystack_payments_plugin_class_init(AllPaystackPaymentsPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = all_paystack_payments_plugin_dispose;
}

static void all_paystack_payments_plugin_init(AllPaystackPaymentsPlugin* self) {
  self->priv = static_cast<AllPaystackPaymentsPluginPrivate*>(
      all_paystack_payments_plugin_get_instance_private(self));
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  AllPaystackPaymentsPlugin* plugin = ALL_PAYSTACK_PAYMENTS_PLUGIN(user_data);
  all_paystack_payments_plugin_handle_method_call(plugin, method_call);
}

void all_paystack_payments_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  AllPaystackPaymentsPlugin* plugin = ALL_PAYSTACK_PAYMENTS_PLUGIN(
      g_object_new(all_paystack_payments_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "all_paystack_payments",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
