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
import androidx.glance.appwidget.*
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.layout.*
import androidx.glance.text.*
import androidx.glance.state.GlanceState
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.state.PreferencesGlanceStateDefinition
import androidx.glance.unit.ColorProvider

// ── NeuroLoad Home Screen Widget ─────────────────────────────────────────────
//
// Feature 03: Jetpack Glance App Widget.
//
// Displays two states:
//   Idle   — "NEUROLOAD" label + "Start Session" button + last session line
//   Active — large elapsed timer + category + "Distracted" button

object WidgetKeys {
    val SESSION_ACTIVE      = booleanPreferencesKey("session_active")
    val ELAPSED_SECONDS     = intPreferencesKey("elapsed_seconds")
    val CATEGORY            = stringPreferencesKey("category")
    val SUB_CATEGORY        = stringPreferencesKey("sub_category")
    val LAP_COUNT           = intPreferencesKey("lap_count")
    val LAST_SESSION_MINS   = intPreferencesKey("last_session_minutes")
    val LAST_SESSION_CAT    = stringPreferencesKey("last_session_category")
}

class NeuroLoadWidget : GlanceAppWidget() {

    override val stateDefinition: GlanceStateDefinition<Preferences> = PreferencesGlanceStateDefinition

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = GlanceState.getValue(context, PreferencesGlanceStateDefinition, id.toString())

        provideContent {
            val isActive       = prefs[WidgetKeys.SESSION_ACTIVE]    ?: false
            val elapsedSecs    = prefs[WidgetKeys.ELAPSED_SECONDS]   ?: 0
            val category       = prefs[WidgetKeys.CATEGORY]          ?: ""
            val subCategory    = prefs[WidgetKeys.SUB_CATEGORY]      ?: ""
            val lapCount       = prefs[WidgetKeys.LAP_COUNT]         ?: 0
            val lastMins       = prefs[WidgetKeys.LAST_SESSION_MINS]
            val lastCat        = prefs[WidgetKeys.LAST_SESSION_CAT]

            NeuroLoadWidgetContent(
                isActive,
                elapsedSecs,
                category,
                subCategory,
                lapCount,
                lastMins,
                lastCat,
            )
        }
    }
}

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
            .background(bgColor, bgColor)
            .appWidgetBackground()
            .padding(16.dp),
        contentAlignment = Alignment.TopStart,
    ) {
        if (isActive) {
            Column(modifier = GlanceModifier.fillMaxSize()) {
                if (category.isNotEmpty()) {
                    Text(
                        text = category.uppercase(),
                        style = TextStyle(
                            color = ColorProvider(teal),
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold
                        )
                    )
                    Spacer(modifier = GlanceModifier.size(4.dp))
                }

                if (subCategory.isNotEmpty()) {
                    Text(
                        text = subCategory,
                        style = TextStyle(
                            color = ColorProvider(grey),
                            fontSize = 11.sp,
                        ),
                    )
                    Spacer(modifier = GlanceModifier.size(4.dp))
                }

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
                        color = ColorProvider(white),
                        fontSize = 38.sp,
                        fontWeight = FontWeight.Bold,
                    ),
                )

                Spacer(modifier = GlanceModifier.defaultWeight())

                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    if (lapCount > 0) {
                        Text(
                            text = "$lapCount lap${if (lapCount != 1) "s" else ""}",
                            style = TextStyle(
                                color = ColorProvider(grey),
                                fontSize = 11.sp,
                            ),
                        )
                    }
                    Spacer(modifier = GlanceModifier.defaultWeight())
                    Box(
                        modifier = GlanceModifier
                            .background(Color(0xFF1E1E1E), Color(0xFF1E1E1E))
                            .padding(horizontal = 10.dp, vertical = 6.dp)
                            .clickable(actionRunCallback<WidgetDistractionCallback>()),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(
                            text = "Distracted",
                            style = TextStyle(
                                color = ColorProvider(grey),
                                fontSize = 11.sp,
                            ),
                        )
                    }
                }
            }
        } else {
            Column(modifier = GlanceModifier.fillMaxSize()) {
                Text(
                    text = "NEUROLOAD",
                    style = TextStyle(
                        color = ColorProvider(teal),
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Medium,
                    ),
                )

                Spacer(modifier = GlanceModifier.defaultWeight())

                Box(
                    modifier = GlanceModifier
                        .fillMaxWidth()
                        .background(teal, teal)
                        .padding(horizontal = 16.dp, vertical = 10.dp)
                        .clickable(actionStartActivity<MainActivity>()),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(
                        text = "Start Session",
                        style = TextStyle(
                            color = ColorProvider(Color(0xFF0A0A0A)),
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold,
                        ),
                    )
                }

                Spacer(modifier = GlanceModifier.size(8.dp))

                if (lastCat == null) {
                    Text(
                        text = "NO PREVIOUS SESSION",
                        style = TextStyle(
                            color = ColorProvider(dimGrey),
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Medium
                        )
                    )
                } else {
                    Row(
                        modifier = GlanceModifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = GlanceModifier
                                .width(4.dp)
                                .fillMaxHeight()
                                .background(teal, teal)
                        ) {}
                        Spacer(modifier = GlanceModifier.width(8.dp))
                        Column {
                            Text(
                                text = "LAST SESSION",
                                style = TextStyle(
                                    color = ColorProvider(teal),
                                    fontSize = 10.sp
                                )
                            )
                            Text(
                                text = lastCat.uppercase(),
                                style = TextStyle(
                                    color = ColorProvider(white),
                                    fontSize = 14.sp
                                )
                            )
                        }
                    }
                }

                Spacer(modifier = GlanceModifier.size(8.dp))

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
                        color = ColorProvider(dimGrey),
                        fontSize = 10.sp,
                    ),
                )
            }
        }
    }
}

class NeuroLoadWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = NeuroLoadWidget()
}
