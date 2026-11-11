package com.punnyam.staff

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.LocationManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.content.ContextCompat
import com.pnsol.sdk.auth.AccountValidator
import com.pnsol.sdk.interfaces.TransactionTypes
import com.pnsol.sdk.payment.PaymentInitialization
import com.pnsol.sdk.vo.PosPaymentModel
import com.pnsol.sdk.vo.response.LoginResponse
import com.pnsol.sdk.vo.response.TransactionResponse
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import ps.module.location.LocationData
import ps.module.utils.AppInfo
import ps.sdk.mpay.repository.merchantInfo.remote.models.MerchantInfoDetailsResponse
import ps.sdk.mpay.ui.PosPaymentActivity
import android.graphics.Bitmap
import android.graphics.Color
import android.util.Base64
import com.google.zxing.BarcodeFormat
import com.google.zxing.qrcode.QRCodeWriter
import com.pnsol.sdk.vo.QrTransactionResponse
import com.ps.qrcode.model.QR
import com.ps.qrcode.model.customrequest.MerchantPersonalizeQR
import java.io.ByteArrayOutputStream
import ps.sdk.mpay.creator.PayswiffSDK
import ps.sdk.mpay.creator.interfaces.IQRExecutor

/** Flutter <-> Payswiff SDK payment bridge. */
class PaymentChannel(private val activity: Activity) {

    companion object {
        const val CHANNEL = "punnyam/apos_payment"
        const val REQ_PAYMENT = 7001
        private const val TAG = "APOS_PAY"
        private const val PREF_ENV = "activated_env"

        // Values taken from the SDK (com.pnsol.sdk.interfaces.CommonResultCode)
        private const val RC_SUCCESS = 1018
        private const val RC_FAIL = 1019
        private const val RC_ERROR = -1
        private const val RC_TXN_FAILED = 1032
        private const val RC_TXN_PENDING = 1034
        // CommonResultCode is package-private in the SDK, so the QR codes are copied too
        // (read from ps-n86Uat-v2.1.13.aar). ERROR_MESSAGE = RC_ERROR (-1).
        private const val RC_QR_STATUS_SUCCESS = 4000
        private const val RC_QR_STATUS_ERROR = 4001
    }

    /** Flutter call waiting for the payment screen to close. */
    private var pendingSale: MethodChannel.Result? = null

    private val appName get() = BuildConfig.PS_APP_NAME
    private val appVersion: String
        get() = try { AppInfo.getAppVersionName() } catch (e: Throwable) { BuildConfig.VERSION_NAME }

        /** Kept so QR payment status can be pushed to Flutter (onQrStatus). */
    private var channel: MethodChannel? = null

