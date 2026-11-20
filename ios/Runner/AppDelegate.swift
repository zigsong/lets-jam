import UIKit
import Flutter
import LinkPresentation
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
    if let registrar = registrar(forPlugin: "LetsJamProfileShare") {
      let channel = FlutterMethodChannel(
        name: "com.chunkybuddy.letsjam/profile_share",
        binaryMessenger: registrar.messenger()
      )
      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "shareProfile" else {
          result(FlutterMethodNotImplemented)
          return
        }
        guard let self = self else {
          result(false)
          return
        }
        self.shareProfile(call.arguments, result: result)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func shareProfile(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let arguments = arguments as? [String: Any],
          let urlString = arguments["url"] as? String,
          let url = URL(string: urlString), url.scheme == "https", url.host == "letsjam.work",
          let title = arguments["title"] as? String else {
      result(FlutterError(code: "invalid_profile_share", message: "프로필 링크가 올바르지 않습니다.", details: nil))
      return
    }

    var presenter = window?.rootViewController
    while let presented = presenter?.presentedViewController {
      presenter = presented
    }
    guard let presenter = presenter, let view = presenter.viewIfLoaded, view.window != nil else {
      result(FlutterError(code: "share_unavailable", message: "공유 화면을 열 수 없습니다.", details: nil))
      return
    }

    let item = ProfileShareItem(url: url, title: title)
    let sharesheet = UIActivityViewController(activityItems: [item], applicationActivities: nil)
    if let popover = sharesheet.popoverPresentationController {
      popover.sourceView = view
      let x = arguments["x"] as? Double ?? 0
      let y = arguments["y"] as? Double ?? 0
      let width = arguments["width"] as? Double ?? 0
      let height = arguments["height"] as? Double ?? 0
      var source = CGRect.null
      if [x, y, width, height].allSatisfy({ $0.isFinite }), width > 0, height > 0 {
        source = view.convert(CGRect(x: x, y: y, width: width, height: height), from: nil)
          .intersection(view.bounds)
      }
      popover.sourceRect = source.isEmpty
        ? CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        : source
    }
    sharesheet.completionWithItemsHandler = { _, completed, _, error in
      if let error = error {
        result(FlutterError(code: "share_failed", message: error.localizedDescription, details: nil))
      } else {
        result(completed)
      }
    }
    presenter.present(sharesheet, animated: true)
  }
}

private final class ProfileShareItem: NSObject, UIActivityItemSource {
  private let url: URL
  private let title: String

  init(url: URL, title: String) {
    self.url = url
    self.title = title
    super.init()
  }

  func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
    url
  }

  func activityViewController(
    _ activityViewController: UIActivityViewController,
    itemForActivityType activityType: UIActivity.ActivityType?
  ) -> Any? {
    url
  }

  func activityViewController(
    _ activityViewController: UIActivityViewController,
    subjectForActivityType activityType: UIActivity.ActivityType?
  ) -> String {
    title
  }

  func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
    let metadata = LPLinkMetadata()
    metadata.originalURL = url
    metadata.url = url
    metadata.title = title
    return metadata
  }
}
