package com.neuroload.neuro_load

import android.content.Context
import androidx.compose.runtime.Composable
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
import androidx.glance.appwidget.appWidgetBackground
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.state.getAppWidgetState
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.*
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
        // Read state BEFORE entering provideContent using the stable
        // getAppWidgetState API. This avoids currentState<T>() which is
        // an inline function whose resolution is sensitive to the Kotlin
        // compiler version / Glance version pairing.
        val prefs = getAppWidgetState(context, PreferencesGlanceStateDefinition, id)

        val isActive    = prefs[WidgetKeys.SESSION_ACTIVE]  ?: false
        val elapsedSecs = prefs[WidgetKeys.ELAPSED_SECONDS] ?: 0
        val category    = prefs[WidgetKeys.CATEGORY]        ?: ""
        val subCategory = prefs[WidgetKeys.SUB_CATEGORY]    ?: ""
        val lapCount    = prefs[WidgetKeys.LAP_COUNT]       ?: 0
        val lastMins    = prefs[WidgetKeys.LAST_SESSION_MINS]
        val lastCat     = prefs[WidgetKeys.LAST_SESSION_CAT]

        provideContent {
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
    val bgColor = ColorProvider(android.graphics.Color.parseColor("#0A0A0A"))
    val teal    = ColorProvider(android.graphics.Color.parseColor("#00B5A5"))
    val grey    = ColorProvider(android.graphics.Color.parseColor("#888888"))
    val dimGrey = ColorProvider(android.graphics.Color.parseColor("#505050"))
    val white   = ColorProvider(android.graphics.Color.parseColor("#E8E8E8"))
    val darkCard = ColorProvider(android.graphics.Color.parseColor("#1E1E1E"))
    val black   = ColorProvider(android.graphics.Color.parseColor("#0A0A0A"))

    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(bgColor)
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
                            color = teal,
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
                            color = grey,
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
                        color = white,
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
                                color = grey,
                                fontSize = 11.sp,
                            ),
                        )
                    }
                    Spacer(modifier = GlanceModifier.defaultWeight())
                    Box(
                        modifier = GlanceModifier
                            .background(darkCard)
                            .padding(horizontal = 10.dp, vertical = 6.dp)
                            .clickable(actionRunCallback<WidgetDistractionCallback>()),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(
                            text = "Distracted",
                            style = TextStyle(
                                color = grey,
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
                        color = teal,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Medium,
                    ),
                )

                Spacer(modifier = GlanceModifier.defaultWeight())

                Box(
                    modifier = GlanceModifier
                        .fillMaxWidth()
                        .background(teal)
                        .padding(horizontal = 16.dp, vertical = 10.dp)
                        .clickable(actionStartActivity<MainActivity>()),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(
                        text = "Start Session",
                        style = TextStyle(
                            color = black,
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
                            color = dimGrey,
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
                                .background(teal)
                        ) {}
                        Spacer(modifier = GlanceModifier.width(8.dp))
                        Column {
                            Text(
                                text = "LAST SESSION",
                                style = TextStyle(
                                    color = teal,
                                    fontSize = 10.sp
                                )
                            )
                            Text(
                                text = lastCat.uppercase(),
                                style = TextStyle(
                                    color = white,
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
                        color = dimGrey,
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
