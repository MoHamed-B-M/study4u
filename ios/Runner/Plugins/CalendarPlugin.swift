import Flutter
import UIKit
import EventKit

public class CalendarPlugin: NSObject, FlutterPlugin {
    private let eventStore = EKEventStore()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.stdy4u/calendar", binaryMessenger: registrar.messenger())
        let instance = CalendarPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "addEvent":
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            addEvent(args: args, result: result)
        case "removeEvent":
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            removeEvent(args: args, result: result)
        case "fetchEvents":
            guard let args = call.arguments as? [String: Any] else {
                result([])
                return
            }
            fetchEvents(args: args, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func addEvent(args: [String: Any], result: @escaping FlutterResult) {
        let title = args["title"] as? String ?? ""
        let description = args["description"] as? String ?? ""
        let startDate = Date(timeIntervalSince1970: (args["startDate"] as? Double ?? 0) / 1000)
        let endDate = Date(timeIntervalSince1970: (args["endDate"] as? Double ?? 0) / 1000)

        eventStore.requestWriteOnlyAccessToEvents { [weak self] granted, error in
            guard granted, let self = self else { result(false); return }
            let event = EKEvent(eventStore: self.eventStore)
            event.title = title
            event.notes = description
            event.startDate = startDate
            event.endDate = endDate
            event.calendar = self.eventStore.defaultCalendarForNewEvents
            do {
                try self.eventStore.save(event, span: .thisEvent)
                result(true)
            } catch {
                result(false)
            }
        }
    }

    private func removeEvent(args: [String: Any], result: @escaping FlutterResult) {
        result(true)
    }

    private func fetchEvents(args: [String: Any], result: @escaping FlutterResult) {
        let startDate = Date(timeIntervalSince1970: (args["startDate"] as? Double ?? 0) / 1000)
        let endDate = Date(timeIntervalSince1970: (args["endDate"] as? Double ?? 0) / 1000)

        eventStore.requestFullAccessToEvents { [weak self] granted, error in
            guard granted, let self = self else { result([]); return }
            let predicate = self.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
            let events = self.eventStore.events(matching: predicate).map { event -> [String: Any] in
                return [
                    "eventId": event.eventIdentifier ?? "",
                    "title": event.title ?? "",
                    "startDate": Int(event.startDate.timeIntervalSince1970 * 1000),
                    "endDate": Int(event.endDate.timeIntervalSince1970 * 1000)
                ] as [String: Any]
            }
            result(events)
        }
    }
}
