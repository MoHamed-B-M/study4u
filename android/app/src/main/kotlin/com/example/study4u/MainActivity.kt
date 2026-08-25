package com.example.study4u

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(ScreenTimePlugin())
        flutterEngine.plugins.add(CalendarPlugin())
        flutterEngine.plugins.add(AlarmPlugin())
        flutterEngine.plugins.add(SettingsPlugin())
        flutterEngine.plugins.add(WidgetPlugin())
    }
}
