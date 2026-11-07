package com.punnyam.staff
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.util.Base64
import com.google.gson.Gson
import com.pnsol.sdk.dynamicViews.ViewUtils
import com.pnsol.sdk.util.DeviceInfo
import com.punnyam.staff.print.PrintModel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "punnyam/apos_printer"
    private lateinit var paymentChannel: PaymentChannel

    // Result of the Payswiff card screen (PosPaymentActivity)
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (::paymentChannel.isInitialized &&
            paymentChannel.onActivityResult(requestCode, resultCode, data)) return
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        paymentChannel = PaymentChannel(this)
        paymentChannel.register(flutterEngine.dartExecutor.binaryMessenger)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // true only on the Payswiff POS terminal
                    "isPosDevice" -> result.success(
                         try { DeviceInfo.isDevicePOS } catch (e: Throwable) { false }
                    )

                    // Print: Dart sends the receipt as a JSON string matching PrintModel
                    "printReceipt" -> {
                        try {
                            val json = call.argument<String>("json") ?: "{}"
                            val model = Gson().fromJson(json, PrintModel::class.java)
                            // Bill image sent from Dart as base64 (null = no image)
                            val logo = call.argument<String>("logo")?.let { decodeLogo(it) }
                            ViewUtils.startPrint(
                                this,
                                logo, // printed in the template's image section (after header)
                                "print_template_receipt_card_qb.json",
                                model,
                                object : ViewUtils.PrintListener {
                                    // The SDK may call these from a background thread;
                                    // Flutter requires replies on the main thread.
                                    override fun onSuccess() {
                                        runOnUiThread { result.success(true) }
                                    }
                                    override fun onError(message: String?) {
                                        runOnUiThread { result.error("PRINT_FAILED", message, null) }
                                    }
                                }
                            )
                        } catch (e: Throwable) {
                            result.error("PRINT_FAILED", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

        // N86 prints 58 mm paper = 384 dots. The SDK sends the logo to the printer
    // as-is, and anything wider is silently dropped - so scale it down here.
    private val printerWidth = 384

    private fun decodeLogo(base64: String): Bitmap? = try {
        val bytes = Base64.decode(base64, Base64.DEFAULT)
        BitmapFactory.decodeByteArray(bytes, 0, bytes.size)?.let { src ->
            // Fit to paper width, keep aspect ratio (never upscale)
            val width = minOf(src.width, printerWidth)
            val height = (src.height * width.toFloat() / src.width).toInt().coerceAtLeast(1)
            val scaled = Bitmap.createScaledBitmap(src, width, height, true)

            // White background (transparent PNGs otherwise print black)
            val out = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            Canvas(out).apply {
                drawColor(Color.WHITE)
                drawBitmap(scaled, 0f, 0f, null)
            }
            android.util.Log.d("APOS", "logo ${src.width}x${src.height} -> ${width}x${height}")
            out
        }
    } catch (e: Throwable) {
        android.util.Log.e("APOS", "logo decode failed: ${e.message}")
        null // bad image data - print without it
    }
}