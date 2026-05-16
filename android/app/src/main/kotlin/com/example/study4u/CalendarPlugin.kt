package com.example.study4u

import android.content.ContentValues
import android.content.Context
import android.provider.CalendarContract
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class CalendarPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.stdy4u/calendar")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "addEvent" -> {
                try {
                    val args = call.arguments as Map<String, Any>
                    val values = ContentValues().apply {
                        put(CalendarContract.Events.CALENDAR_ID, 1)
                        put(CalendarContract.Events.TITLE, args["title"] as String)
                        put(CalendarContract.Events.DESCRIPTION, args["description"] as String)
                        put(CalendarContract.Events.DTSTART, (args["startDate"] as Number).toLong())
                        put(CalendarContract.Events.DTEND, (args["endDate"] as Number).toLong())
                        put(CalendarContract.Events.EVENT_LOCATION, args["location"] as String? ?: "")
                        put(CalendarContract.Events.EVENT_TIMEZONE, java.util.TimeZone.getDefault().id)
                    }
                    val uri = context.contentResolver.insert(CalendarContract.Events.CONTENT_URI, values)
                    result.success(uri != null)
                } catch (e: Exception) {
                    result.success(false)
                }
            }
            "removeEvent" -> {
                try {
                    val args = call.arguments as Map<String, Any>
                    val eventId = args["eventId"] as String
                    val deleted = context.contentResolver.delete(
                        CalendarContract.Events.CONTENT_URI,
                        "${CalendarContract.Events._ID} = ?",
                        arrayOf(eventId)
                    )
                    result.success(deleted > 0)
                } catch (e: Exception) {
                    result.success(false)
                }
            }
            "fetchEvents" -> {
                try {
                    val args = call.arguments as Map<String, Any>
                    val startDate = (args["startDate"] as Number).toLong()
                    val endDate = (args["endDate"] as Number).toLong()
                    val projection = arrayOf(
                        CalendarContract.Events._ID,
                        CalendarContract.Events.TITLE,
                        CalendarContract.Events.DTSTART,
                        CalendarContract.Events.DTEND
                    )
                    val selection = "${CalendarContract.Events.DTSTART} >= ? AND ${CalendarContract.Events.DTEND} <= ?"
                    val selectionArgs = arrayOf(startDate.toString(), endDate.toString())
                    val cursor = context.contentResolver.query(
                        CalendarContract.Events.CONTENT_URI,
                        projection, selection, selectionArgs, null
                    )
                    val events = mutableListOf<Map<String, Any>>()
                    cursor?.use {
                        while (it.moveToNext()) {
                            events.add(mapOf(
                                "eventId" to it.getString(0),
                                "title" to it.getString(1),
                                "startDate" to it.getLong(2),
                                "endDate" to it.getLong(3)
                            ))
                        }
                    }
                    result.success(events)
                } catch (e: Exception) {
                    result.success(emptyList<Map<String, Any>>())
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
