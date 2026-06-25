import Flutter
import UIKit
import UserNotifications

public class AlarmPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.stdy4u/alarm", binaryMessenger: registrar.messenger())
        let instance = AlarmPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "scheduleAlarm":
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            scheduleAlarm(args: args, result: result)
        case "cancelAlarm":
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            cancelAlarm(args: args, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func scheduleAlarm(args: [String: Any], result: @escaping FlutterResult) {
        let title = args["title"] as? String ?? ""
        let body = args["body"] as? String ?? ""
        let id = args["id"] as? Int ?? 0
        let triggerAt = Date(timeIntervalSince1970: (args["triggerAtMillis"] as? Double ?? 0) / 1000)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerAt)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: "alarm_\(id)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            result(error == nil)
        }
    }

    private func cancelAlarm(args: [String: Any], result: @escaping FlutterResult) {
        let id = args["id"] as? Int ?? 0
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["alarm_\(id)"])
        result(true)
    }
}
