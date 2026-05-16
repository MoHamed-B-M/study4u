import Flutter
import UIKit
import FamilyControls
import ManagedSettings

public class ScreenTimePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.stdy4u/screen_time", binaryMessenger: registrar.messenger())
        let instance = ScreenTimePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getUsageStats" {
            result([])
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
