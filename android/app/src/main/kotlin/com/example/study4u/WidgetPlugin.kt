package com.example.study4u

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

/**
 * Method channel bridge ("com.stdy4u/widget") between Flutter and the
 * [StudyWidgetProvider] home-screen widget.
 */
class WidgetPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var binding: FlutterPlugin.FlutterPluginBinding? = null
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding
        channel = MethodChannel(binding.binaryMessenger, "com.stdy4u/widget")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val context = binding?.applicationContext
        when (call.method) {
            "updateWidget" -> {
                if (context == null) {
                    result.success(false)
                    return
                }
                try {
                    @Suppress("UNCHECKED_CAST")
                    val args = call.arguments as? Map<Any?, Any?>
                    val json = JSONObject(args ?: emptyMap<Any?, Any?>()).toString()
                    result.success(StudyWidgetProvider.saveAndPush(context, json))
                } catch (_: Exception) {
                    result.success(false)
                }
            }

            "requestPinWidget" -> {
                if (context == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                    result.success(false)
                    return
                }
                try {
                    val manager = AppWidgetManager.getInstance(context)
                    val provider = ComponentName(context, StudyWidgetProvider::class.java)
                    val supported = manager != null && manager.isRequestPinAppWidgetSupported
                    result.success(supported && manager.requestPinAppWidget(provider, null, null))
                } catch (_: Exception) {
                    result.success(false)
                }
            }

            "hasWidgets" -> {
                result.success(context != null && StudyWidgetProvider.hasWidgets(context))
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        this.binding = null
    }
}
