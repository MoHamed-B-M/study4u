import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    let registrar = self.registrar(forPlugin: "ScreenTimePlugin")!
    ScreenTimePlugin.register(with: registrar)
    let calendarRegistrar = self.registrar(forPlugin: "CalendarPlugin")!
    CalendarPlugin.register(with: calendarRegistrar)
    let alarmRegistrar = self.registrar(forPlugin: "AlarmPlugin")!
    AlarmPlugin.register(with: alarmRegistrar)

    // Register alarm notification category for proper alarm behavior
    let alarmCategory = UNNotificationCategory(
      identifier: "ALARM_CATEGORY",
      actions: [],
      intentIdentifiers: [],
      options: [.customDismissAction]
    )
    UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])

    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, error in }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
