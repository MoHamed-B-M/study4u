package com.example.study4u

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Method channel bridge ("com.stdy4u/app_icon") letting Flutter switch the
 * launcher icon between the default comic icon and the alternate one.
 *
 * The manifest declares two [android.app.activity-alias] entries targeting
 * [MainActivity]; exactly one is enabled at a time via PackageManager
 * component-enabled settings, which persist across reboots.
 */
class AppIconPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var binding: FlutterPlugin.FlutterPluginBinding? = null
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding
        channel = MethodChannel(binding.binaryMessenger, "com.stdy4u/app_icon")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val context = binding?.applicationContext
        when (call.method) {
            "setAppIcon" -> {
                val useAlt = call.arguments as? Boolean
                if (context == null || useAlt == null) {
                    result.success(false)
                    return
                }
                try {
                    val pm = context.packageManager
                    val def =
                        ComponentName(context, "com.example.study4u.MainLauncherDefault")
                    val alt =
                        ComponentName(context, "com.example.study4u.MainLauncherAlt")
                    pm.setComponentEnabledSetting(
                        if (useAlt) alt else def,
                        PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                        PackageManager.DONT_KILL_APP,
                    )
                    pm.setComponentEnabledSetting(
                        if (useAlt) def else alt,
                        PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                        PackageManager.DONT_KILL_APP,
                    )
                    result.success(true)
                } catch (_: Exception) {
                    result.success(false)
                }
            }

            "isAltIcon" -> {
                if (context == null) {
                    result.success(false)
                    return
                }
                try {
                    val state = context.packageManager.getComponentEnabledSetting(
                        ComponentName(context, "com.example.study4u.MainLauncherAlt")
                    )
                    result.success(state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED)
                } catch (_: Exception) {
                    result.success(false)
                }
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        this.binding = null
    }
}
