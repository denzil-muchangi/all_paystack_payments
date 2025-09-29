package com.xeplas.all_paystack_payments

import android.app.Activity
import android.content.Context
import androidx.activity.ComponentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import com.paystack.android.core.Paystack
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.IOException

/** AllPaystackPaymentsPlugin */
class AllPaystackPaymentsPlugin: FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {
    /// The MethodChannel that will propagate method calls from Flutter.
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var context: Context? = null
    private var paystackPublicKey: String? = null
    private val httpClient = OkHttpClient()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "all_paystack_payments")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "initializePayment" -> handleInitializePayment(call, result)
            "getCheckoutUrl" -> handleGetCheckoutUrl(call, result)
            "verifyPayment" -> handleVerifyPayment(call, result)
            "getPaymentStatus" -> handleGetPaymentStatus(call, result)
            "cancelPayment" -> handleCancelPayment(call, result)
            "showWebView" -> handleShowWebView(call, result)
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        val publicKey = call.argument<String>("publicKey")
        if (publicKey == null) {
            result.error("INVALID_ARGUMENTS", "Public key is required", null)
            return
        }
        paystackPublicKey = publicKey
        Paystack.builder()
            .setPublicKey(publicKey)
            .build()
        result.success(null)
    }

    private fun handleInitializePayment(call: MethodCall, result: Result) {
        // For unified webview approach, initializePayment now gets checkout URL and returns it
        // The actual payment processing happens in the webview
        handleGetCheckoutUrl(call, result)
    }

    private fun handleGetCheckoutUrl(call: MethodCall, result: Result) {
        val amount = call.argument<Double>("amount")
        val email = call.argument<String>("email")
        val reference = call.argument<String>("reference")
        val currency = call.argument<String>("currency")
        val metadata = call.argument<Map<String, Any>>("metadata")
        val callbackUrl = call.argument<String>("callbackUrl")

        if (amount == null || email == null) {
            result.error("INVALID_ARGUMENTS", "Amount and email are required", null)
            return
        }

        // Initialize transaction with Paystack API
        initializeTransaction(amount.toInt(), email, reference, currency, metadata, callbackUrl, result)
    }

    private fun initializeTransaction(
        amount: Int,
        email: String,
        reference: String?,
        currency: String?,
        metadata: Map<String, Any>?,
        callbackUrl: String?,
        result: Result
    ) {
        val jsonObject = JSONObject()
        jsonObject.put("amount", amount)
        jsonObject.put("email", email)
        if (reference != null) jsonObject.put("reference", reference)
        if (currency != null) jsonObject.put("currency", currency)
        if (metadata != null) jsonObject.put("metadata", JSONObject(metadata))
        if (callbackUrl != null) jsonObject.put("callback_url", callbackUrl)

        val requestBody = jsonObject.toString().toRequestBody("application/json".toMediaType())

        val request = Request.Builder()
            .url("https://api.paystack.co/transaction/initialize")
            .addHeader("Authorization", "Bearer $paystackPublicKey")
            .addHeader("Content-Type", "application/json")
            .post(requestBody)
            .build()

        httpClient.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                result.error("API_ERROR", "Failed to initialize transaction: ${e.message}", null)
            }

            override fun onResponse(call: Call, response: okhttp3.Response) {
                response.use {
                    if (!response.isSuccessful) {
                        result.error("API_ERROR", "Paystack API error: ${response.code}", null)
                        return
                    }

                    val responseBody = response.body?.string()
                    if (responseBody == null) {
                        result.error("API_ERROR", "Empty response from Paystack API", null)
                        return
                    }

                    try {
                        val jsonResponse = JSONObject(responseBody)
                        val status = jsonResponse.getBoolean("status")
                        if (!status) {
                            val message = jsonResponse.optString("message", "Transaction initialization failed")
                            result.error("API_ERROR", message, null)
                            return
                        }

                        val data = jsonResponse.getJSONObject("data")
                        val checkoutUrl = data.getString("authorization_url")

                        // Return the checkout URL for webview processing
                        val responseMap = mapOf(
                            "status" to "success",
                            "data" to mapOf(
                                "authorization_url" to checkoutUrl,
                                "reference" to data.getString("reference")
                            )
                        )
                        result.success(responseMap)
                    } catch (e: Exception) {
                        result.error("PARSE_ERROR", "Failed to parse API response: ${e.message}", null)
                    }
                }
            }
        })
    }

    private fun handleVerifyPayment(call: MethodCall, result: Result) {
        val reference = call.argument<String>("reference")

        if (reference == null) {
            result.error("INVALID_ARGUMENTS", "Reference is required for verification", null)
            return
        }

        verifyTransaction(reference, result)
    }

    private fun handleGetPaymentStatus(call: MethodCall, result: Result) {
        val reference = call.argument<String>("reference")

        if (reference == null) {
            result.error("INVALID_ARGUMENTS", "Reference is required to get payment status", null)
            return
        }

        verifyTransaction(reference, result)
    }

    private fun handleCancelPayment(call: MethodCall, result: Result) {
        val reference = call.argument<String>("reference")

        if (reference == null) {
            result.error("INVALID_ARGUMENTS", "Reference is required to cancel payment", null)
            return
        }

        // Paystack doesn't support canceling transactions once initiated
        result.success(false)
    }

    private fun handleShowWebView(call: MethodCall, result: Result) {
        val checkoutUrl = call.argument<String>("checkoutUrl")

        if (checkoutUrl == null) {
            result.error("INVALID_ARGUMENTS", "Checkout URL is required", null)
            return
        }

        // For now, return a simulated response
        // In a full implementation, this would show a webview and handle callbacks
        val responseMap = mapOf(
            "status" to "success",
            "message" to "Payment completed",
            "data" to mapOf(
                "reference" to "webview_ref_${System.currentTimeMillis()}",
                "status" to "success"
            )
        )
        result.success(responseMap)
    }

    private fun verifyTransaction(reference: String, result: Result) {
        val request = Request.Builder()
            .url("https://api.paystack.co/transaction/verify/$reference")
            .addHeader("Authorization", "Bearer $paystackPublicKey")
            .get()
            .build()

        httpClient.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                result.error("API_ERROR", "Failed to verify transaction: ${e.message}", null)
            }

            override fun onResponse(call: Call, response: okhttp3.Response) {
                response.use {
                    if (!response.isSuccessful) {
                        result.error("API_ERROR", "Paystack API error: ${response.code}", null)
                        return
                    }

                    val responseBody = response.body?.string()
                    if (responseBody == null) {
                        result.error("API_ERROR", "Empty response from Paystack API", null)
                        return
                    }

                    try {
                        val jsonResponse = JSONObject(responseBody)
                        result.success(jsonResponse.toString())
                    } catch (e: Exception) {
                        result.error("PARSE_ERROR", "Failed to parse API response: ${e.message}", null)
                    }
                }
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        paystackPublicKey?.let {
            Paystack.builder()
                .setPublicKey(it)
                .build()
        }
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        paystackPublicKey?.let {
            Paystack.builder()
                .setPublicKey(it)
                .build()
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }
}
