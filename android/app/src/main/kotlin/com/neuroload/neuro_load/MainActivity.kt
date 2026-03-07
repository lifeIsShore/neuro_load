package com.neuroload.neuro_load

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {

    private val WIDGET_CHANNEL = "neuroload/widget"

    // ── BroadcastReceiver for widget Distracted tap ───────────────────────────
    private val distractionReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == WidgetDistractionCallback.ACTION_WIDGET_DISTRACTION) {
                // Forward to Flutter as a MethodChannel call on the widget channel
                // Flutter's NotificationService.onNotificationDistraction callback
                // will fire addLap() without requiring the app to be in foreground.
                // We reuse the existing distraction callback registered in session_provider.
                flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                    MethodChannel(messenger, WIDGET_CHANNEL)
                        .invokeMethod("onWidgetDistraction", null)
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Widget MethodChannel ──────────────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateWidget" -> {
                        val isActive    = call.argument<Boolean>("isActive") ?: false
                        val elapsed     = call.argument<Int>("elapsedSeconds") ?: 0
                        val category    = call.argument<String>("category") ?: ""
                        val subCat      = call.argument<String>("subCategory") ?: ""
                        val lapCount    = call.argument<Int>("lapCount") ?: 0
                        val lastMins    = call.argument<Int>("lastSessionMinutes")
                        val lastCat     = call.argument<String>("lastSessionCategory")

                        CoroutineScope(Dispatchers.IO).launch {
                            pushWidgetState(
                                context        = applicationContext,
                                isActive       = isActive,
                                elapsedSeconds = elapsed,
                                category       = category,
                                subCategory    = subCat,
                                lapCount       = lapCount,
                                lastMins       = lastMins,
                                lastCat        = lastCat,
                            )
                        }
                        result.success(null)
                    }

                    "clearWidget" -> {
                        val lastMins = call.argument<Int>("lastSessionMinutes")
                        val lastCat  = call.argument<String>("lastSessionCategory")
                        CoroutineScope(Dispatchers.IO).launch {
                            pushWidgetState(
                                context        = applicationContext,
                                isActive       = false,
                                elapsedSeconds = 0,
                                category       = "",
                                subCategory    = "",
                                lapCount       = 0,
                                lastMins       = lastMins,
                                lastCat        = lastCat,
                            )
                        }
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // ── Lifecycle: register / unregister broadcast receiver ───────────────────

    override fun onStart() {
        super.onStart()
        val filter = IntentFilter(WidgetDistractionCallback.ACTION_WIDGET_DISTRACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(distractionReceiver, filter, RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(distractionReceiver, filter)
        }
    }

    override fun onStop() {
        super.onStop()
        try { unregisterReceiver(distractionReceiver) } catch (_: IllegalArgumentException) {}
    }

    // ── Glance state update helper ────────────────────────────────────────────

    private suspend fun pushWidgetState(
        context: Context,
        isActive: Boolean,
        elapsedSeconds: Int,
        category: String,
        subCategory: String,
        lapCount: Int,
        lastMins: Int?,
        lastCat: String?,
    ) {
        val manager = GlanceAppWidgetManager(context)
        val glanceIds = manager.getGlanceIds(NeuroLoadWidget::class.java)

        for (id in glanceIds) {
            updateAppWidgetState(context, id) { prefs ->
                prefs[WidgetKeys.SESSION_ACTIVE]   = isActive
                prefs[WidgetKeys.ELAPSED_SECONDS]  = elapsedSeconds
                prefs[WidgetKeys.CATEGORY]         = category
                prefs[WidgetKeys.SUB_CATEGORY]     = subCategory
                prefs[WidgetKeys.LAP_COUNT]        = lapCount
                if (lastMins != null) prefs[WidgetKeys.LAST_SESSION_MINS] = lastMins
                if (lastCat  != null) prefs[WidgetKeys.LAST_SESSION_CAT]  = lastCat
            }
            NeuroLoadWidget().update(context, id)
        }
    }
}
