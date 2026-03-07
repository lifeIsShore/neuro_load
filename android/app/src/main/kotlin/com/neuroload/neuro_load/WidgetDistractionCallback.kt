package com.neuroload.neuro_load

import android.content.Context
import android.content.Intent
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback

// ── Feature 03: Widget Distraction Callback ───────────────────────────────────
//
// Called when the user taps "Distracted" on the active home screen widget.
// Sends a local broadcast that MainActivity.kt picks up to fire addLap()
// via the same mechanism as the notification action button.

class WidgetDistractionCallback : ActionCallback {
    companion object {
        const val ACTION_WIDGET_DISTRACTION =
            "com.neuroload.neuro_load.WIDGET_DISTRACTION"
    }

    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters,
    ) {
        val intent = Intent(ACTION_WIDGET_DISTRACTION).apply {
            setPackage(context.packageName)
        }
        context.sendBroadcast(intent)
    }
}
