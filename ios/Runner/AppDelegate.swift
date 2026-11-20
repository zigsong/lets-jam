import UIKit
import Flutter
import UserNotifications

@UIApplicationMain // 혹은 @main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = registrar(forPlugin: "LetsJamBadge") {
      let channel = FlutterMethodChannel(
        name: "com.chunkybuddy.letsjam/badge",
        binaryMessenger: registrar.messenger()
      )
      channel.setMethodCallHandler { call, result in
        guard call.method == "setBadgeCount" else {
          result(FlutterMethodNotImplemented)
          return
        }
        guard let count = call.arguments as? Int, count >= 0 else {
          result(FlutterError(code: "invalid_badge_count", message: "알림 개수가 올바르지 않습니다.", details: nil))
          return
        }

        if #available(iOS 16.0, *) {
          UNUserNotificationCenter.current().setBadgeCount(count) { error in
            DispatchQueue.main.async {
              if let error = error {
                result(FlutterError(code: "badge_update_failed", message: error.localizedDescription, details: nil))
              } else {
                result(nil)
              }
            }
          }
        } else {
          application.applicationIconBadgeNumber = count
          result(nil)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
