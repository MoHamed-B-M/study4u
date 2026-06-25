import Flutter
import UIKit

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

    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
