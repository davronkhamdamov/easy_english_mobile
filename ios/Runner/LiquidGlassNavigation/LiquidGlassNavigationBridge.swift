import Flutter
import UIKit

// MARK: - Flutter ↔ Swift Navigation Bridge
/// Bidirectional `FlutterMethodChannel` bridge between the Dart navigation layer
/// and the native `LiquidGlassTabBarController`.
///
/// ## Flutter → Swift methods
/// | Method                  | Arguments                                            |
/// |-------------------------|------------------------------------------------------|
/// | `configureItems`        | `{ "items": [ {id, label, sfSymbolName, …} ] }`      |
/// | `setSelectedIndex`      | `{ "index": Int }`                                   |
/// | `updateScrollOffset`    | `{ "tabId": String?, "offset": Double, "contentHeight": Double, "viewportHeight": Double }` |
/// | `setMinimizeBehavior`   | `{ "behavior": String }`                             |
/// | `setBottomAccessory`    | `{ "label": String }` or `nil`                       |
/// | `setTabBarVisible`      | `{ "visible": Bool, "animated": Bool }`              |
/// | `getTabBarFrame`        | (none)                                               |
///
/// ## Swift → Flutter methods
/// | Method                  | Arguments                                            |
/// |-------------------------|------------------------------------------------------|
/// | `onTabSelected`         | `{ "index": Int }`                                   |
/// | `onTabBarFrameChanged`  | `{ "x", "y", "width", "height", "bottomSafeArea" }`  |
final class LiquidGlassNavigationBridge: NSObject {

    // MARK: - Constants

    static let channelName = "uz.cordialsoft.easyenglish/liquid_glass_nav"

    // MARK: - Properties

    private let channel: FlutterMethodChannel
    private weak var tabBarController: LiquidGlassTabBarController?

    /// Throttle timer for geometry updates to avoid high-frequency channel traffic.
    private var geometryThrottleTimer: Timer?
    private var pendingGeometry: [String: Double]?

    // MARK: - Initialisation

    init(tabBarController: LiquidGlassTabBarController, messenger: FlutterBinaryMessenger) {
        self.tabBarController = tabBarController
        self.channel = FlutterMethodChannel(name: Self.channelName, binaryMessenger: messenger)
        super.init()

        tabBarController.navigationBridge = self
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    deinit {
        geometryThrottleTimer?.invalidate()
    }

    // MARK: - Incoming (Flutter → Swift)

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "configureItems":
            guard let args = call.arguments as? [String: Any],
                  let items = args["items"] as? [[String: Any]] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected {items: [...]}", details: nil))
                return
            }
            tabBarController?.configureItems(items)
            result(nil)

        case "setSelectedIndex":
            guard let args = call.arguments as? [String: Any],
                  let index = args["index"] as? Int else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected {index: Int}", details: nil))
                return
            }
            tabBarController?.selectTab(at: index)
            result(nil)

        case "updateScrollOffset":
            guard let args = call.arguments as? [String: Any],
                  let offset = args["offset"] as? Double,
                  let contentHeight = args["contentHeight"] as? Double,
                  let viewportHeight = args["viewportHeight"] as? Double else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected offset/contentHeight/viewportHeight", details: nil))
                return
            }
            let tabId = args["tabId"] as? String
            tabBarController?.updateScrollOffset(
                tabId: tabId,
                offset: offset,
                contentHeight: contentHeight,
                viewportHeight: viewportHeight
            )
            result(nil)

        case "setMinimizeBehavior":
            guard let args = call.arguments as? [String: Any],
                  let behavior = args["behavior"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected {behavior: String}", details: nil))
                return
            }
            tabBarController?.setMinimizeBehavior(behavior)
            result(nil)

        case "setBottomAccessory":
            let args = call.arguments as? [String: Any]
            tabBarController?.setBottomAccessory(content: args)
            result(nil)

        case "setTabBarVisible":
            guard let args = call.arguments as? [String: Any],
                  let visible = args["visible"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGS", message: "Expected {visible: Bool}", details: nil))
                return
            }
            let animated = args["animated"] as? Bool ?? true
            tabBarController?.setTabBarVisible(visible, animated: animated)
            result(nil)

        case "getTabBarFrame":
            if let tbc = tabBarController {
                let frame = tbc.tabBar.frame
                result([
                    "x": Double(frame.origin.x),
                    "y": Double(frame.origin.y),
                    "width": Double(frame.size.width),
                    "height": Double(frame.size.height),
                    "bottomSafeArea": Double(tbc.view.safeAreaInsets.bottom),
                ])
            } else {
                result(nil)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Outgoing (Swift → Flutter)

    /// Notifies Flutter that the user tapped a tab.
    func onTabSelected(index: Int) {
        channel.invokeMethod("onTabSelected", arguments: ["index": index])
    }

    /// Notifies Flutter that the tab bar geometry changed (e.g. during minimisation).
    /// Calls are throttled to ≤30 Hz to avoid excessive channel traffic.
    func onTabBarFrameChanged(x: Double, y: Double, width: Double, height: Double, bottomSafeArea: Double) {
        let geometry: [String: Double] = [
            "x": x,
            "y": y,
            "width": width,
            "height": height,
            "bottomSafeArea": bottomSafeArea,
        ]

        pendingGeometry = geometry

        if geometryThrottleTimer == nil {
            geometryThrottleTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: false) { [weak self] _ in
                guard let self = self, let geo = self.pendingGeometry else { return }
                self.channel.invokeMethod("onTabBarFrameChanged", arguments: geo)
                self.pendingGeometry = nil
                self.geometryThrottleTimer = nil
            }
        }
    }
}
