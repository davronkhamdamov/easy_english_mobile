import Flutter
import UIKit
import UserNotifications

// MARK: - App Delegate

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 1. Push notifications
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        application.registerForRemoteNotifications()

        // 2. Register Native iOS 26 Liquid Glass Navigation Bar Platform View Factory
        let registrar = self.registrar(forPlugin: "IOS26LiquidGlassNavPlugin")
        if let messenger = registrar?.messenger() {
            let factory = IOS26LiquidGlassFactory(messenger: messenger)
            registrar?.register(factory, withId: "uz.cordialsoft.easyenglish/ios26_liquid_glass_nav")
            // Backward compatibility alias
            registrar?.register(factory, withId: "uz.cordialsoft.easyenglish/liquid_nav_bar")
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }
}
