package com.example.study4u

import android.content.ComponentName
import android.content.Context
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
 * component-enabled settings, which persist across reboots. As a second
 * layer of durability, the desired choice is also synchronously committed
 * to SharedPreferences ("app_icon_prefs" -> "use_alt") so an explicit
 * PackageManager reset (OS update, launcher cache clear) can be restored
 * and so the choice survives a quick process kill before Hive flushes.
 */
class AppIconPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var binding: FlutterPlugin.FlutterPluginBinding? = null
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding
        channel = MethodChannel(binding.binaryMessenger, "com.stdy4u/app_icon")
        channel.setMethodCallHandler(this)
        // Restore the persisted icon before Flutter Dart code runs so the
        // launcher state is correct even before any Dart apply() call.
        binding.applicationContext?.let { ctx ->
            try {
                val prefs = ctx.getSharedPreferences("app_icon_prefs", Context.MODE_PRIVATE)
                if (prefs.contains("use_alt")) {
                    val useAlt = prefs.getBoolean("use_alt", false)
                    val pm = ctx.packageManager
                    val def = ComponentName(ctx, "com.example.study4u.MainLauncherDefault")
                    val alt = ComponentName(ctx, "com.example.study4u.MainLauncherAlt")
                    val altState = pm.getComponentEnabledSetting(alt)
                    val isAltEnabled = altState == PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                    // If PM state (effective) doesn't match persisted choice, restore it.
                    // Handle DEFAULT case: effective alt disabled = manifest false.
                    val needsRestore = isAltEnabled != useAlt
                    if (needsRestore) {
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
                    }
                }
            } catch (_: Exception) {
            }
        }
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
                    // Synchronous commit – survives a quick process kill before Hive flushes.
                    context.getSharedPreferences("app_icon_prefs", Context.MODE_PRIVATE)
                        .edit().putBoolean("use_alt", useAlt).commit()
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
                    val pm = context.packageManager
                    val altState = pm.getComponentEnabledSetting(
                        ComponentName(context, "com.example.study4u.MainLauncherAlt")
                    )
                    // Explicit ENABLED means alt is active.
                    if (altState == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) {
                        result.success(true)
                        return
                    }
                    if (altState == PackageManager.COMPONENT_ENABLED_STATE_DISABLED) {
                        result.success(false)
                        return
                    }
                    // DEFAULT (never explicitly set) -> fall back to persisted pref,
                    // which is the durable source of truth. Manifest default alt = disabled.
                    val prefs = context.getSharedPreferences("app_icon_prefs", Context.MODE_PRIVATE)
                    if (prefs.contains("use_alt")) {
                        result.success(prefs.getBoolean("use_alt", false))
                    } else {
                        result.success(false)
                    }
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
