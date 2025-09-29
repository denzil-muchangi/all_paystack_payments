package com.xeplas.all_paystack_payments

import android.app.Activity
import android.content.Context
import co.paystack.android.PaystackSdk
import co.paystack.android.Transaction
import co.paystack.android.model.Card
import co.paystack.android.model.Charge
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

/** AllPaystackPaymentsPlugin */
class AllPaystackPaymentsPlugin: FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {
    /// The MethodChannel that will propagate method calls from Flutter.
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var context: Context? = null

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
            "verifyPayment" -> handleVerifyPayment(call, result)
            "getPaymentStatus" -> handleGetPaymentStatus(call, result)
            "cancelPayment" -> handleCancelPayment(call, result)
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
        PaystackSdk.setPublicKey(publicKey)
        result.success(null)
    }

    private fun handleInitializePayment(call: MethodCall, result: Result) {
        val paymentMethod = call.argument<String>("paymentMethod")
        val amount = call.argument<Double>("amount")
        val email = call.argument<String>("email")
        val reference = call.argument<String>("reference")
        val currency = call.argument<String>("currency")
        val metadata = call.argument<Map<String, Any>>("metadata")
        val callbackUrl = call.argument<String>("callbackUrl")

        if (amount == null || email == null || reference == null || currency == null) {
            result.error("INVALID_ARGUMENTS", "Missing required payment arguments", null)
            return
        }

        when (paymentMethod) {
            "card" -> handleCardPayment(call, result, amount, email, reference, currency, metadata, callbackUrl)
            "bank_transfer" -> handleBankTransferPayment(call, result, amount, email, reference, currency, metadata, callbackUrl)
            "mobile_money" -> handleMobileMoneyPayment(call, result, amount, email, reference, currency, metadata, callbackUrl)
            else -> result.notImplemented()
        }
    }

    private fun handleCardPayment(
        call: MethodCall,
        result: Result,
        amount: Double,
        email: String,
        reference: String,
        currency: String,
        metadata: Map<String, Any>?,
        callbackUrl: String?
    ) {
        val cardNumber = call.argument<String>("cardNumber")
        val expiryMonth = call.argument<Int>("expiryMonth")
        val expiryYear = call.argument<Int>("expiryYear")
        val cvv = call.argument<String>("cvv")
        val cardHolderName = call.argument<String>("cardHolderName")

        if (cardNumber == null || expiryMonth == null || expiryYear == null || cvv == null) {
            result.error("INVALID_ARGUMENTS", "Missing required card details", null)
            return
        }

        val card = Card(cardNumber, expiryMonth, expiryYear, cvv)
        if (!card.isValid) {
            result.error("INVALID_CARD", "Card details are invalid", null)
            return
        }

        val charge = Charge()
        charge.cardNumber = cardNumber
        charge.expiryMonth = expiryMonth
        charge.expiryYear = expiryYear
        charge.cvv = cvv
        charge.amount = (amount * 100).toInt() // Paystack amount is in kobo/cent
        charge.email = email
        charge.reference = reference
        charge.currency = currency
        // TODO: Add metadata and callbackUrl if Paystack Android SDK supports it directly

        PaystackSdk.chargeCard(activity, charge, object : PaystackSdk.TransactionCallback {
            override fun onSuccess(transaction: Transaction) {
                result.success(mapOf(
                    "reference" to transaction.reference,
                    "status" to "success",
                    "message" to transaction.gatewayResponse
                ))
            }

            override fun beforeValidate(transaction: Transaction) {
                // This is called before card validation. Perform any validation here.
            }

            override fun onError(transaction: Transaction, error: Throwable) {
                result.error("PAYMENT_FAILED", error.message, null)
            }
        })
    }

    private fun handleBankTransferPayment(
        call: MethodCall,
        result: Result,
        amount: Double,
        email: String,
        reference: String,
        currency: String,
        metadata: Map<String, Any>?,
        callbackUrl: String?
    ) {
        // Paystack Android SDK does not directly support initiating bank transfers from the client-side.
        // Bank transfers usually involve displaying bank details to the user for manual transfer
        // or are initiated server-side. For now, we will return notImplemented.
        result.notImplemented()
    }

    private fun handleMobileMoneyPayment(
        call: MethodCall,
        result: Result,
        amount: Double,
        email: String,
        reference: String,
        currency: String,
        metadata: Map<String, Any>?,
        callbackUrl: String?
    ) {
        // Paystack Android SDK does not directly support initiating mobile money payments from the client-side.
        // Mobile money payments often involve USSD codes or redirects, which are typically handled server-side.
        // For now, we will return notImplemented.
        result.notImplemented()
    }

    private fun handleVerifyPayment(call: MethodCall, result: Result) {
        val reference = call.argument<String>("reference")

        if (reference == null) {
            result.error("INVALID_ARGUMENTS", "Reference is required for verification", null)
            return
        }

        // Paystack Android SDK does not have a direct client-side method for verifying payments.
        // Verification is typically done server-side by calling Paystack's API.
        // For now, we will return notImplemented.
        result.notImplemented()
    }

    private fun handleGetPaymentStatus(call: MethodCall, result: Result) {
        val reference = call.argument<String>("reference")

        if (reference == null) {
            result.error("INVALID_ARGUMENTS", "Reference is required to get payment status", null)
            return
        }

        // Paystack Android SDK does not have a direct client-side method for getting payment status.
        // This is typically done server-side by calling Paystack's API.
        // For now, we will return notImplemented.
        result.notImplemented()
    }

    private fun handleCancelPayment(call: MethodCall, result: Result) {
        val reference = call.argument<String>("reference")

        if (reference == null) {
            result.error("INVALID_ARGUMENTS", "Reference is required to cancel payment", null)
            return
        }

        // Paystack Android SDK does not have a direct client-side method for canceling payments.
        // This is typically done server-side by calling Paystack's API.
        // For now, we will return notImplemented.
        result.notImplemented()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        PaystackSdk.initialize(context)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReinitializedActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }
}
