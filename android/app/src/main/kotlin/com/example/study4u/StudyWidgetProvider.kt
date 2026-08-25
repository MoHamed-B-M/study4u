package com.example.study4u

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

/**
 * Comic-print study dashboard widget (2x2).
 *
 * Data is pushed from Flutter as a JSON snapshot via [WidgetPlugin] and stored
 * in SharedPreferences. Today's "next class" is computed natively at render
 * time so the widget stays accurate between app launches (system refreshes it
 * every [widget_study_info.updatePeriodMillis]).
 */
class StudyWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val views = buildRemoteViews(context)
        for (appWidgetId in appWidgetIds) {
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    companion object {
        private const val PREFS_NAME = "stdy4u_widget"
        private const val KEY_DATA = "widget_data"

        private const val INK_RED = 0xFFE63946.toInt()
        private const val INK_BLACK = 0xFF000000.toInt()
        private const val DARK_TEXT = 0xFFF5F5F5.toInt()
        private const val MUTED_LIGHT = 0x99000000.toInt() // 60% ink black
        private const val MUTED_DARK = 0x99F5F5F5.toInt() // 60% dark text

        /** Saves a data snapshot pushed from Flutter and re-renders all widgets. */
        fun saveAndPush(context: Context, json: String): Boolean {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putString(KEY_DATA, json)
                .apply()
            return pushAll(context)
        }

        fun pushAll(context: Context): Boolean {
            val manager = AppWidgetManager.getInstance(context) ?: return false
            val ids = manager.getAppWidgetIds(ComponentName(context, StudyWidgetProvider::class.java))
            if (ids.isEmpty()) return false
            val views = buildRemoteViews(context)
            for (id in ids) {
                manager.updateAppWidget(id, views)
            }
            return true
        }

        fun hasWidgets(context: Context): Boolean {
            val manager = AppWidgetManager.getInstance(context) ?: return false
            val ids = manager.getAppWidgetIds(ComponentName(context, StudyWidgetProvider::class.java))
            return ids.isNotEmpty()
        }

        fun buildRemoteViews(context: Context): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.widget_study)

            // Tap anywhere on the widget to open the app.
            context.packageManager.getLaunchIntentForPackage(context.packageName)?.let { intent ->
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                val pendingIntent = PendingIntent.getActivity(
                    context, 0, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            // Day/night text colors to match the comic theme.
            val nightMask =
                context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
            val isNight = nightMask == Configuration.UI_MODE_NIGHT_YES
            val ink = if (isNight) DARK_TEXT else INK_BLACK
            val muted = if (isNight) MUTED_DARK else MUTED_LIGHT

            views.setTextColor(R.id.widget_app_name, INK_BLACK)
            views.setTextColor(R.id.widget_date, muted)
            views.setTextColor(R.id.widget_next_label, INK_RED)
            views.setTextColor(R.id.widget_next_name, ink)
            views.setTextColor(R.id.widget_next_detail, muted)

            val raw = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getString(KEY_DATA, null)
            var data: JSONObject? = null
            if (raw != null) {
                try {
                    data = JSONObject(raw)
                } catch (_: Exception) {
                }
            }

            renderNextClass(views, data, ink, muted)
            renderStats(views, data, ink)
            views.setTextViewText(
                R.id.widget_date,
                SimpleDateFormat("EEE d MMM", Locale.getDefault())
                    .format(Date()).uppercase(Locale.getDefault()),
            )
            return views
        }

        private fun renderNextClass(
            views: RemoteViews,
            data: JSONObject?,
            inkColor: Int,
            mutedColor: Int,
        ) {
            val classes = data?.optJSONArray("classes")
            if (classes == null || classes.length() == 0) {
                views.setTextViewText(R.id.widget_next_label, "NEXT CLASS")
                views.setTextViewText(R.id.widget_next_name, "No classes today")
                views.setTextViewText(R.id.widget_next_detail, "Enjoy the break!")
                return
            }

            val nowMinutes = Calendar.getInstance().let {
                it.get(Calendar.HOUR_OF_DAY) * 60 + it.get(Calendar.MINUTE)
            }

            var current: JSONObject? = null
            var next: JSONObject? = null
            for (i in 0 until classes.length()) {
                val cls = classes.optJSONObject(i) ?: continue
                val startMin = cls.optInt("startMin", -1)
                val endMin = cls.optInt("endMin", -1)
                if (startMin <= nowMinutes && nowMinutes < endMin && current == null) {
                    current = cls
                } else if (startMin > nowMinutes &&
                    (next == null || startMin < next.optInt("startMin", Int.MAX_VALUE))
                ) {
                    next = cls
                }
            }

            val highlight = current ?: next
            if (highlight == null) {
                views.setTextViewText(R.id.widget_next_label, "NEXT CLASS")
                views.setTextViewText(R.id.widget_next_name, "Done for today!")
                views.setTextViewText(R.id.widget_next_detail, "No more classes")
                return
            }

            val name = highlight.optString("name", "—").ifEmpty { "—" }
            val room = highlight.optString("room", "").trim()
            val isCurrent = highlight === current

            views.setTextViewText(
                R.id.widget_next_label,
                if (isCurrent) "IN PROGRESS" else "NEXT CLASS",
            )
            views.setTextViewText(R.id.widget_next_name, name)
            views.setTextColor(R.id.widget_next_name, inkColor)
            views.setTextViewText(
                R.id.widget_next_detail,
                buildString {
                    append(if (isCurrent) "until ${highlight.optString("endTime")}" else highlight.optString("startTime"))
                    if (room.isNotEmpty()) append(" · ").append(room)
                },
            )
            views.setTextColor(R.id.widget_next_detail, mutedColor)
        }

        private fun renderStats(
            views: RemoteViews,
            data: JSONObject?,
            inkColor: Int,
        ) {
            val tasks = data?.optInt("pendingTasks", 0) ?: 0
            val focusMinutes = data?.optInt("focusMinutes", 0) ?: 0
            val cgpa = data?.optString("cgpa", "—")?.ifEmpty { "—" } ?: "—"
            val letter = data?.optString("letter", "")?.trim().orEmpty()

            views.setTextViewText(R.id.widget_stat_tasks_value, tasks.toString())
            views.setTextViewText(
                R.id.widget_stat_focus_value,
                if (focusMinutes >= 60) "${focusMinutes / 60}h${focusMinutes % 60}" else "${focusMinutes}m",
            )
            views.setTextViewText(R.id.widget_stat_cgpa_value, cgpa)
            views.setTextViewText(
                R.id.widget_stat_tasks_label,
                if (tasks == 1) "TASK LEFT" else "TASKS LEFT",
            )
            views.setTextViewText(R.id.widget_stat_focus_label, "FOCUS TODAY")
            views.setTextViewText(
                R.id.widget_stat_cgpa_label,
                if (letter.isEmpty()) "CGPA" else "CGPA · $letter",
            )

            listOf(
                R.id.widget_stat_tasks_value,
                R.id.widget_stat_focus_value,
                R.id.widget_stat_cgpa_value,
            ).forEach { id -> views.setTextColor(id, inkColor) }
        }
    }
}