    fun register(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, CHANNEL)
        channel!!.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "isActivated" -> result.success(isActivatedForEnv())
                    "activate" -> activate(call, result)
                    "getMerchantConfig" -> getMerchantConfig(call, result)
                    "startSale" -> startSale(call, result)
                    "voidTxn" -> voidTxn(call, result)
                    "generateQr" -> generateQr(call, result)
                    "cancelQr" -> { cancelQr(); result.success(true) }
                    else -> result.notImplemented()
                }
            } catch (e: Throwable) {
                Log.e(TAG, "${call.method} failed", e)
                result.error("SDK_ERROR", e.message, null)
            }
        }
    }

    // ---------------------------------------------------------------- activation
    private fun activate(call: MethodCall, result: MethodChannel.Result) {
        val merchantKey = call.argument<String>("merchantKey")
            ?: return result.error("ARGS", "merchantKey missing", null)
        val partnerKey = call.argument<String>("partnerKey")
            ?: return result.error("ARGS", "partnerKey missing", null)

        // Drop a stale activation from another environment (e.g. UAT user id) first.
        val env = prefs.getString(PREF_ENV, null)
        if (env != BuildConfig.PS_ENV && AccountValidator(activity).isAccountActivated()) {
            Log.w(TAG, "Clearing SDK activation from env=$env before activating for ${BuildConfig.PS_ENV}")
            activity.getSharedPreferences("mpay", Context.MODE_PRIVATE).edit().clear().commit()
            activity.deleteSharedPreferences("mpay")
        }

        AccountValidator(activity).accountActivation(
            oneShotHandler(result) { obj ->
                prefs.edit().putString(PREF_ENV, BuildConfig.PS_ENV).apply()
                (obj as? LoginResponse)?.responseMessage ?: "Activated"
            },
            merchantKey.trim(), partnerKey.trim()
        )
    }

    // The SDK stores its activation locally and doesn't know which server it was for.
    // A device activated on UAT would still report "activated" on a release build and
    // get "Invalid user id" from production, so we also remember the environment.
    private val prefs get() = activity.getSharedPreferences("punnyam_ps", Context.MODE_PRIVATE)

    private fun isActivatedForEnv(): Boolean {
        val sdkActivated = AccountValidator(activity).isAccountActivated()
        val env = prefs.getString(PREF_ENV, null)
        Log.d(TAG, "isActivated sdk=$sdkActivated env=$env build=${BuildConfig.PS_ENV}")
        return sdkActivated && env == BuildConfig.PS_ENV
    }

    // ---------------------------------------------------------------- merchant config
    private fun getMerchantConfig(call: MethodCall, result: MethodChannel.Result) {
        val apiKey = call.argument<String>("apiKey") ?: ""
        val secureKey = call.argument<String>("secureKey") ?: ""

        PaymentInitialization(activity, activity.application, BuildConfig.PS_BANNER_NAME)
            .getMerchantConfigurationDetails(
                oneShotHandler(result) { obj ->
                    val r = obj as MerchantInfoDetailsResponse
                    mapOf(
                        "serialNumber" to r.deviceSerialNumber,
                        "deviceStatus" to r.deviceStatus,
                        "mid" to r.acquirerMerchantId,
                        "tid" to r.acquirerTerminalId,
                        "bankName" to r.acquirerBankName,
                        "deviceAppVersion" to r.deviceAppVersion,
                        "lastTransactionDate" to r.lastTransactionDate
                    )
                },
                apiKey, secureKey
            )
    }

    // ---------------------------------------------------------------- card sale
    private fun startSale(call: MethodCall, result: MethodChannel.Result) {
        if (pendingSale != null) {
            return result.error("BUSY", "A payment is already in progress", null)
        }
        val amount = call.argument<String>("amount")
            ?: return result.error("ARGS", "amount missing", null)
        if (!isActivatedForEnv()) {
            return result.error("NOT_ACTIVATED", "Payment device not activated for ${BuildConfig.PS_ENV}", null)
        }

        val model = PosPaymentModel(
            appName,                                     // 1 appName
            appVersion,                                  // 2 appVersion
            amount,                                      // 3 amount e.g. "150.00"
            TransactionTypes.SALE,                       // 4 "Sale"
            call.argument<String>("mobile") ?: "",       // 5 customer mobile
            call.argument<String>("name") ?: "Customer", // 6 customer name
            lastLocation(),                              // 7 location
            "0",                                         // 8 cashback amount
            call.argument<String>("merchantRefNo") ?: "",// 9 merchant ref
            call.argument<String>("orderRefNo") ?: ""    // 10 order ref
        )

        pendingSale = result
        activity.startActivityForResult(
            PosPaymentActivity.buildStartTransactionIntent(activity, model),
            REQ_PAYMENT
        )
    }

    /** Called from MainActivity.onActivityResult. Returns true if handled. */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQ_PAYMENT) return false
        val result = pendingSale ?: return true
        pendingSale = null

        val txn = try {
            data?.getSerializableExtra(PosPaymentActivity.TRANSACTION_RESPONSE) as? TransactionResponse
        } catch (e: Throwable) { null }

        val map: Map<String, Any?> = when (resultCode) {
            RC_SUCCESS -> responseToMap("success", txn)
            RC_TXN_FAILED -> responseToMap("failed", txn)
            RC_TXN_PENDING -> responseToMap("pending", txn)
            RC_ERROR -> mapOf(
                "status" to "error",
                "responseMessage" to (data?.getStringExtra(PosPaymentActivity.ERROR) ?: "Unknown error")
            )
            else -> mapOf("status" to "cancelled", "responseMessage" to "Transaction cancelled")
        }
        Log.d(TAG, "sale result $resultCode -> $map")
        result.success(map)
        return true
    }

    // ---------------------------------------------------------------- void
    private fun voidTxn(call: MethodCall, result: MethodChannel.Result) {
        val refNo = call.argument<String>("referenceNumber")
            ?: return result.error("ARGS", "referenceNumber missing", null)

        PaymentInitialization(activity, activity.application).initiateVoidTransaction(
            oneShotHandler(result) { obj -> responseToMap("success", obj as? TransactionResponse) },
            refNo, appName, appVersion
        )
    }

    

    // ---------------------------------------------------------------- helpers

    /** Handler that replies to Flutter exactly once, ignoring progress messages. */
    private fun oneShotHandler(result: MethodChannel.Result, onSuccess: (Any?) -> Any?): Handler {
        var replied = false
        return Handler(Looper.getMainLooper()) { msg ->
            if (!replied) {
                when (msg.what) {
                    RC_SUCCESS -> {
                        replied = true
                        try { result.success(onSuccess(msg.obj)) }
                        catch (e: Throwable) { result.error("PARSE", e.message, null) }
                    }
                    RC_FAIL, RC_ERROR, RC_TXN_FAILED -> {
                        replied = true
                        result.error("FAILED", msg.obj?.toString() ?: "Failed", null)
                    }
                    else -> Log.d(TAG, "progress ${msg.what}: ${msg.obj}")
                }
            }
            true
        }
    }

        // ---------------------------------------------------------------- dynamic QR
    // generateQr -> SDK SUCCESS (QR) -> reply with QR image -> getTxnStatus() polls
    // -> QR_STATUS_SUCCESS / QR_STATUS_ERROR pushed via channel.invokeMethod("onQrStatus")

    private var pendingQr: MethodChannel.Result? = null   // waiting for QR image
    private var activeQr: QR? = null                      // QR on screen (polling)

    private val qrExecutor: IQRExecutor by lazy {
        PayswiffSDK.Builder(activity.application)
            .withAppName(appName)
            .withAppVersion(appVersion)
            .build()
            .withHandler(qrHandler)
            .getQRExecutorBuilder(activity)
            .build()
    }

    private val qrHandler = Handler(Looper.getMainLooper()) { msg ->
        Log.d(TAG, "QR msg ${msg.what}: ${msg.obj}")
        try { handleQrMessage(msg) }
        catch (e: Throwable) {
            // Never let an SDK message crash the app.
            Log.e(TAG, "QR message ${msg.what} handling failed", e)
            val reply = pendingQr
            pendingQr = null
            try {
                if (reply != null) reply.error("QR_FAILED", e.message ?: "QR error", null)
                else pushQrStatus("error", null, e.message ?: "QR error")
            } catch (_: Throwable) {}
        }
        true
    }

    private fun handleQrMessage(msg: android.os.Message) {
        when (msg.what) {
            RC_SUCCESS -> {
                val qr = msg.obj as? QR
                val qrString = qr?.qrString
                val reply = pendingQr
                pendingQr = null
                if (qr == null || qrString.isNullOrEmpty()) {
                    reply?.error("QR_FAILED", "Failed to read QR from SDK", null)
                } else {
                    activeQr = qr
                    reply?.success(
                        mapOf(
                            "qrString" to qrString,
                            "qrImage" to qrToBase64(qrString),
                            "orderId" to qr.orderId,
                            "vpa" to qr.vpa,
                            "amount" to qr.amount,
                            "qrTimer" to qr.qrTimer?.toString(),
                            "businessName" to qr.businessName
                        )
                    )
                    try { qrExecutor.getTxnStatus(qr) }        // start polling
                    catch (e: Throwable) { Log.e(TAG, "getTxnStatus failed", e) }
                }
            }
            RC_QR_STATUS_SUCCESS ->
                pushQrStatus("success", msg.obj as? QrTransactionResponse, null)
            RC_QR_STATUS_ERROR ->
                pushQrStatus("failed", msg.obj as? QrTransactionResponse, null)
            RC_FAIL, RC_ERROR -> {
                val text = msg.obj?.toString() ?: "QR request failed"
                val reply = pendingQr
                pendingQr = null
                if (reply != null) {
                    reply.error("QR_FAILED", text, null)                      // while generating
                } else if (activeQr != null) {                                // while polling
                    // The SDK poller only recognises status "pending"/"success"/"failed".
                    // Any other status (e.g. UAT returns "Approved") arrives here as
                    // ERROR_MESSAGE with just the raw status text, so classify it ourselves.
                    val mapped = qrStatusFromText(text)
                    Log.d(TAG, "QR polling ended with unrecognised status '$text' -> $mapped")
                    pushQrStatus(mapped, null, text)
                }
            }
        }
    }

    private fun generateQr(call: MethodCall, result: MethodChannel.Result) {
        if (pendingQr != null || activeQr != null) cancelQr()  // drop old QR
        val amount = call.argument<String>("amount")?.toDoubleOrNull()
            ?: return result.error("ARGS", "amount missing", null)
        val orderRef = call.argument<String>("orderRefNo")
            ?: return result.error("ARGS", "orderRefNo missing", null)

        val request = MerchantPersonalizeQR().apply {
            this.amount = String.format(java.util.Locale.US, "%.2f", amount).toDouble()
            this.isPooling = true
            this.staticQR = false
            this.orderReferenceNumber = orderRef
            this.merchantRefNo = call.argument<String>("merchantRefNo") ?: ""
            this.paymentType = "BharatQR"
        }
        if (!isActivatedForEnv()) {
            return result.error("NOT_ACTIVATED", "Payment device not activated for ${BuildConfig.PS_ENV}", null)
        }
        pendingQr = result
        try {
            qrExecutor.generateQr(request)
        } catch (e: Throwable) {
            // Reply here and clear pendingQr, so no one replies to this result again
            // (a second reply throws and closes the app).
            Log.e(TAG, "generateQr failed", e)
            pendingQr = null
            result.error("QR_FAILED", e.message ?: e.javaClass.simpleName, null)
        }
    }

    /** Staff pressed Cancel / QR expired / screen closed. */
    private fun cancelQr() {
        pendingQr?.error("CANCELLED", "QR cancelled", null)
        pendingQr = null
        if (activeQr != null) {
            try { qrExecutor.stopTxnStatusPolling() }
            catch (e: Throwable) { Log.w(TAG, "stopTxnStatusPolling: ${e.message}") }
        }
        activeQr = null
    }

    private fun pushQrStatus(status: String, r: QrTransactionResponse?, error: String?) {
        val qr = activeQr ?: return   // already cancelled - ignore late messages
        activeQr = null
        try { qrExecutor.stopTxnStatusPolling() } catch (_: Throwable) {}
        val map = mapOf(
            "status" to status,
            "responseCode" to r?.responseCode,
            "responseMessage" to (r?.responseMessage ?: error),
            "transactionRefNo" to (r?.transactionRefNo ?: qr.transactionRefNo),
            "orderId" to (r?.orderId ?: qr.orderId),
            "amount" to (r?.amount ?: qr.amount)?.toString(),
            "transactionDate" to r?.transactionDate?.toString(),
            "paymentType" to r?.paymentType
        )
        Log.d(TAG, "QR result -> $map")
        channel?.invokeMethod("onQrStatus", map)
    }

    /** Maps a raw QR status text from the SDK's ERROR_MESSAGE to success / failed / error. */
    private fun qrStatusFromText(text: String): String =
        when (text.trim().lowercase(java.util.Locale.ROOT)) {
            "approved", "success", "successful", "captured", "completed", "paid" -> "success"
            "declined", "rejected", "failure", "failed", "expired", "cancelled" -> "failed"
            else -> "error"
        }

    /** QR string -> PNG base64 (uses ZXing, already in build.gradle). */
    private fun qrToBase64(text: String, size: Int = 600): String {
        val matrix = QRCodeWriter().encode(text, BarcodeFormat.QR_CODE, size, size)
        val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.RGB_565)
        for (x in 0 until size) for (y in 0 until size) {
            bmp.setPixel(x, y, if (matrix.get(x, y)) Color.BLACK else Color.WHITE)
        }
        val out = ByteArrayOutputStream()
        bmp.compress(Bitmap.CompressFormat.PNG, 100, out)
        return Base64.encodeToString(out.toByteArray(), Base64.NO_WRAP)
    }

    private fun responseToMap(status: String, r: TransactionResponse?): Map<String, Any?> {
        val rc = r?.posReceipt
        return mapOf(
            "status" to status,
            "responseCode" to r?.responseCode,
            "responseMessage" to r?.responseMessage,
            "dateTime" to r?.dateTime?.toString(),
            "referenceNumber" to r?.referenceNumber,
            "rrn" to r?.rrn,
            "amount" to r?.amount,
            "transactionStatus" to r?.transactionStatus,
            "cardBrand" to r?.cardBrand,
            "cardNumber" to rc?.cardNumber,   // masked by the SDK
            "cardType" to rc?.cardType,
            "authCode" to rc?.authCode,
            "mid" to rc?.acqMerchantId,
            "tid" to rc?.acqTerminalId,
            "invoiceNo" to rc?.invoiceNo,
            "batchNo" to rc?.batchNo
        )
    }

    @SuppressLint("MissingPermission")
    private fun lastLocation(): LocationData {
        val fine = ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION)
        val coarse = ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_COARSE_LOCATION)
        if (fine == PackageManager.PERMISSION_GRANTED || coarse == PackageManager.PERMISSION_GRANTED) {
            try {
                val lm = activity.getSystemService(Context.LOCATION_SERVICE) as LocationManager
                val loc = lm.getProviders(true)
                    .mapNotNull { lm.getLastKnownLocation(it) }
                    .maxByOrNull { it.time }
                if (loc != null) {
                    return LocationData(loc.provider ?: "gps", loc.latitude, loc.longitude, loc.accuracy, loc.time)
                }
            } catch (e: Throwable) {
                Log.w(TAG, "location failed: ${e.message}")
            }
        }
        return LocationData("none", 0.0, 0.0, 0f, System.currentTimeMillis())
    }
}