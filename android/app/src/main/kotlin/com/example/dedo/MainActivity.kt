package com.example.dedo

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.dedo/icon_switcher"
    private val PREFS_NAME = "dedo_icon_prefs"
    private val KEY_CURRENT_ICON = "current_icon"

    private val ALIAS_DARK = "com.example.dedo.MainActivityDark"
    private val ALIAS_LIGHT = "com.example.dedo.MainActivityLight"

    // Holds the pending theme change until the user minimizes/exits the app
    private var pendingTheme: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "switchIcon" -> {
                    val target = call.arguments as? String ?: "dark"
                    queuePendingIcon(target)
                    result.success(true)
                }
                "getCurrentIcon" -> {
                    result.success(getSavedIcon())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getSavedIcon(): String {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getString(KEY_CURRENT_ICON, "dark") ?: "dark"
    }

    private fun queuePendingIcon(target: String) {
        val current = getSavedIcon()
        if (target != current) {
            pendingTheme = target
        } else {
            pendingTheme = null
        }
    }

    override fun onStop() {
        super.onStop()

        // Ignore configuration changes (like screen rotation)
        if (isChangingConfigurations) return

        // Ninja Swap: execute the icon alias switch only when the app is minimized/in background!
        val target = pendingTheme ?: return
        pendingTheme = null

        val isDark = target == "dark"
        val pm = packageManager
        val enableAlias = ComponentName(this, if (isDark) ALIAS_DARK else ALIAS_LIGHT)
        val disableAlias = ComponentName(this, if (isDark) ALIAS_LIGHT else ALIAS_DARK)

        try {
            // Enable desired theme launcher alias
            pm.setComponentEnabledSetting(
                enableAlias,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )

            // Disable alternative theme launcher alias
            pm.setComponentEnabledSetting(
                disableAlias,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )

            // Persist the applied icon state
            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().putString(KEY_CURRENT_ICON, target).apply()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
