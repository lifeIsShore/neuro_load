package com.neuroload.neuro_load

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.appWidgetBackground
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.color.ColorProvider
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.layout.wrapContentHeight
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider

// ── NeuroLoad Home Screen Widget ─────────────────────────────────────────────
//
// Feature 03: Jetpack Glance App Widget.
//
// Displays two states:
//   Idle   — "NEUROLOAD" label + "Start Session" button + last session line
//   Active — large elapsed timer + category + "Distracted" button
//
// State is stored in GlanceState (Preferences DataStore) and pushed from
// Flutter via MethodChannel → MainActivity.kt → updateAppWidgetState().
//
// The Distracted button fires WidgetDistractionCallback which broadcasts
// to the running Flutter isolate the same way as the notification action.

// ── State keys ────────────────────────────────────────────────────────────────

object WidgetKeys {
    val SESSION_ACTIVE      = booleanPreferencesKey("session_active")
    val ELAPSED_SECONDS     = intPreferencesKey("elapsed_seconds")
    val CATEGORY            = stringPreferencesKey("category")
    val SUB_CATEGORY        = stringPreferencesKey("sub_category")
    val LAP_COUNT           = intPreferencesKey("lap_count")
    val LAST_SESSION_MINS   = intPreferencesKey("last_session_minutes")
    val LAST_SESSION_CAT    = stringPreferencesKey("last_session_category")
}

// ── GlanceAppWidget ───────────────────────────────────────────────────────────

class NeuroLoadWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val prefs = currentState<Preferences>()
            val isActive       = prefs[WidgetKeys.SESSION_ACTIVE]    ?: false
            val elapsedSecs    = prefs[WidgetKeys.ELAPSED_SECONDS]   ?: 0
            val category       = prefs[WidgetKeys.CATEGORY]          ?: ""
            val subCategory    = prefs[WidgetKeys.SUB_CATEGORY]      ?: ""
            val lapCount       = prefs[WidgetKeys.LAP_COUNT]         ?: 0
            val lastMins       = prefs[WidgetKeys.LAST_SESSION_MINS]
            val lastCat        = prefs[WidgetKeys.LAST_SESSION_CAT]

            NeuroLoadWidgetContent(
                isActive     = isActive,
                elapsedSecs  = elapsedSecs,
                category     = category,
                subCategory  = subCategory,
                lapCount     = lapCount,
                lastMins     = lastMins,
                lastCat      = lastCat,
            )
        }
    }
}

// ── Widget UI ─────────────────────────────────────────────────────────────────

@Composable
private fun NeuroLoadWidgetContent(
    isActive: Boolean,
    elapsedSecs: Int,
    category: String,
    subCategory: String,
    lapCount: Int,
    lastMins: Int?,
    lastCat: String?,
) {
    val bgColor = Color(0xFF0A0A0A)
    val teal    = Color(0xFF00B5A5)
    val grey    = Color(0xFF888888)
    val dimGrey = Color(0xFF505050)
    val white   = Color(0xFFE8E8E8)

    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(ColorProvider(bgColor, bgColor))
            .appWidgetBackground()
            .padding(16.dp),
        contentAlignment = Alignment.TopStart,
    ) {
        if (isActive) {
            // ── Active state ──────────────────────────────────────────────
            Column(modifier = GlanceModifier.fillMaxSize()) {
                // Category label
                if (category.isNotEmpty()) {
                    Text(
                        text = category.uppercase(),
                        style = TextStyle(
                            color = ColorProvider(teal, teal),
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Medium,
                        ),
                    )
                    Spacer(modifier = GlanceModifier.height(4.dp))
                }

                // Sub-category
                if (subCategory.isNotEmpty()) {
                    Text(
                        text = subCategory,
                        style = TextStyle(
                            color = ColorProvider(grey, grey),
                            fontSize = 11.sp,
                        ),
                    )
                    Spacer(modifier = GlanceModifier.height(4.dp))
                }

                // Large elapsed timer — focal point
                val h = elapsedSecs / 3600
                val m = (elapsedSecs % 3600) / 60
                val s = elapsedSecs % 60
                val timeStr = if (h > 0)
                    "%d:%02d:%02d".format(h, m, s)
                else
                    "%d:%02d".format(m, s)

                Text(
                    text = timeStr,
                    style = TextStyle(
                        color = ColorProvider(white, white),
                        fontSize = 38.sp,
                        fontWeight = FontWeight.Bold,
                    ),
                )

                Spacer(modifier = GlanceModifier.defaultWeight())

                // Bottom row: lap count + distracted button
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    if (lapCount > 0) {
                        Text(
                            text = "$lapCount lap${if (lapCount != 1) "s" else ""}",
                            style = TextStyle(
                                color = ColorProvider(grey, grey),
                                fontSize = 11.sp,
                            ),
                        )
                    }
                    Spacer(modifier = GlanceModifier.defaultWeight())
                    // Distracted button — fix #1: clickable as GlanceModifier, not Text modifier
                    Box(
                        modifier = GlanceModifier
                            .background(ColorProvider(Color(0xFF1E1E1E), Color(0xFF1E1E1E)))
                            .padding(horizontal = 10.dp, vertical = 6.dp)
                            .clickable(actionRunCallback<WidgetDistractionCallback>()),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(
                            text = "Distracted",
                            style = TextStyle(
                                color = ColorProvider(grey, grey),
                                fontSize = 11.sp,
                            ),
                        )
                    }
                }
            }
        } else {
            // ── Idle state ────────────────────────────────────────────────
            Column(modifier = GlanceModifier.fillMaxSize()) {
                // App name
                Text(
                    text = "NEUROLOAD",
                    style = TextStyle(
                        color = ColorProvider(teal, teal),
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Medium,
                    ),
                )

                Spacer(modifier = GlanceModifier.defaultWeight())

                // Start session CTA — fix #2: actionStartActivity<T>() instead of Intent overload
                Box(
                    modifier = GlanceModifier
                        .fillMaxWidth()
                        .background(ColorProvider(teal, teal))
                        .padding(horizontal = 16.dp, vertical = 10.dp)
                        .clickable(actionStartActivity<MainActivity>()),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(
                        text = "Start Session",
                        style = TextStyle(
                            color = ColorProvider(Color(0xFF0A0A0A), Color(0xFF0A0A0A)),
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold,
                        ),
                    )
                }

                Spacer(modifier = GlanceModifier.height(8.dp))

                // Last session line (if available)
                val subtitle = when {
                    lastMins != null && lastCat != null ->
                        "Last · ${lastMins}min · $lastCat"
                    lastMins != null ->
                        "Last session · ${lastMins}min"
                    else ->
                        "Your first session is waiting."
                }
                Text(
                    text = subtitle,
                    style = TextStyle(
                        color = ColorProvider(dimGrey, dimGrey),
                        fontSize = 10.sp,
                    ),
                )
            }
        }
    }
}

// ── Widget Receiver ───────────────────────────────────────────────────────────
// Fix #3: @GlanceAppWidgetReceiver is not a valid annotation in Glance 1.1.0.
// The receiver is registered in AndroidManifest.xml instead.

class NeuroLoadWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = NeuroLoadWidget()
}
